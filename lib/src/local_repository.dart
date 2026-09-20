import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import 'local_database.dart';
import 'models.dart';

class LocalSnapshot {
  const LocalSnapshot({
    required this.projects,
    required this.profile,
    required this.pendingSync,
    required this.pendingDeletes,
    this.syncOperation,
  });
  final List<AuditProject> projects;
  final EngineerProfile profile;
  final bool pendingSync;
  final List<PendingDelete> pendingDeletes;
  final SyncOperation? syncOperation;
}

class SyncOperation {
  const SyncOperation({
    required this.revision,
    required this.state,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.nextAttemptAt,
    this.lastError,
  });
  final int revision;
  final String state;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextAttemptAt;
  final String? lastError;

  SyncOperation copyWith({
    int? revision,
    String? state,
    int? attemptCount,
    DateTime? updatedAt,
    DateTime? nextAttemptAt,
    String? lastError,
    bool clearNextAttempt = false,
    bool clearError = false,
  }) => SyncOperation(
    revision: revision ?? this.revision,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    nextAttemptAt:
        clearNextAttempt ? null : nextAttemptAt ?? this.nextAttemptAt,
    lastError: clearError ? null : lastError ?? this.lastError,
  );
}

class PendingDelete {
  const PendingDelete({
    required this.table,
    required this.id,
    this.bucket,
    this.objectPath,
  });
  final String table;
  final String id;
  final String? bucket;
  final String? objectPath;
  Map<String, dynamic> toJson() => {
    'table': table,
    'id': id,
    'bucket': bucket,
    'objectPath': objectPath,
  };
  factory PendingDelete.fromJson(Map<String, dynamic> value) => PendingDelete(
    table: value['table'] as String,
    id: value['id'] as String,
    bucket: value['bucket'] as String?,
    objectPath: value['objectPath'] as String?,
  );
}

/// Per-user relational persistence with a one-time importer for legacy JSON
/// snapshots. Supabase remains a separate background synchronization boundary.
class LocalRepository {
  LocalRepository({File? file, AudomateDatabase? database})
    : _file = file,
      _database = database,
      _explicitFile = file != null;

  static const _guestFileName = 'audomate_guest_data.json';
  final bool _explicitFile;
  String? _userId;
  File? _file;
  AudomateDatabase? _database;

  Future<void> useUser(String? userId) async {
    if (_explicitFile || _userId == userId) return;
    _userId = userId;
    _file = null;
    await _database?.close();
    _database = null;
  }

  AudomateDatabase get _db {
    if (_database != null) return _database!;
    final safe = (_userId ?? 'guest').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return _database = AudomateDatabase('audomate_$safe');
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    if (database != null) await database.close();
  }

  Future<File> _dataFile() async {
    if (_file != null) return _file!;
    final directory = await getApplicationDocumentsDirectory();
    final safeUserId = _userId?.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fileName =
        safeUserId == null ? _guestFileName : 'audomate_user_$safeUserId.json';
    _file = File('${directory.path}${Platform.pathSeparator}$fileName');
    return _file!;
  }

  Future<LocalSnapshot?> load() async {
    if (!_explicitFile) {
      final databaseSnapshot = await _loadDatabase();
      if (databaseSnapshot != null) return databaseSnapshot;
      final legacy = await _loadLegacyJson();
      if (legacy != null) {
        await _saveDatabase(
          legacy.projects,
          legacy.profile,
          pendingSync: legacy.pendingSync,
          pendingDeletes: legacy.pendingDeletes,
          syncOperation: legacy.syncOperation,
        );
        return legacy;
      }
      return null;
    }
    return _loadLegacyJson();
  }

