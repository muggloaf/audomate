import 'dart:io';
import 'dart:typed_data';

import 'package:audit_app/src/local_repository.dart';
import 'package:audit_app/src/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips a complete offline audit snapshot', () async {
    final directory = await Directory.systemTemp.createTemp('structura_test_');
    addTearDown(() => directory.delete(recursive: true));
    final repository = LocalRepository(
      file: File('${directory.path}${Platform.pathSeparator}audit.json'),
    );
    final photo = PhotoData(
      name: 'crack.jpg',
      bytes: Uint8List.fromList([1, 2, 3, 4]),
    );
    final space =
        SpaceAudit(name: 'Room 101', section: 'A Wing', owner: 'Resident')
          ..inspectedAt = DateTime(2026, 9, 14, 10, 30)
          ..findings.add(
            Finding(
              type: issueTypes[1],
              location: locations[0],
              severity: severities[0],
              notes: 'Diagonal crack.',
              recommendation: 'Monitor and repair.',
              photos: [photo],
            ),
          );
    final project = AuditProject(
      number: 'SA-001',
      name: 'Test Society',
      site: 'Pune',
      createdAt: DateTime(2026, 9, 14),
      spaces: [space],
      coverPhoto: photo,
    );
    final profile = EngineerProfile(name: 'Engineer', signature: photo);

    await repository.save([project], profile);
    final restored = await repository.load();

    expect(restored, isNotNull);
    expect(restored!.projects.single.name, 'Test Society');
    expect(
      restored.projects.single.spaces.single.findings.single.notes,
      'Diagonal crack.',
    );
    expect(
      restored
          .projects
          .single
          .spaces
          .single
          .findings
          .single
          .photos
          .single
          .bytes,
      [1, 2, 3, 4],
    );
    expect(restored.profile.name, 'Engineer');
    expect(restored.profile.signature!.name, 'crack.jpg');
  });
}
