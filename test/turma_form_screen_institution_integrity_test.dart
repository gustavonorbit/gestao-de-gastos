import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/ui/screens/classes/turma_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/app/providers.dart' show turmaRepositoryProvider;

class _FakeTurmaRepo implements TurmaRepository {
  final List<Turma> _turmas;

  _FakeTurmaRepo(this._turmas);

  @override
  Future<List<Turma>> getAll({bool? onlyActive}) async {
    if (onlyActive == null) return _turmas;
    return _turmas.where((t) => t.ativa == onlyActive).toList();
  }

  @override
  Future<Turma?> getById(int id) async {
    for (final t in _turmas) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<int> create(Turma turma) async => (turma.id ?? 1);

  @override
  Future<void> update(Turma turma) async {}

  @override
  Future<void> deactivate(int id) async {}
  // Trash-related stubs
  @override
  Future<List<Turma>> getDeleted() async => _turmas.where((t) => t.isDeleted).toList();

  @override
  Future<void> moveToTrash(int id) async {}

  @override
  Future<void> restoreFromTrash(int id) async {}

  @override
  Future<void> deletePermanently(int id) async {}
}

void main() {
  testWidgets('Institution field is not auto-populated by serie/letra changes',
      (tester) async {
    const turma = Turma(
      id: 1,
      nome: 'Escola Antiga 7º B',
      disciplina: 'Matemática',
      anoLetivo: 7,
      ativa: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          turmaRepositoryProvider
              .overrideWithValue(_FakeTurmaRepo(const [turma])),
        ],
        child: MaterialApp(
          home: TurmaFormScreen(turmaId: turma.id),
        ),
      ),
    );

    // Let the screen load the turma.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // In edit mode, institution should start pre-filled to reduce handling.
    expect(find.widgetWithText(TextFormField, 'Escola Antiga'), findsOneWidget);

    // User types institution.
    final instituicaoField = find.byType(TextFormField).first;
    await tester.enterText(instituicaoField, 'Minha Instituição');
    await tester.pump();

    // Change serie dropdown.
    await tester.tap(find.text('7º'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('8º').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Change letra dropdown.
    await tester.tap(find.text('B'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('C').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Ensure typed institution is still there and unchanged.
    expect(find.text('Minha Instituição'), findsOneWidget);
  });

  testWidgets('Removing a pending student shows SnackBar feedback',
      (tester) async {
    void Function(List<String> names)? setPendingNames;

    void bind(void Function(List<String> names) setter) {
      setPendingNames = setter;
    }

    await tester.binding.setSurfaceSize(const Size(800, 1000));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TurmaFormScreen(
            debugBindPendingStudentsSetter: bind,
          ),
        ),
      ),
    );

    expect(setPendingNames, isNotNull);

    // Inject pending names via debug hook.
    setPendingNames!(<String>['Ana', 'Bruno']);
    await tester.pump();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);

    // Tap remove on the first row.
    await tester.tap(find.byTooltip('Remover').first);
    await tester.pump();

    // SnackBar feedback.
    expect(find.text('"Ana" removido.'), findsOneWidget);
    expect(find.text('Ana'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });
}
