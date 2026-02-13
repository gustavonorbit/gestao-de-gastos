import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/ui/screens/classes/turma_form_screen.dart';

// We'll create a small fake to simulate OCR import by calling the debug
// binding to inject pending names directly, since ImagePicker and MLKit are
// heavy to mock in a widget test environment.

void main() {
  testWidgets('Importing students marks form as dirty', (tester) async {
    // Build the TurmaFormScreen in create mode and capture the setter.
    // The widget will provide a setter `void Function(List<String>)` via the
    // debugBindPendingStudentsSetter callback.
    void Function(List<String> names)? binder;

    await tester.pumpWidget(
      MaterialApp(
        home: TurmaFormScreen(
          turmaId: null,
          debugBindPendingStudentsSetter: (setPending) {
            binder = setPending;
          },
        ),
      ),
    );

    // Ensure the widget is built.
    await tester.pumpAndSettle();

    expect(binder, isNotNull, reason: 'debug binder must be provided');

    // Simulate an OCR import by calling the setter with names. This replaces
    // the internal pending names list inside the screen.
    binder!(['Maria Silva', 'Joao Souza']);

    // Pump to apply setState in the screen.
    await tester.pumpAndSettle();

    // Now try to pop the route; since the form should be dirty, a dialog
    // asking for confirmation should be shown.
    // Use tester.state to find the PopScope and call the onPop callback, but
    // simpler: try to tap the back button in the AppBar (which triggers pop).

    // Tap system back via Navigator.maybePop.
  // Attempt to pop the route which should cause the discard dialog to
  // appear because the form is dirty.
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

    expect(find.text('Alterações não salvas'), findsOneWidget,
        reason: 'Dirty form should show discard confirmation dialog when trying to pop');
  });
}
