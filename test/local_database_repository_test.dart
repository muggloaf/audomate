import 'dart:typed_data';

import 'package:audit_app/src/local_database.dart';
import 'package:audit_app/src/local_repository.dart';
import 'package:audit_app/src/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'relational store preserves the complete offline project graph',
    () async {
      final database = AudomateDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalRepository(database: database);
      final root = AuditFolder(name: 'Building 1', kind: 'Building');
      final emptyFlat = AuditFolder(
        name: 'Flat 101',
        kind: 'Flat',
        parentId: root.id,
      );
      final room = SpaceAudit(
        name: 'Future bedroom',
        section: emptyFlat.name,
        sectionId: emptyFlat.id,
      );
      final photo = PhotoData(
        name: 'cover.jpg',
        bytes: Uint8List.fromList([9, 8, 7]),
      );
      final project = AuditProject(
        number: 'DB-1',
        name: 'Database project',
        site: 'Pune',
        createdAt: DateTime(2026, 9, 16),
        spaces: [room],
        folders: [root, emptyFlat],
        coverPhoto: photo,
        projectType: 'society',
      );
      final profile = EngineerProfile(name: 'Engineer');

      await repository.save(
        [project],
        profile,
        pendingSync: true,
        pendingDeletes: const [PendingDelete(table: 'spaces', id: 'old-room')],
      );
      final restored = await repository.load();

      expect(restored, isNotNull);
      expect(restored!.projects.single.folders.length, 2);
      expect(restored.projects.single.spaces.single.name, 'Future bedroom');
      expect(restored.projects.single.spaces.single.isComplete, isFalse);
      expect(restored.projects.single.coverPhoto!.bytes, [9, 8, 7]);
      expect(restored.pendingSync, isTrue);
      expect(restored.pendingDeletes.single.id, 'old-room');
    },
  );
}
