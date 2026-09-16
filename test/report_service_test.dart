import 'package:audit_app/src/models.dart';
import 'package:audit_app/src/report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a report with the branded audomate wordmark', () async {
    final room = SpaceAudit(
      id: 'room-101',
      name: 'Bathroom',
      section: 'Flat 101',
      sectionId: 'flat-101',
    )..noIssues = true;
    final bytes = await ReportService.build(
      AuditProject(
        number: 'PDF-1',
        name: 'PDF test',
        site: 'Pune',
        createdAt: DateTime(2026, 9, 16),
        spaces: [room],
        folders: [
          AuditFolder(id: 'building-a', name: 'Building A', kind: 'Building'),
          AuditFolder(
            id: 'floor-1',
            name: 'Floor 1',
            kind: 'Floor',
            parentId: 'building-a',
          ),
          AuditFolder(
            id: 'flat-101',
            name: 'Flat 101',
            kind: 'Flat',
            parentId: 'floor-1',
          ),
        ],
      ),
      EngineerProfile(organisation: 'Test Engineers'),
    );

    expect(bytes.length, greaterThan(1000));
  });
}
