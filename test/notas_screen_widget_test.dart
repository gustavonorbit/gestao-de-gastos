import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educa_plus/app/providers.dart';
import 'package:educa_plus/ui/screens/lessons/notas_screen.dart';
import 'fakes/fake_nota_repository.dart';
import 'fakes/fake_aluno_repository.dart';
import 'package:educa_plus/domain/repositories/nota_repository.dart';
import 'package:educa_plus/domain/entities/aluno.dart';

void main() {
  testWidgets('Notas screen shows persisted nota.titulo when present', (WidgetTester tester) async {
    // Arrange: fake repositories with a NotaAula that contains a title
    final fakeNota = FakeNotaRepository(
      notaAulaByAulaId: {
        10: NotaAula(aulaId: 10, tipo: 'prova', valorTotal: 5.0, titulo: 'Prova Bimestral'),
      },
      notasAlunoByAulaId: {10: {1: 4.0}},
    );

    final fakeAluno = FakeAlunoRepository(
      alunosByTurmaId: {
        1: [Aluno(id: 1, turmaId: 1, nome: 'Aluno 1')],
      },
    );

    // Build app with providers overridden
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notaRepositoryProvider.overrideWithValue(fakeNota),
          alunoRepositoryProvider.overrideWithValue(fakeAluno),
        ],
        child: MaterialApp(
          home: NotasScreen(aulaId: 10, turmaId: 1),
        ),
      ),
    );

    // Wait for async loads
    await tester.pumpAndSettle();

    // Assert: the screen renders the persisted nota title (may appear in
    // both the AppBar and the editable TextField). We only require it to be
    // present in the widget tree.
    expect(find.text('Prova Bimestral'), findsWidgets);
  });
}
