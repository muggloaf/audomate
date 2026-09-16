import 'package:audit_app/src/app_state.dart';
import 'package:audit_app/src/models.dart';
import 'package:audit_app/src/screens/home_shell.dart';
import 'package:audit_app/src/theme.dart';
import 'package:audit_app/src/widgets/brand_wordmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the audit dashboard', (tester) async {
    final store = AuditStore();
    store.projects.add(
      AuditProject(
        number: 'SA-001',
        name: 'Test Society',
        site: 'Pune',
        createdAt: DateTime(2026, 9, 14),
        spaces: [SpaceAudit(name: 'Room 1', section: 'A Wing')],
      ),
    );
    await tester.pumpWidget(
      AuditScope(
        store: store,
        child: MaterialApp(theme: buildTheme(), home: const HomeShell()),
      ),
    );
    expect(find.byType(BrandWordmark), findsOneWidget);
    expect(find.text('audomate.', findRichText: true), findsOneWidget);
    expect(find.text('New project'), findsOneWidget);
    expect(find.text('Test Society'), findsOneWidget);
  });
}
