import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/screens/classes/turma_form_screen.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/domain/repositories/aluno_repository.dart';
import 'package:educa_plus/domain/entities/aluno.dart';
import 'package:educa_plus/app/providers.dart' show turmaRepositoryProvider, alunoRepositoryProvider, dbProvider;
import 'package:educa_plus/data/database.dart' show AppDatabase;
import 'package:drift/native.dart';

class FakeTurmaRepository implements TurmaRepository {
  bool createCalled = false;
  bool updateCalled = false;
  Turma? createdTurma;

  @override
  Future<int> create(Turma turma) async {
    createCalled = true;
    createdTurma = turma.copyWith(id: 1);
    return 1;
  }

  @override
  Future<void> deactivate(int id) async {}

  @override
  Future<List<Turma>> getAll({bool? onlyActive = true}) async => createdTurma == null ? [] : [createdTurma!];

  @override
  Future<Turma?> getById(int id) async => createdTurma?.id == id ? createdTurma : null;

  @override
  Future<void> update(Turma turma) async {
    updateCalled = true;
    createdTurma = turma;
  }
  // Trash-related stubs
  @override
  Future<List<Turma>> getDeleted() async => createdTurma == null ? [] : [createdTurma!];

  @override
  Future<void> moveToTrash(int id) async {}

  @override
  Future<void> restoreFromTrash(int id) async {}

  @override
  Future<void> deletePermanently(int id) async {}
}

class FakeAlunoRepository implements AlunoRepository {
  bool upsertCalled = false;
  bool updateAlunoCalled = false;
  int lastUpsertTurmaId = -1;
  List<String> lastUpsertNames = [];

  @override
  Future<int> upsertManyByName(int turmaId, List<String> nomes) async {
    upsertCalled = true;
    lastUpsertTurmaId = turmaId;
    lastUpsertNames = List<String>.from(nomes);
    return nomes.length;
  }

  @override
  Future<void> updateAluno({required int id, required String nome, int? numeroChamada, bool? ativo}) async {
    updateAlunoCalled = true;
  }

  @override
  Future<List<Aluno>> getAllForTurma(int turmaId, {bool onlyActive = true}) async => <Aluno>[];

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> deactivate(int id) async {}
}

void main() {
  testWidgets('When turma exists and form invalid, only students are persisted and turma.update is not called', (tester) async {
    final fakeTurmaRepo = FakeTurmaRepository();
    final fakeAlunoRepo = FakeAlunoRepository();
    final db = AppDatabase.test(NativeDatabase.memory());

    // Simulate an existing turma in the repository with id=1.
    fakeTurmaRepo.createdTurma = Turma(id: 1, nome: 'Escola X 1º A', anoLetivo: 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          turmaRepositoryProvider.overrideWithValue(fakeTurmaRepo),
          alunoRepositoryProvider.overrideWithValue(fakeAlunoRepo),
          dbProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: TurmaFormScreen(
            turmaId: 1,
            debugBindPendingStudentsSetter: (setPending) {
              // Inject pending names as if imported by OCR.
              setPending(['Student One', 'Student Two']);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Make the form invalid by clearing the institution field (first TextFormField).
    final firstField = find.byType(TextFormField).first;
    await tester.enterText(firstField, '');
    await tester.pumpAndSettle();

  // Tap the Save button to trigger _save().
  final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
  expect(saveButton, findsOneWidget);
  await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Assertions: students should have been upserted; turma update must not be called.
    expect(fakeAlunoRepo.upsertCalled, isTrue, reason: 'Students should be upserted');
    expect(fakeTurmaRepo.updateCalled, isFalse, reason: 'Turma.update must not be called when form invalid');
  });
}