  Future<LocalSnapshot?> _loadLegacyJson() async {
    try {
      final file = await _dataFile();
      if (!await file.exists()) return null;
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return LocalSnapshot(
        projects:
            (raw['projects'] as List<dynamic>? ?? const [])
                .map((v) => _projectFromJson(v as Map<String, dynamic>))
                .toList(),
        profile: _profileFromJson(
          raw['profile'] as Map<String, dynamic>? ?? const {},
        ),
        pendingSync: raw['pendingSync'] as bool? ?? true,
        pendingDeletes:
            (raw['pendingDeletes'] as List<dynamic>? ?? const [])
                .map((v) => PendingDelete.fromJson(v as Map<String, dynamic>))
                .toList(),
        syncOperation: _syncOperationFromJson(raw['syncOperation']),
      );
    } catch (_) {
      // A corrupt or unavailable local file must never prevent field work.
      return null;
    }
  }

  Future<void> save(
    List<AuditProject> projects,
    EngineerProfile profile, {
    bool pendingSync = true,
    List<PendingDelete> pendingDeletes = const [],
    int revision = 0,
    SyncOperation? syncOperation,
  }) async {
    if (!_explicitFile) {
      await _saveDatabase(
        projects,
        profile,
        pendingSync: pendingSync,
        pendingDeletes: pendingDeletes,
        syncOperation: syncOperation,
      );
      return;
    }
    final file = await _dataFile();
    final temp = File('${file.path}.tmp');
    final payload = jsonEncode({
      'schemaVersion': 2,
      'pendingSync': pendingSync,
      'pendingDeletes': pendingDeletes.map((v) => v.toJson()).toList(),
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'revision': revision,
      'syncOperation': _syncOperationToJson(syncOperation),
      'profile': _profileToJson(profile),
      'projects': projects.map(_projectToJson).toList(),
    });
    await temp.writeAsString(payload, flush: true);
    if (await file.exists()) await file.delete();
    await temp.rename(file.path);
  }

