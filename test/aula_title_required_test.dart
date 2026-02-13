import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educa_plus/ui/screens/lessons/list_lessons_screen.dart';

void main() {
  testWidgets('Creating an aula without title shows error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ListLessonsScreen(turmaId: 1, turmaName: 'Turma Teste'),
        ),
      ),
    );

  // Open "Nova Aula" dialog via bottom button.
  await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar aula'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Aula'), findsOneWidget);

    // Try to save without filling the title.
    await tester.tap(find.text('Salvar aula'));
    await tester.pump();

    // Shows inline validation error inside the dialog.
    expect(find.text('Informe um título para a aula.'), findsOneWidget);

    // And it should not show the blocking progress indicator.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
