import 'dart:async';
import 'dart:io';

import 'package:audit_app/src/app_state.dart';
import 'package:audit_app/src/local_repository.dart';
import 'package:audit_app/src/models.dart';
import 'package:audit_app/src/supabase_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _DelayedRemote extends SupabaseRepository {
  final pushStarted = Completer<void>();
  final finishPush = Completer<void>();
  var pullCalls = 0;

  @override
  bool get canSync => true;

  @override
  Future<void> pushSnapshot(
    List<AuditProject> projects,
    EngineerProfile profile,
  ) async {
    pushStarted.complete();
    await finishPush.future;
  }

  @override
  Future<void> processDeletes(List<PendingDelete> operations) async {}

  @override
  Future<RemoteSnapshot> pullSnapshot(
    EngineerProfile localProfile, {
    List<AuditProject> localProjects = const [],
  }) async {
    pullCalls++;
    return RemoteSnapshot(projects: const [], profile: localProfile);
  }
}

class _FailingRemote extends SupabaseRepository {
  @override
  bool get canSync => true;

  @override
  Future<void> pushSnapshot(
    List<AuditProject> projects,
    EngineerProfile profile,
  ) => Future<void>.error(StateError('offline'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'stale cloud pull cannot remove an empty space added during sync',
    () async {
      final directory = await Directory.systemTemp.createTemp('audomate_sync_');
      addTearDown(() => directory.delete(recursive: true));
      final remote = _DelayedRemote();
      final repository = LocalRepository(
        file: File('${directory.path}/audit.json'),
      );
      final store = AuditStore(
        repository: repository,
        remote: remote,
      );
      addTearDown(store.dispose);
      await store.initialize(userId: 'test-user');
      final root = AuditFolder(name: 'Building 1', kind: 'Building');
      final flat = AuditFolder(
        name: 'Flat 101',
        kind: 'Flat',
        parentId: root.id,
      );
      store.addProject(
        AuditProject(
          number: 'P-1',
          name: 'Project',
          site: 'Site',
          createdAt: DateTime(2026),
          folders: [root, flat],
          spaces: [
            SpaceAudit(
              name: 'Bedroom',
              section: flat.name,
              sectionId: flat.id,
            ),
          ],
        ),
      );

      final syncing = store.syncNow();
      await remote.pushStarted.future;
      final committedBeforeUploadFinished = await repository.load();
      expect(committedBeforeUploadFinished!.projects.single.folders.length, 2);
      expect(committedBeforeUploadFinished.projects.single.spaces.length, 1);
      store.projects.single.folders.add(
        AuditFolder(name: 'Empty building', kind: 'Building'),
      );
      store.changed();
      remote.finishPush.complete();
      await syncing;

      expect(
        store.projects.single.folders.any(
          (folder) => folder.name == 'Empty building',
        ),
        isTrue,
      );
      expect(store.projects.single.spaces.single.name, 'Bedroom');
      expect(store.pendingSync, isTrue);
      expect(remote.pullCalls, 0);
    },
  );

  test('failed online sync remains durably queued for retry', () async {
    final directory = await Directory.systemTemp.createTemp('audomate_retry_');
    addTearDown(() => directory.delete(recursive: true));
    final repository = LocalRepository(
      file: File('${directory.path}/audit.json'),
    );
    final store = AuditStore(repository: repository, remote: _FailingRemote());
    addTearDown(store.dispose);
    await store.initialize(userId: 'test-user');
    store.addProject(
      AuditProject(
        number: 'P-2',
        name: 'Retry project',
        site: 'Site',
        createdAt: DateTime(2026),
        spaces: [],
      ),
    );

    await store.syncNow();
    final snapshot = await repository.load();

    expect(snapshot!.pendingSync, isTrue);
    expect(snapshot.syncOperation, isNotNull);
    expect(snapshot.syncOperation!.state, 'failed');
    expect(snapshot.syncOperation!.attemptCount, 1);
    expect(snapshot.projects.single.name, 'Retry project');
  });
}
