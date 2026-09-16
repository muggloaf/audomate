import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'models.dart';

class LocalSnapshot {
  const LocalSnapshot({
    required this.projects,
    required this.profile,
    required this.pendingSync,
    required this.pendingDeletes,
  });
  final List<AuditProject> projects;
  final EngineerProfile profile;
  final bool pendingSync;
  final List<PendingDelete> pendingDeletes;
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

/// A deliberately small persistence boundary. Supabase can later implement the
/// same load/save contract while this repository remains the offline source.
class LocalRepository {
  LocalRepository({File? file}) : _file = file, _explicitFile = file != null;

  static const _guestFileName = 'audomate_guest_data.json';
  final bool _explicitFile;
  String? _userId;
  File? _file;

  void useUser(String? userId) {
    if (_explicitFile || _userId == userId) return;
    _userId = userId;
    _file = null;
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
  }) async {
    final file = await _dataFile();
    final temp = File('${file.path}.tmp');
    final payload = jsonEncode({
      'schemaVersion': 2,
      'pendingSync': pendingSync,
      'pendingDeletes': pendingDeletes.map((v) => v.toJson()).toList(),
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': _profileToJson(profile),
      'projects': projects.map(_projectToJson).toList(),
    });
    await temp.writeAsString(payload, flush: true);
    if (await file.exists()) await file.delete();
    await temp.rename(file.path);
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
    'findings': s.findings.map(_findingToJson).toList(),
  };

  SpaceAudit _spaceFromJson(Map<String, dynamic> value) {
    final space = SpaceAudit(
      id: value['id'] as String?,
      sectionId: value['sectionId'] as String?,
      inspectionId: value['inspectionId'] as String?,
      name: value['name'] as String? ?? 'Untitled space',
      section: value['section'] as String? ?? 'Standalone spaces',
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
