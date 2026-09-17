import 'dart:async';

import 'package:flutter/widgets.dart';
import 'local_repository.dart';
import 'models.dart';
import 'supabase_repository.dart';

class AuditStore extends ChangeNotifier with WidgetsBindingObserver {
  AuditStore({LocalRepository? repository, SupabaseRepository? remote})
    : _repository = repository ?? LocalRepository(),
      _remote = remote ?? SupabaseRepository() {
    WidgetsBinding.instance.addObserver(this);
  }

  final LocalRepository _repository;
  final SupabaseRepository _remote;
  Timer? _syncTimer;
  int _changeRevision = 0;
  int _persistedRevision = 0;
  Future<void> _localWriteChain = Future<void>.value();
  SyncOperation? _syncOperation;
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
    _changeRevision++;
    _syncTimer?.cancel();
    await _localWriteChain;
    activeUserId = userId;
    await _repository.useUser(userId);
    projects.clear();
    pendingDeletes.clear();
    profile = EngineerProfile();
    pendingSync = false;
    syncError = null;
    storageError = null;
    _syncOperation = null;
    _persistedRevision = 0;
    isReady = false;
    if (notify) notifyListeners();
    final snapshot = await _repository.load();
    if (snapshot == null) {
      pendingSync = false;
      await _queueLocalSave(_changeRevision);
    } else {
      projects.addAll(snapshot.projects);
      profile = snapshot.profile;
      pendingSync = snapshot.pendingSync;
      pendingDeletes.addAll(snapshot.pendingDeletes);
      _syncOperation = snapshot.syncOperation;
      final storedRevision = snapshot.syncOperation?.revision ?? 0;
      if (storedRevision > _changeRevision) _changeRevision = storedRevision;
      _persistedRevision = _changeRevision;
      if (_syncOperation?.state == 'running') {
        _syncOperation = _syncOperation!.copyWith(
          state: 'pending',
          updatedAt: DateTime.now().toUtc(),
        );
      }
    }
    isReady = true;
    notifyListeners();
    if (_remote.canSync) scheduleSync(delay: Duration.zero);
  }

  void restoreSignupProfile(Map<String, dynamic> metadata, {String? email}) {
    var restored = false;
    void fill(String current, String? value, void Function(String) assign) {
      if (current.trim().isEmpty && value != null && value.trim().isNotEmpty) {
        assign(value.trim());
        restored = true;
      }
    }

    fill(
      profile.name,
      metadata['full_name'] as String?,
      (v) => profile.name = v,
    );
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
    _changeRevision++;
    pendingSync = true;
    final now = DateTime.now().toUtc();
    _syncOperation =
        _syncOperation?.copyWith(
          revision: _changeRevision,
          state: 'pending',
          attemptCount: 0,
          updatedAt: now,
          clearNextAttempt: true,
          clearError: true,
        ) ??
        SyncOperation(
          revision: _changeRevision,
          state: 'pending',
          attemptCount: 0,
          createdAt: now,
          updatedAt: now,
        );
    notifyListeners();
    unawaited(_queueLocalSave(_changeRevision));
    scheduleSync();
  }

  void scheduleSync({Duration delay = const Duration(seconds: 2)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer(delay, () => syncNow(force: false));
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

  void queueFolderDeletion(String folderId) {
    pendingDeletes.add(PendingDelete(table: 'project_sections', id: folderId));
  }

  void deleteProject(AuditProject project) {
    if (project.coverPhoto != null) {
      pendingDeletes.add(
        PendingDelete(
          table: 'projects',
          id: project.id,
          bucket: 'audit-media',
          objectPath: project.coverPhoto!.remotePath,
        ),
      );
    }
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

  Future<void> syncNow({bool force = true}) async {
    if (isSyncing || !_remote.canSync) return;
    await _localWriteChain;
    if (storageError != null || _persistedRevision < _changeRevision) {
      syncError = 'Waiting for this device to save changes safely.';
      notifyListeners();
      return;
    }
    final nextAttemptAt = _syncOperation?.nextAttemptAt;
    if (!force && nextAttemptAt != null) {
      final remaining = nextAttemptAt.difference(DateTime.now().toUtc());
      if (!remaining.isNegative) {
        scheduleSync(delay: remaining);
        return;
      }
    }
    final syncRevision = _changeRevision;
    final deletesForSync = List<PendingDelete>.from(pendingDeletes);
    isSyncing = true;
    syncError = null;
    notifyListeners();
    try {
      if (pendingSync) {
        final now = DateTime.now().toUtc();
        _syncOperation = (_syncOperation ??
                SyncOperation(
                  revision: syncRevision,
                  state: 'pending',
                  attemptCount: 0,
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              revision: syncRevision,
              state: 'running',
              updatedAt: now,
              clearNextAttempt: true,
              clearError: true,
            );
        await _queueLocalSave(syncRevision);
        if (storageError != null) {
          throw StateError('Could not persist the sync queue locally.');
        }
        await _remote.pushSnapshot(projects, profile);
        await _remote.processDeletes(deletesForSync);
        pendingDeletes.removeWhere(
          (candidate) => deletesForSync.any(
            (sent) =>
                sent.table == candidate.table &&
                sent.id == candidate.id &&
                sent.bucket == candidate.bucket &&
                sent.objectPath == candidate.objectPath,
          ),
        );

        // Never pull immediately after an upload. Supabase receives a project
        // tree through several requests, so a read at this point can observe a
        // partial tree and destroy valid local children.
        pendingSync = _changeRevision != syncRevision;
        _syncOperation =
            pendingSync
                ? _syncOperation!.copyWith(
                  revision: _changeRevision,
                  state: 'pending',
                  attemptCount: 0,
                  updatedAt: DateTime.now().toUtc(),
                  clearNextAttempt: true,
                  clearError: true,
                )
                : null;
        await _queueLocalSave(_changeRevision);
      } else {
        // Pulling is safe only when there are no unsent local changes.
        final remote = await _remote.pullSnapshot(
          profile,
          localProjects: projects,
        );
        if (_changeRevision != syncRevision || pendingSync) return;
        projects
          ..clear()
          ..addAll(remote.projects);
        profile = remote.profile;
        await _queueLocalSave(_changeRevision);
      }
    } catch (error) {
      syncError = error.toString();
      if (pendingSync) {
        final now = DateTime.now().toUtc();
        final attempts = (_syncOperation?.attemptCount ?? 0) + 1;
        final seconds = 2 << (attempts > 7 ? 7 : attempts - 1);
        final retryAt = now.add(Duration(seconds: seconds));
        _syncOperation = (_syncOperation ??
                SyncOperation(
                  revision: _changeRevision,
                  state: 'pending',
                  attemptCount: 0,
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              revision: _changeRevision,
              state: 'failed',
              attemptCount: attempts,
              updatedAt: now,
              nextAttemptAt: retryAt,
              lastError: syncError,
            );
        await _queueLocalSave(_changeRevision);
      }
    } finally {
      isSyncing = false;
      notifyListeners();
      if (pendingSync) {
        final retryAt = _syncOperation?.nextAttemptAt;
        final delay = retryAt?.difference(DateTime.now().toUtc());
        scheduleSync(
          delay:
              delay != null && !delay.isNegative
                  ? delay
                  : const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _queueLocalSave(int revision) {
    _localWriteChain = _localWriteChain.then((_) async {
      isSaving = true;
      storageError = null;
      notifyListeners();
      try {
        await _repository.save(
          projects,
          profile,
          pendingSync: pendingSync,
          pendingDeletes: List<PendingDelete>.from(pendingDeletes),
          revision: revision,
          syncOperation: _syncOperation,
        );
        _persistedRevision =
            revision > _persistedRevision ? revision : _persistedRevision;
      } catch (_) {
        storageError = 'Changes are on screen but could not be saved locally.';
      } finally {
        isSaving = false;
        notifyListeners();
      }
    });
    return _localWriteChain;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && pendingSync) {
      scheduleSync(delay: Duration.zero);
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_repository.close());
    super.dispose();
  }
}

class AuditScope extends InheritedNotifier<AuditStore> {
  const AuditScope({super.key, required AuditStore store, required super.child})
    : super(notifier: store);
  static AuditStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuditScope>()!.notifier!;
}