  Future<LocalSnapshot?> _loadDatabase() async {
    final stateRows = await _db.select(_db.localStateRows).get();
    if (stateRows.isEmpty) return null;
    final state = {for (final row in stateRows) row.key: row.value};
    final projectRows =
        await (_db.select(_db.localProjects)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
    final folderRows =
        await (_db.select(_db.localFolders)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
    final roomRows =
        await (_db.select(_db.localRooms)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
    final findingRows =
        await (_db.select(_db.localFindings)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
    final photoRows =
        await (_db.select(_db.localPhotos)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();

    final photosByOwner = <String, List<PhotoData>>{};
    for (final row in photoRows) {
      photosByOwner
          .putIfAbsent('${row.ownerKind}:${row.ownerId}', () => [])
          .add(
            PhotoData(
              id: row.id,
              name: row.name,
              bytes: Uint8List.fromList(row.bytes),
              remotePath: row.remotePath,
            ),
          );
    }
    final findingsByRoom = <String, List<Finding>>{};
    for (final row in findingRows) {
      findingsByRoom
          .putIfAbsent(row.roomId, () => [])
          .add(
            Finding(
              id: row.id,
              type: row.type,
              location: row.location,
              severity: normalizeSeverity(row.severity),
              notes: row.notes,
              recommendation: row.recommendation,
              photos: photosByOwner['finding:${row.id}'] ?? <PhotoData>[],
            ),
          );
    }
    final roomsByProject = <String, List<SpaceAudit>>{};
    for (final row in roomRows) {
      final room =
          SpaceAudit(
              id: row.id,
              sectionId: row.folderId,
              inspectionId: row.inspectionId,
              name: row.name,
              section: row.sectionName,
              sortOrder: row.sortOrder,
            )
            ..inspectedAt = row.inspectedAt
            ..noIssues = row.noIssues
            ..findings.addAll(findingsByRoom[row.id] ?? const <Finding>[]);
      roomsByProject.putIfAbsent(row.projectId, () => []).add(room);
    }
    final foldersByProject = <String, List<AuditFolder>>{};
    for (final row in folderRows) {
      foldersByProject
          .putIfAbsent(row.projectId, () => [])
          .add(
            AuditFolder(
              id: row.id,
              name: row.name,
              kind: row.kind,
              parentId: row.parentId,
              sortOrder: row.sortOrder,
            ),
          );
    }
    final projects =
        projectRows.map((row) {
          final covers = photosByOwner['project:${row.id}'];
          return AuditProject(
            id: row.id,
            organisationId: row.organisationId,
            projectType: row.projectType,
            number: row.number,
            name: row.name,
            site: row.site,
            createdAt: row.createdAt,
            preamble: row.preamble,
            conclusion: row.conclusion,
            spaces: roomsByProject[row.id] ?? <SpaceAudit>[],
            folders: foldersByProject[row.id] ?? <AuditFolder>[],
            coverPhoto: covers?.firstOrNull,
          );
        }).toList();

    final profileRows = await _db.select(_db.localProfiles).get();
    final profile =
        profileRows.isEmpty
            ? EngineerProfile()
            : _profileFromJson(
              Map<String, dynamic>.from(
                jsonDecode(profileRows.first.payload) as Map,
              ),
            );
    profile.letterhead = photosByOwner['profile:letterhead']?.firstOrNull;
    profile.signature = photosByOwner['profile:signature']?.firstOrNull;
    final pendingRows = await _db.select(_db.localPendingDeletes).get();
    final syncJson = state['sync_operation'];
    final syncMap =
        syncJson == null
            ? null
            : Map<String, dynamic>.from(jsonDecode(syncJson) as Map);
    final syncOperation =
        syncMap == null
            ? null
            : SyncOperation(
              revision: syncMap['revision'] as int? ?? 0,
              state: syncMap['state'] as String? ?? 'pending',
              attemptCount: syncMap['attemptCount'] as int? ?? 0,
              createdAt:
                  DateTime.tryParse(syncMap['createdAt'] as String? ?? '') ??
                  DateTime.now().toUtc(),
              updatedAt:
                  DateTime.tryParse(syncMap['updatedAt'] as String? ?? '') ??
                  DateTime.now().toUtc(),
              nextAttemptAt: DateTime.tryParse(
                syncMap['nextAttemptAt'] as String? ?? '',
              ),
              lastError: syncMap['lastError'] as String?,
            );
    return LocalSnapshot(
      projects: projects,
      profile: profile,
      pendingSync: state['pending_sync'] != 'false' || syncOperation != null,
      pendingDeletes:
          pendingRows
              .map(
                (row) => PendingDelete(
                  table: row.targetTable,
                  id: row.remoteId,
                  bucket: row.bucket,
                  objectPath: row.objectPath,
                ),
              )
              .toList(),
      syncOperation: syncOperation,
    );
  }

  Future<void> _saveDatabase(
    List<AuditProject> projects,
    EngineerProfile profile, {
    required bool pendingSync,
    required List<PendingDelete> pendingDeletes,
    SyncOperation? syncOperation,
  }) async {
    final projectRows = <LocalProject>[];
    final folderRows = <LocalFolder>[];
    final roomRows = <LocalRoom>[];
    final findingRows = <LocalFinding>[];
    final photoRows = <LocalPhoto>[];
    for (var projectIndex = 0; projectIndex < projects.length; projectIndex++) {
      final project = projects[projectIndex];
      projectRows.add(
        LocalProject(
          id: project.id,
          organisationId: project.organisationId,
          projectType: project.projectType,
          number: project.number,
          name: project.name,
          site: project.site,
          createdAt: project.createdAt,
          preamble: project.preamble,
          conclusion: project.conclusion,
          sortOrder: projectIndex,
        ),
      );
      if (project.coverPhoto != null) {
        photoRows.add(
          _localPhoto(project.coverPhoto!, 'project', project.id, 0),
        );
      }
      for (final folder in project.folders) {
        folderRows.add(
          LocalFolder(
            id: folder.id,
            projectId: project.id,
            parentId: folder.parentId,
            name: folder.name,
            kind: folder.kind,
            sortOrder: folder.sortOrder,
          ),
        );
      }
      for (final room in project.spaces) {
        roomRows.add(
          LocalRoom(
            id: room.id,
            projectId: project.id,
            folderId: room.sectionId,
            inspectionId: room.inspectionId,
            name: room.name,
            sectionName: room.section,
            inspectedAt: room.inspectedAt,
            noIssues: room.noIssues,
            sortOrder: room.sortOrder,
          ),
        );
        for (
          var findingIndex = 0;
          findingIndex < room.findings.length;
          findingIndex++
        ) {
          final finding = room.findings[findingIndex];
          findingRows.add(
            LocalFinding(
              id: finding.id,
              roomId: room.id,
              type: finding.type,
              location: finding.location,
              severity: normalizeSeverity(finding.severity),
              notes: finding.notes,
              recommendation: finding.recommendation,
              sortOrder: findingIndex,
            ),
          );
          for (
            var photoIndex = 0;
            photoIndex < finding.photos.length;
            photoIndex++
          ) {
            photoRows.add(
              _localPhoto(
                finding.photos[photoIndex],
                'finding',
                finding.id,
                photoIndex,
              ),
            );
          }
        }
      }
    }
    if (profile.letterhead != null) {
      photoRows.add(
        _localPhoto(profile.letterhead!, 'profile', 'letterhead', 0),
      );
    }
    if (profile.signature != null) {
      photoRows.add(_localPhoto(profile.signature!, 'profile', 'signature', 0));
    }
    final profileJson =
        _profileToJson(profile)
          ..remove('letterhead')
          ..remove('signature');

    await _db.transaction(() async {
      await _db.delete(_db.localPendingDeletes).go();
      await _db.delete(_db.localPhotos).go();
      await _db.delete(_db.localFindings).go();
      await _db.delete(_db.localRooms).go();
      await _db.delete(_db.localFolders).go();
      await _db.delete(_db.localProjects).go();
      await _db.delete(_db.localProfiles).go();
      await _db.delete(_db.localStateRows).go();
      await _db.batch((batch) {
        batch.insertAll(_db.localProjects, projectRows);
        batch.insertAll(_db.localFolders, folderRows);
        batch.insertAll(_db.localRooms, roomRows);
        batch.insertAll(_db.localFindings, findingRows);
        batch.insertAll(_db.localPhotos, photoRows);
        batch.insert(
          _db.localProfiles,
          LocalProfile(id: 'current', payload: jsonEncode(profileJson)),
        );
        batch.insertAll(
          _db.localPendingDeletes,
          pendingDeletes
              .map(
                (item) => LocalPendingDeletesCompanion.insert(
                  targetTable: item.table,
                  remoteId: item.id,
                  bucket: Value(item.bucket),
                  objectPath: Value(item.objectPath),
                ),
              )
              .toList(),
        );
        batch.insertAll(_db.localStateRows, [
          LocalStateRow(key: 'pending_sync', value: '$pendingSync'),
          LocalStateRow(
            key: 'saved_at',
            value: DateTime.now().toUtc().toIso8601String(),
          ),
          const LocalStateRow(key: 'migration_complete', value: 'true'),
          if (pendingSync)
            LocalStateRow(
              key: 'sync_operation',
              value: jsonEncode({
                'revision': syncOperation?.revision ?? 0,
                'state': syncOperation?.state ?? 'pending',
                'attemptCount': syncOperation?.attemptCount ?? 0,
                'createdAt':
                    (syncOperation?.createdAt ?? DateTime.now().toUtc())
                        .toIso8601String(),
                'updatedAt':
                    (syncOperation?.updatedAt ?? DateTime.now().toUtc())
                        .toIso8601String(),
                'nextAttemptAt':
                    syncOperation?.nextAttemptAt?.toIso8601String(),
                'lastError': syncOperation?.lastError,
              }),
            ),
        ]);
      });
    });
  }

  LocalPhoto _localPhoto(
    PhotoData photo,
    String ownerKind,
    String ownerId,
    int sortOrder,
  ) => LocalPhoto(
    id: photo.id,
    ownerKind: ownerKind,
    ownerId: ownerId,
    name: photo.name,
    bytes: photo.bytes,
    remotePath: photo.remotePath,
    sortOrder: sortOrder,
  );

  Map<String, dynamic>? _syncOperationToJson(SyncOperation? operation) =>
      operation == null
          ? null
          : {
            'revision': operation.revision,
            'state': operation.state,
            'attemptCount': operation.attemptCount,
            'createdAt': operation.createdAt.toIso8601String(),
            'updatedAt': operation.updatedAt.toIso8601String(),
            'nextAttemptAt': operation.nextAttemptAt?.toIso8601String(),
            'lastError': operation.lastError,
          };

  SyncOperation? _syncOperationFromJson(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final now = DateTime.now().toUtc();
    return SyncOperation(
      revision: json['revision'] as int? ?? 0,
      state: json['state'] as String? ?? 'pending',
      attemptCount: json['attemptCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
      nextAttemptAt: DateTime.tryParse(json['nextAttemptAt'] as String? ?? ''),
      lastError: json['lastError'] as String?,
    );
  }

  Map<String, dynamic> _photoToJson(PhotoData? p) =>
      p == null
          ? const {}
          : {
            'id': p.id,
            'name': p.name,
            'bytes': base64Encode(p.bytes),
            'remotePath': p.remotePath,
          };

  PhotoData? _photoFromJson(dynamic value) {
    if (value is! Map<String, dynamic> || value['bytes'] == null) return null;
    return PhotoData(
      id: value['id'] as String?,
      name: value['name'] as String? ?? 'photo.jpg',
      bytes: Uint8List.fromList(base64Decode(value['bytes'] as String)),
      remotePath: value['remotePath'] as String?,
    );
  }

  Map<String, dynamic> _findingToJson(Finding f) => {
    'id': f.id,
    'type': f.type,
    'location': f.location,
    'severity': f.severity,
    'notes': f.notes,
    'recommendation': f.recommendation,
    'photos': f.photos.map(_photoToJson).toList(),
  };

  Finding _findingFromJson(Map<String, dynamic> value) => Finding(
    id: value['id'] as String?,
    type: value['type'] as String? ?? 'Other',
    location: value['location'] as String? ?? 'Other',
    severity: normalizeSeverity(value['severity'] as String?),
    notes: value['notes'] as String? ?? '',
    recommendation: value['recommendation'] as String? ?? '',
    photos:
        (value['photos'] as List<dynamic>? ?? const [])
            .map(_photoFromJson)
            .whereType<PhotoData>()
            .toList(),
  );

  Map<String, dynamic> _spaceToJson(SpaceAudit s) => {
    'id': s.id,
    'sectionId': s.sectionId,
    'inspectionId': s.inspectionId,
    'name': s.name,
    'section': s.section,
    'inspectedAt': s.inspectedAt?.toUtc().toIso8601String(),
    'noIssues': s.noIssues,
    'sortOrder': s.sortOrder,
    'findings': s.findings.map(_findingToJson).toList(),
  };

  SpaceAudit _spaceFromJson(Map<String, dynamic> value) {
    final space = SpaceAudit(
      id: value['id'] as String?,
      sectionId: value['sectionId'] as String?,
      inspectionId: value['inspectionId'] as String?,
      name: value['name'] as String? ?? 'Untitled space',
      section: value['section'] as String? ?? 'Standalone spaces',
      sortOrder: value['sortOrder'] as int? ?? 0,
    );
    final inspectedAt = value['inspectedAt'] as String?;
    if (inspectedAt != null) {
      space.inspectedAt = DateTime.tryParse(inspectedAt)?.toLocal();
    }
    space.noIssues = value['noIssues'] as bool? ?? false;
    space.findings.addAll(
      (value['findings'] as List<dynamic>? ?? const []).map(
        (v) => _findingFromJson(v as Map<String, dynamic>),
      ),
    );
    return space;
  }

  Map<String, dynamic> _projectToJson(AuditProject p) => {
    'id': p.id,
    'organisationId': p.organisationId,
    'projectType': p.projectType,
    'number': p.number,
    'name': p.name,
    'site': p.site,
    'createdAt': p.createdAt.toUtc().toIso8601String(),
    'coverPhoto': _photoToJson(p.coverPhoto),
    'preamble': p.preamble,
    'conclusion': p.conclusion,
    'spaces': p.spaces.map(_spaceToJson).toList(),
    'folders':
        p.folders
            .map(
              (f) => {
                'id': f.id,
                'name': f.name,
                'kind': f.kind,
                'parentId': f.parentId,
                'sortOrder': f.sortOrder,
              },
            )
            .toList(),
  };

  AuditProject _projectFromJson(Map<String, dynamic> value) {
    final spaces =
        (value['spaces'] as List<dynamic>? ?? const [])
            .map((v) => _spaceFromJson(v as Map<String, dynamic>))
            .toList();
    final folderValues = value['folders'] as List<dynamic>?;
    return AuditProject(
      id: value['id'] as String?,
      organisationId: value['organisationId'] as String?,
      projectType: value['projectType'] as String? ?? 'Other',
      number: value['number'] as String? ?? '',
      name: value['name'] as String? ?? 'Untitled project',
      site: value['site'] as String? ?? '',
      createdAt:
          DateTime.tryParse(value['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      coverPhoto: _photoFromJson(value['coverPhoto']),
      preamble: value['preamble'] as String? ?? '',
      conclusion: value['conclusion'] as String? ?? '',
      spaces: spaces,
      folders:
          folderValues
              ?.map(
                (v) => AuditFolder(
                  id: (v as Map<String, dynamic>)['id'] as String?,
                  name: v['name'] as String? ?? 'Space',
                  kind: v['kind'] as String? ?? 'Space',
                  parentId: v['parentId'] as String?,
                  sortOrder: v['sortOrder'] as int? ?? 0,
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> _profileToJson(EngineerProfile p) => {
    'name': p.name,
    'designation': p.designation,
    'organisation': p.organisation,
    'licence': p.licence,
    'phone': p.phone,
    'email': p.email,
    'letterhead': _photoToJson(p.letterhead),
    'signature': _photoToJson(p.signature),
    'letterheadRemotePath': p.letterheadRemotePath,
    'signatureRemotePath': p.signatureRemotePath,
    'darkMode': p.darkMode,
    'customIssueTypes': p.customIssueTypes,
    'customProjectTemplates': p.customProjectTemplates,
    'customSpaceTemplates': p.customSpaceTemplates,
    'projectTemplates':
        p.projectTemplates.map((value) => value.toJson()).toList(),
  };

  EngineerProfile _profileFromJson(Map<String, dynamic> value) =>
      EngineerProfile(
        name: value['name'] as String? ?? '',
        designation: value['designation'] as String? ?? '',
        organisation: value['organisation'] as String? ?? '',
        licence: value['licence'] as String? ?? '',
        phone: value['phone'] as String? ?? '',
        email: value['email'] as String? ?? '',
        letterhead: _photoFromJson(value['letterhead']),
        signature: _photoFromJson(value['signature']),
        letterheadRemotePath: value['letterheadRemotePath'] as String?,
        signatureRemotePath: value['signatureRemotePath'] as String?,
        darkMode: value['darkMode'] as bool? ?? false,
        customIssueTypes:
            (value['customIssueTypes'] as List<dynamic>? ?? const [])
                .cast<String>(),
        customProjectTemplates:
            (value['customProjectTemplates'] as List<dynamic>? ?? const [])
                .cast<String>(),
        customSpaceTemplates:
            (value['customSpaceTemplates'] as List<dynamic>? ?? const [])
                .cast<String>(),
        projectTemplates:
            (value['projectTemplates'] as List<dynamic>?)
                ?.map(
                  (item) => ProjectTemplate.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(),
      );
}
