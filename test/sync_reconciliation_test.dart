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
  }) async => RemoteSnapshot(projects: const [], profile: localProfile);
}

void main() {
  test(
    'stale cloud pull cannot remove an empty space added during sync',
    () async {
      final directory = await Directory.systemTemp.createTemp('audomate_sync_');
      addTearDown(() => directory.delete(recursive: true));
      final remote = _DelayedRemote();
      final store = AuditStore(
        repository: LocalRepository(file: File('${directory.path}/audit.json')),
        remote: remote,
      );
      addTearDown(store.dispose);
      await store.initialize(userId: 'test-user');
      store.addProject(
        AuditProject(
          number: 'P-1',
          name: 'Project',
          site: 'Site',
          createdAt: DateTime(2026),
          spaces: [],
        ),
      );

      final syncing = store.syncNow();
      await remote.pushStarted.future;
      store.projects.single.folders.add(
        AuditFolder(name: 'Empty building', kind: 'Building'),
      );
      store.changed();
      remote.finishPush.complete();
      await syncing;

      expect(store.projects.single.folders.single.name, 'Empty building');
      expect(store.pendingSync, isTrue);
    },
  );
}
