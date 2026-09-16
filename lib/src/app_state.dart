import 'dart:async';

import 'package:flutter/widgets.dart';
import 'local_repository.dart';
import 'models.dart';
import 'supabase_repository.dart';

class AuditStore extends ChangeNotifier {
  AuditStore({LocalRepository? repository})
    : _repository = repository ?? LocalRepository(),
      _remote = SupabaseRepository();

  final LocalRepository _repository;
  final SupabaseRepository _remote;
  Timer? _saveTimer;
  Timer? _syncTimer;
  bool isReady = false;
  bool isSaving = false;
  String? storageError;
  bool pendingSync = false;
  bool isSyncing = false;
  String? syncError;
  final List<PendingDelete> pendingDeletes = [];
  EngineerProfile profile = EngineerProfile();
  final List<AuditProject> projects = [];
  String? activeUserId;

  Future<void> initialize({String? userId}) async {
    await activateUser(userId, notify: false);
  }

  Future<void> activateUser(String? userId, {bool notify = true}) async {
    if (isReady && activeUserId == userId) return;
    _saveTimer?.cancel();
    _syncTimer?.cancel();
    activeUserId = userId;
    _repository.useUser(userId);
    projects.clear();
    pendingDeletes.clear();
    profile = EngineerProfile();
    pendingSync = false;
    syncError = null;
    isReady = false;
    if (notify) notifyListeners();
    final snapshot = await _repository.load();
    if (snapshot == null) {
      pendingSync = false;
      await _saveNow();
    } else {
      projects.addAll(snapshot.projects);
      profile = snapshot.profile;
      pendingSync = snapshot.pendingSync;
      pendingDeletes.addAll(snapshot.pendingDeletes);
    }
    isReady = true;
    notifyListeners();
    if (pendingSync) scheduleSync();
  }

  void restoreSignupProfile(Map<String, dynamic> metadata, {String? email}) {
    var restored = false;
    void fill(String current, String? value, void Function(String) assign) {
      if (current.trim().isEmpty && value != null && value.trim().isNotEmpty) {
        assign(value.trim());
        restored = true;
      }
    }

    fill(profile.name, metadata['full_name'] as String?, (v) => profile.name = v);
    fill(
      profile.organisation,
      metadata['organisation_name'] as String?,
      (v) => profile.organisation = v,
    );
    fill(
      profile.designation,
      metadata['designation'] as String?,
      (v) => profile.designation = v,
    );
    fill(
      profile.licence,
      metadata['licence_number'] as String?,
      (v) => profile.licence = v,
    );
    fill(profile.email, email, (v) => profile.email = v);
    if (restored) changed();
  }

  void addProject(AuditProject project) {
    projects.insert(0, project);
    changed();
  }

  void changed() {
    pendingSync = true;
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 450), _saveNow);
    scheduleSync();
  }

  void scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 2), syncNow);
  }

  void queueFindingDeletion(Finding finding) {
    for (final photo in finding.photos) {
      pendingDeletes.add(
        PendingDelete(
          table: 'finding_photos',
          id: photo.id,
          bucket: 'audit-media',
          objectPath: photo.remotePath,
        ),
      );
    }
    pendingDeletes.add(PendingDelete(table: 'findings', id: finding.id));
    changed();
  }

  void queuePhotoDeletion(PhotoData photo) {
    pendingDeletes.add(
      PendingDelete(
        table: 'finding_photos',
        id: photo.id,
        bucket: 'audit-media',
        objectPath: photo.remotePath,
      ),
    );
    changed();
  }

  void deleteSpace(AuditProject project, SpaceAudit space) {
    for (final finding in space.findings) {
      for (final photo in finding.photos) {
        pendingDeletes.add(
          PendingDelete(
            table: 'finding_photos',
            id: photo.id,
            bucket: 'audit-media',
            objectPath: photo.remotePath,
          ),
        );
      }
    }
    pendingDeletes.add(PendingDelete(table: 'spaces', id: space.id));
    project.spaces.remove(space);
    changed();
  }

  void deleteProject(AuditProject project) {
    if (project.coverPhoto != null)
      pendingDeletes.add(
        PendingDelete(
          table: 'projects',
          id: project.id,
          bucket: 'audit-media',
          objectPath: project.coverPhoto!.remotePath,
        ),
      );
    for (final space in project.spaces) {
      for (final finding in space.findings) {
        for (final photo in finding.photos) {
          pendingDeletes.add(
            PendingDelete(
              table: 'finding_photos',
              id: photo.id,
              bucket: 'audit-media',
              objectPath: photo.remotePath,
            ),
          );
        }
      }
    }
    pendingDeletes.add(PendingDelete(table: 'projects', id: project.id));
    projects.remove(project);
    changed();
  }

  Future<void> syncNow() async {
    if (isSyncing || !_remote.canSync) return;
    isSyncing = true;
    syncError = null;
    notifyListeners();
    try {
      if (pendingSync) {
        await _remote.pushSnapshot(projects, profile);
        await _remote.processDeletes(pendingDeletes);
        pendingDeletes.clear();
      }
      final remote = await _remote.pullSnapshot(profile);
      projects
        ..clear()
        ..addAll(remote.projects);
      profile = remote.profile;
      pendingSync = false;
      await _saveNow();
    } catch (error) {
      syncError = error.toString();
      pendingSync = true;
      await _saveNow();
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _saveNow() async {
    isSaving = true;
    storageError = null;
    notifyListeners();
    try {
      await _repository.save(
        projects,
        profile,
        pendingSync: pendingSync,
        pendingDeletes: pendingDeletes,
      );
    } catch (_) {
      storageError = 'Changes are on screen but could not be saved locally.';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}

class AuditScope extends InheritedNotifier<AuditStore> {
  const AuditScope({super.key, required AuditStore store, required super.child})
    : super(notifier: store);
  static AuditStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuditScope>()!.notifier!;
}
