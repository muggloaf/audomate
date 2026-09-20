import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'local_repository.dart';
import 'supabase_config.dart';
import 'supabase_storage_service.dart';

class RemoteSnapshot {
  const RemoteSnapshot({required this.projects, required this.profile});

  final List<AuditProject> projects;
  final EngineerProfile profile;
}

class SupabaseRepository {
  SupabaseRepository({SupabaseClient? client, SupabaseStorageService? storage})
    : _client = client ?? SupabaseConfig.client,
      _storage = storage ?? SupabaseStorageService(client: client);

  final SupabaseClient? _client;
  final SupabaseStorageService _storage;

  SupabaseClient get client {
    final value = _client;
    if (value == null) throw StateError('Supabase is not configured.');
    return value;
  }

  bool get canSync => _client != null && client.auth.currentUser != null;

  Future<String> currentOrganisationId() async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('Sign in before syncing.');
    final row =
        await client
            .from('organisations')
            .select('id')
            .eq('created_by', user.id)
            .limit(1)
            .single();
    return row['id'] as String;
  }

  Future<void> pushSnapshot(
    List<AuditProject> projects,
    EngineerProfile profile,
  ) async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('Sign in before syncing.');
    final organisationId = await currentOrganisationId();
    final issueRows = await client.from('issue_types').select('id,label');
    final locationRows = await client
        .from('finding_locations')
        .select('id,label');
    final issueIds = {
      for (final row in issueRows) row['label'] as String: row['id'] as String,
    };
    final locationIds = {
      for (final row in locationRows)
        row['label'] as String: row['id'] as String,
    };

    await _pushProfile(organisationId, profile);
    for (final project in projects) {
      project.organisationId = organisationId;
      if (project.coverPhoto != null &&
          project.coverPhoto!.remotePath == null) {
        project.coverPhoto!.remotePath = await _storage.uploadProjectCover(
          organisationId: organisationId,
          projectId: project.id,
          photo: project.coverPhoto!,
        );
      }
      await client.from('projects').upsert({
        'id': project.id,
        'organisation_id': organisationId,
        'project_number': project.number,
        'project_type': project.projectType,
        'name': project.name,
        'site_address': project.site,
        'project_date': _date(project.createdAt),
        'status':
            project.completed == 0
                ? 'draft'
                : project.completed == project.spaces.length
                ? 'complete'
                : 'in_progress',
        'preamble': project.preamble,
        'conclusion': project.conclusion,
        'cover_object_path': project.coverPhoto?.remotePath,
        'owner_id': user.id,
      });

      if (project.folders.isEmpty && project.spaces.isNotEmpty) {
        project.folders.addAll(AuditProject.foldersFromSpaces(project.spaces));
      }
      for (final folder in project.folders) {
        await client.from('project_sections').upsert({
          'id': folder.id,
          'project_id': project.id,
          'parent_section_id': folder.parentId,
          'name': folder.name,
          'kind': folder.kind,
          'sort_order': folder.sortOrder,
        });
      }

      for (final space in project.spaces) {
        await client.from('spaces').upsert({
          'id': space.id,
          'project_id': project.id,
          'section_id': space.sectionId,
          'name': space.name,
          'owner_or_occupant': '',
          'sort_order': space.sortOrder,
        });
        if (!space.isComplete && space.inspectedAt == null) continue;
        await client.from('inspections').upsert({
          'id': space.inspectionId,
          'space_id': space.id,
          'inspector_id': user.id,
          'inspected_at':
              (space.inspectedAt ?? DateTime.now()).toUtc().toIso8601String(),
          'no_issues': space.noIssues,
        });
        for (
          var findingIndex = 0;
          findingIndex < space.findings.length;
          findingIndex++
        ) {
          final finding = space.findings[findingIndex];
          final issueTypeId = issueIds[finding.type] ?? issueIds['Other'];
          final locationId =
              locationIds[finding.location] ?? locationIds['Other'];
          await client.from('findings').upsert({
            'id': finding.id,
            'inspection_id': space.inspectionId,
            'issue_type_id': issueTypeId,
            'custom_issue_type':
                issueIds.containsKey(finding.type) ? null : finding.type,
            'location_id': locationId,
            'custom_location':
                locationId == locationIds['Other'] ? finding.location : null,
            'priority': _priority(finding.severity),
            'observation': finding.notes,
            'recommendation': finding.recommendation,
            'sort_order': findingIndex,
          });
          for (
            var photoIndex = 0;
            photoIndex < finding.photos.length;
            photoIndex++
          ) {
            final photo = finding.photos[photoIndex];
            photo.remotePath ??= await _storage.uploadFindingPhoto(
              organisationId: organisationId,
              projectId: project.id,
              findingId: finding.id,
              photoId: photo.id,
              bytes: photo.bytes,
              mimeType: _mime(photo.name),
              originalFilename: photo.name,
            );
            await client.from('finding_photos').upsert({
              'id': photo.id,
              'finding_id': finding.id,
              'object_path': photo.remotePath,
              'original_filename': photo.name,
              'mime_type': _mime(photo.name),
              'byte_size': photo.bytes.length,
              'sort_order': photoIndex,
            });
          }
        }
      }
    }
  }

  Future<RemoteSnapshot> pullSnapshot(
    EngineerProfile localProfile, {
    List<AuditProject> localProjects = const [],
  }) async {
    final organisationId = await currentOrganisationId();
    final user = client.auth.currentUser!;
    final projectRows = await client
        .from('projects')
        .select()
        .eq('organisation_id', organisationId)
        .eq('owner_id', user.id)
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: false);
    final projectsData =
        projectRows.map((v) => Map<String, dynamic>.from(v)).toList();
    final projectIds = projectsData.map((v) => v['id'] as String).toList();

    final sectionRows =
        projectIds.isEmpty
            ? <dynamic>[]
            : await client
                .from('project_sections')
                .select()
                .inFilter('project_id', projectIds)
                .order('sort_order');
    final spaceRows =
        projectIds.isEmpty
            ? <dynamic>[]
            : await client
                .from('spaces')
                .select()
                .inFilter('project_id', projectIds)
                .isFilter('deleted_at', null)
                .order('sort_order');
    final spacesData =
        spaceRows.map((v) => Map<String, dynamic>.from(v)).toList();
    final spaceIds = spacesData.map((v) => v['id'] as String).toList();
    final inspectionRows =
        spaceIds.isEmpty
            ? <dynamic>[]
            : await client
                .from('inspections')
                .select()
                .inFilter('space_id', spaceIds)
                .isFilter('deleted_at', null)
                .order('inspected_at', ascending: false);
    final inspectionsData =
        inspectionRows.map((v) => Map<String, dynamic>.from(v)).toList();
    final inspectionIds =
        inspectionsData.map((v) => v['id'] as String).toList();
    final findingRows =
        inspectionIds.isEmpty
            ? <dynamic>[]
            : await client
                .from('findings')
                .select()
                .inFilter('inspection_id', inspectionIds)
                .isFilter('deleted_at', null)
                .order('sort_order');
    final findingsData =
        findingRows.map((v) => Map<String, dynamic>.from(v)).toList();
    final findingIds = findingsData.map((v) => v['id'] as String).toList();
    final photoRows =
        findingIds.isEmpty
            ? <dynamic>[]
            : await client
                .from('finding_photos')
                .select()
                .inFilter('finding_id', findingIds)
                .order('sort_order');
    final issueRows = await client.from('issue_types').select('id,label');
    final locationRows = await client
        .from('finding_locations')
        .select('id,label');

    final sections = {
      for (final row in sectionRows) row['id'] as String: row['name'] as String,
    };
    final foldersByProject = <String, List<AuditFolder>>{};
    for (final raw in sectionRows) {
      final row = Map<String, dynamic>.from(raw);
      foldersByProject
          .putIfAbsent(row['project_id'] as String, () => [])
          .add(
            AuditFolder(
              id: row['id'] as String,
              name: row['name'] as String,
              kind: row['kind'] as String? ?? 'Space',
              parentId: row['parent_section_id'] as String?,
              sortOrder: row['sort_order'] as int? ?? 0,
            ),
          );
    }
    final issueLabels = {
      for (final row in issueRows) row['id'] as String: row['label'] as String,
    };
    final locationLabels = {
      for (final row in locationRows)
        row['id'] as String: row['label'] as String,
    };
    final cachedPhotos = <String, PhotoData>{};
    void cache(PhotoData? photo) {
      if (photo?.remotePath != null) cachedPhotos[photo!.remotePath!] = photo;
    }

    cache(localProfile.letterhead);
    cache(localProfile.signature);
    for (final project in localProjects) {
      cache(project.coverPhoto);
      for (final room in project.spaces) {
        for (final finding in room.findings) {
          for (final photo in finding.photos) {
            cache(photo);
          }
        }
      }
    }
    final photosByFinding = <String, List<PhotoData>>{};
    for (final raw in photoRows) {
      final row = Map<String, dynamic>.from(raw);
      final path = row['object_path'] as String;
      final cached = cachedPhotos[path];
      final bytes =
          cached?.bytes ??
          await _tryDownload(SupabaseStorageService.auditMediaBucket, path);
      if (bytes == null) continue;
      photosByFinding
          .putIfAbsent(row['finding_id'] as String, () => [])
          .add(
            PhotoData(
              id: row['id'] as String,
              name: row['original_filename'] as String? ?? path.split('/').last,
              bytes: bytes,
              remotePath: path,
            ),
          );
    }

    final findingsByInspection = <String, List<Finding>>{};
    final customIssues = <String>{...localProfile.customIssueTypes};
    for (final row in findingsData) {
      final customIssue = (row['custom_issue_type'] as String?)?.trim();
      final type =
          customIssue?.isNotEmpty == true
              ? customIssue!
              : issueLabels[row['issue_type_id']] ?? 'Other';
      if (customIssue?.isNotEmpty == true) customIssues.add(customIssue!);
      final customLocation = (row['custom_location'] as String?)?.trim();
      final location =
          customLocation?.isNotEmpty == true
              ? customLocation!
              : locationLabels[row['location_id']] ?? 'Other';
      findingsByInspection
          .putIfAbsent(row['inspection_id'] as String, () => [])
          .add(
            Finding(
              id: row['id'] as String,
              type: type,
              location: location,
              severity: _severity(row['priority'] as String?),
              notes: row['observation'] as String? ?? '',
              recommendation: row['recommendation'] as String? ?? '',
              photos: photosByFinding[row['id']] ?? <PhotoData>[],
            ),
          );
    }

    final inspectionBySpace = <String, Map<String, dynamic>>{};
    for (final row in inspectionsData) {
      inspectionBySpace.putIfAbsent(row['space_id'] as String, () => row);
    }
    final spacesByProject = <String, List<SpaceAudit>>{};
    for (final row in spacesData) {
      final inspection = inspectionBySpace[row['id']];
      final space = SpaceAudit(
        id: row['id'] as String,
        sectionId: row['section_id'] as String?,
        inspectionId: inspection?['id'] as String?,
        name: row['name'] as String,
        section: sections[row['section_id']] ?? 'Standalone spaces',
        sortOrder: row['sort_order'] as int? ?? 0,
      );
      if (inspection != null) {
        space.inspectedAt =
            DateTime.tryParse(
              inspection['inspected_at'] as String? ?? '',
            )?.toLocal();
        space.noIssues = inspection['no_issues'] as bool? ?? false;
        space.findings.addAll(
          findingsByInspection[inspection['id']] ?? <Finding>[],
        );
      }
      spacesByProject
          .putIfAbsent(row['project_id'] as String, () => [])
          .add(space);
    }

    final projects = <AuditProject>[];
    for (final row in projectsData) {
      final coverPath = row['cover_object_path'] as String?;
      PhotoData? cover;
      if (coverPath != null) {
        final cached = cachedPhotos[coverPath];
        final bytes =
            cached?.bytes ??
            await _tryDownload(
              SupabaseStorageService.auditMediaBucket,
              coverPath,
            );
        if (bytes != null) {
          cover = PhotoData(
            id: _objectId(coverPath),
            name: coverPath.split('/').last,
            bytes: bytes,
            remotePath: coverPath,
          );
        }
      }
      projects.add(
        AuditProject(
          id: row['id'] as String,
          organisationId: row['organisation_id'] as String,
          projectType: row['project_type'] as String? ?? 'other',
          number: row['project_number'] as String,
          name: row['name'] as String,
          site: row['site_address'] as String? ?? '',
          createdAt:
              DateTime.tryParse(row['project_date'] as String? ?? '') ??
              DateTime.now(),
          spaces: spacesByProject[row['id']] ?? <SpaceAudit>[],
          folders: foldersByProject[row['id']] ?? <AuditFolder>[],
          coverPhoto: cover,
          preamble: row['preamble'] as String? ?? '',
          conclusion: row['conclusion'] as String? ?? '',
        ),
      );
    }

    final profileRows = await client
        .from('report_profiles')
        .select()
        .eq('organisation_id', organisationId)
        .limit(1);
    final profileRow =
        profileRows.isEmpty
            ? null
            : Map<String, dynamic>.from(profileRows.first);
    final remoteTemplateValues =
        profileRow?['project_templates'] as List<dynamic>? ?? const [];
    final remoteTemplates =
        remoteTemplateValues
            .map(
              (item) => ProjectTemplate.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
    final profile = EngineerProfile(
      name: profileRow?['engineer_name'] as String? ?? localProfile.name,
      designation:
          profileRow?['designation'] as String? ?? localProfile.designation,
      organisation:
          profileRow?['organisation_name'] as String? ??
          localProfile.organisation,
      licence: profileRow?['licence_number'] as String? ?? localProfile.licence,
      phone: profileRow?['phone'] as String? ?? localProfile.phone,
      email: profileRow?['email'] as String? ?? localProfile.email,
      darkMode: localProfile.darkMode,
      customIssueTypes: customIssues.toList()..sort(),
      customProjectTemplates:
          (profileRow?['custom_project_templates'] as List<dynamic>?)
              ?.cast<String>() ??
          localProfile.customProjectTemplates,
      customSpaceTemplates:
          (profileRow?['custom_space_templates'] as List<dynamic>?)
              ?.cast<String>() ??
          localProfile.customSpaceTemplates,
      projectTemplates:
          remoteTemplates.isEmpty
              ? localProfile.projectTemplates
              : remoteTemplates,
    );
    await _loadProfileAsset(
      profile,
      profileRow?['letterhead_object_path'] as String?,
      cachedPhotos: cachedPhotos,
      signature: false,
    );
    await _loadProfileAsset(
      profile,
      profileRow?['signature_object_path'] as String?,
      cachedPhotos: cachedPhotos,
      signature: true,
    );
    return RemoteSnapshot(projects: projects, profile: profile);
  }

  Future<void> processDeletes(List<PendingDelete> operations) async {
    const allowedTables = {
      'finding_photos',
      'findings',
      'inspections',
      'spaces',
      'project_sections',
      'projects',
    };
    for (final operation in List<PendingDelete>.from(operations)) {
      if (!allowedTables.contains(operation.table)) {
        throw StateError('Unsupported delete table: ${operation.table}');
      }
      await client.from(operation.table).delete().eq('id', operation.id);
      if (operation.bucket != null && operation.objectPath != null) {
        await _storage.delete(operation.bucket!, operation.objectPath!);
      }
    }
  }

  Future<void> _pushProfile(
    String organisationId,
    EngineerProfile profile,
  ) async {
    if (profile.letterhead != null && profile.letterheadRemotePath == null) {
      profile.letterheadRemotePath = await _storage.uploadReportAsset(
        organisationId: organisationId,
        assetId: profile.letterhead!.id,
        kind: 'letterhead',
        bytes: profile.letterhead!.bytes,
        mimeType: _mime(profile.letterhead!.name),
        originalFilename: profile.letterhead!.name,
      );
    }
    if (profile.signature != null && profile.signatureRemotePath == null) {
      profile.signatureRemotePath = await _storage.uploadReportAsset(
        organisationId: organisationId,
        assetId: profile.signature!.id,
        kind: 'signature',
        bytes: profile.signature!.bytes,
        mimeType: _mime(profile.signature!.name),
        originalFilename: profile.signature!.name,
      );
    }
    await client.from('report_profiles').upsert({
      'organisation_id': organisationId,
      'organisation_name': profile.organisation,
      'engineer_name': profile.name,
      'designation': profile.designation,
      'licence_number': profile.licence,
      'phone': profile.phone.isEmpty ? null : profile.phone,
      'email': profile.email.isEmpty ? null : profile.email,
      'letterhead_object_path': profile.letterheadRemotePath,
      'signature_object_path': profile.signatureRemotePath,
      'custom_project_templates': profile.customProjectTemplates,
      'custom_space_templates': profile.customSpaceTemplates,
      'project_templates':
          profile.projectTemplates.map((value) => value.toJson()).toList(),
    }, onConflict: 'organisation_id');
  }

  String _priority(String value) =>
      value.startsWith('A')
          ? 'a_one_month'
          : value.startsWith('B')
          ? 'b_three_months'
          : 'monitor';
  String _severity(String? value) => switch (value) {
    'a_one_month' => severities.first,
    'b_three_months' => severities[1],
    _ => severities.last,
  };
  Future<Uint8List?> _tryDownload(String bucket, String path) async {
    try {
      return await _storage.download(bucket, path);
    } catch (_) {
      return null;
    }
  }

  String _objectId(String path) {
    final filename = path.split('/').last;
    final dot = filename.lastIndexOf('.');
    return dot > 0 ? filename.substring(0, dot) : filename;
  }

  Future<void> _loadProfileAsset(
    EngineerProfile profile,
    String? path, {
    required Map<String, PhotoData> cachedPhotos,
    required bool signature,
  }) async {
    if (path == null) return;
    final cached = cachedPhotos[path];
    final bytes =
        cached?.bytes ??
        await _tryDownload(SupabaseStorageService.reportAssetsBucket, path);
    if (bytes == null) return;
    final photo = PhotoData(
      id: _objectId(path),
      name: path.split('/').last,
      bytes: bytes,
      remotePath: path,
    );
    if (signature) {
      profile.signature = photo;
      profile.signatureRemotePath = path;
    } else {
      profile.letterhead = photo;
      profile.letterheadRemotePath = path;
    }
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  String _mime(String filename) {
    final value = filename.toLowerCase();
    if (value.endsWith('.png')) return 'image/png';
    if (value.endsWith('.webp')) return 'image/webp';
    if (value.endsWith('.heic')) return 'image/heic';
    if (value.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }
}
