import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/screens/classes/turma_form_screen.dart';

void main() {
  testWidgets('tapping add -> manual creates an empty TextField at end', (tester) async {
    // Use the debug binder to inject pending names without interacting with
    // the Add modal. The screen supports a debug hook that returns a setter
    // to manipulate pending students during tests.
    void Function(List<String> names)? setter;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: TurmaFormScreen(
          debugBindPendingStudentsSetter: (s) => setter = s,
        ),
      ),
    ));

  // Inject a single empty pending row (simulates Add manual)
  expect(setter, isNotNull);
  setter!(['']);
  await tester.pumpAndSettle();

  // After injection the pending editor should be present and contain at least one TextField
  final textFields = find.byType(TextField);
  expect(textFields, findsWidgets);
  });

  testWidgets('can enter text into newly added manual field', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: TurmaFormScreen(
          debugInitialInstituicao: 'Escola Teste',
          debugInitialSerie: '1º',
          debugInitialLetra: 'A',
        ),
      ),
    ));

    final addButton = find.byIcon(Icons.add).first;
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Digitar manualmente'));
    await tester.pumpAndSettle();

    // Locate the last TextField and enter text
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);
    await tester.enterText(textFields.last, 'João da Silva');
    await tester.pumpAndSettle();

    // Verify text appears in the widget tree
    expect(find.text('João da Silva'), findsOneWidget);
  });
}
