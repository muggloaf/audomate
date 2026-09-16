import 'package:audit_app/src/app_state.dart';
import 'package:audit_app/src/screens/templates_screen.dart';
import 'package:audit_app/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renaming a space template keeps its detail route intact', (
    tester,
  ) async {
    final store = AuditStore();
    await tester.pumpWidget(
      AuditScope(
        store: store,
        child: MaterialApp(theme: buildTheme(), home: const TemplatesScreen()),
      ),
    );

    await tester.tap(find.text('Housing society'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit space template'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1BHK');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('1BHK'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Suggested rooms'), findsOneWidget);
    store.dispose();
  });
}
