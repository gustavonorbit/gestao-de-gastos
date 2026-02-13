import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/screens/classes/turma_form_screen.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/domain/repositories/aluno_repository.dart';
import 'package:educa_plus/app/providers.dart'
    show turmaRepositoryProvider, alunoRepositoryProvider, dbProvider;
import 'package:educa_plus/data/database.dart' show AppDatabase;
import 'package:educa_plus/domain/entities/aluno.dart' show Aluno;
import 'package:drift/native.dart';

class FakeTurmaRepository implements TurmaRepository {
  bool createCalled = false;
  bool updateCalled = false;
  Turma? createdTurma;

  @override
  Future<int> create(Turma turma) async {
    createCalled = true;
    // store and return id 1
    createdTurma = turma.copyWith(id: 1);
    return 1;
  }

  @override
  Future<void> deactivate(int id) async {
    // noop
  }

  @override
  Future<List<Turma>> getAll({bool? onlyActive = true}) async {
    if (createdTurma == null) return [];
    return [createdTurma!];
  }

  @override
  Future<Turma?> getById(int id) async {
    if (createdTurma != null && createdTurma!.id == id) return createdTurma;
    return null;
  }

  @override
  Future<void> update(Turma turma) async {
    updateCalled = true;
    createdTurma = turma;
  }
  // Trash-related stubs
  @override
  Future<List<Turma>> getDeleted() async => [];

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

  // The rest of the interface methods are not needed for this test.
  @override
  Future<List<Aluno>> getAllForTurma(int turmaId, {bool onlyActive = true}) async => <Aluno>[];

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> deactivate(int id) async {}
}

void main() {
  testWidgets('Creating turma blocked when form invalid', (tester) async {
    final fakeTurmaRepo = FakeTurmaRepository();
    final fakeAlunoRepo = FakeAlunoRepository();

    // Increase test window to avoid layout overflows and reuse a single in-memory DB.
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    final db = AppDatabase.test(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          turmaRepositoryProvider.overrideWithValue(fakeTurmaRepo),
          alunoRepositoryProvider.overrideWithValue(fakeAlunoRepo),
          dbProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(home: TurmaFormScreen(turmaId: null)),
      ),
    );

    await tester.pumpAndSettle();

    // Do not fill required fields. Tap Save.
  final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
  expect(saveButton, findsOneWidget);
  await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Create should not be called because form is invalid.
    expect(fakeTurmaRepo.createCalled, isFalse);
  });

  testWidgets('Allow saving students after initial create even if form invalid', (tester) async {
    final fakeTurmaRepo = FakeTurmaRepository();
    final fakeAlunoRepo = FakeAlunoRepository();

    // Increase test window to avoid layout overflows and reuse a single in-memory DB.
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    final db = AppDatabase.test(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          turmaRepositoryProvider.overrideWithValue(fakeTurmaRepo),
          alunoRepositoryProvider.overrideWithValue(fakeAlunoRepo),
          dbProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(home: TurmaFormScreen(turmaId: null)),
      ),
    );

    await tester.pumpAndSettle();

  // Fill required fields: instituicao, serie, letra
  // The first TextFormField is the institution field.
  await tester.enterText(find.byType(TextFormField).first, 'Escola X');
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    // Select first serie '1º'
    await tester.tap(find.text('1º').last);
    await tester.pumpAndSettle();
    // Select letter 'A' in the second dropdown
    final dropdowns = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A').last);
    await tester.pumpAndSettle();

    // Add pending students manually via the UI: tap '+' -> 'Digitar manualmente'
    // to append an empty row, then enter names.
    // Find and tap the add button.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    // Choose manual entry.
    await tester.tap(find.text('Digitar manualmente'));
    await tester.pumpAndSettle();

    // Enter two names into the pending list (fields are TextField widgets).
    await tester.enterText(find.byType(TextField).last, 'Alice');
    await tester.pumpAndSettle();
    // Add another manual row.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Digitar manualmente'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Bob');
    await tester.pumpAndSettle();

    // Save (first create)
  await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(fakeTurmaRepo.createCalled, isTrue);
    expect(fakeAlunoRepo.upsertCalled, isTrue);

    // Now reopen in edit mode (simulate navigation to edit)
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          turmaRepositoryProvider.overrideWithValue(fakeTurmaRepo),
          alunoRepositoryProvider.overrideWithValue(fakeAlunoRepo),
          dbProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(home: TurmaFormScreen(turmaId: 1)),
      ),
    );

    await tester.pumpAndSettle();

    // Make the form invalid by clearing the institution field
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.pumpAndSettle();

    // Inject another pending name via the same manual + entry flow.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Digitar manualmente'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Carlos');
    await tester.pumpAndSettle();

    // Save: form is invalid, but turma exists; students should be saved,
    // and repository.update should NOT be called.
    fakeTurmaRepo.updateCalled = false;
    fakeAlunoRepo.upsertCalled = false;

  await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(fakeAlunoRepo.upsertCalled, isTrue, reason: 'Students should be upserted');
    expect(fakeTurmaRepo.updateCalled, isFalse, reason: 'Turma update must not be called when form invalid');
  });
}
