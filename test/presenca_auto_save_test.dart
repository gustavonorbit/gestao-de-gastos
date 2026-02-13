import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/ui/screens/lessons/presenca_screen.dart';
import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider, presencaRepositoryProvider;
import 'package:educa_plus/domain/repositories/presenca_repository.dart';
import 'package:educa_plus/domain/entities/aula.dart' as domain;
import 'package:educa_plus/domain/repositories/aula_repository.dart' as ar;
import 'package:educa_plus/domain/entities/aluno.dart';
import 'package:educa_plus/providers/alunos_provider.dart';

class FakePresencaRepository implements PresencaRepository {
  final List<PresencaRecord> storage = [];
  final List<PresencaUpsert> upsertCalls = [];
  final List<List<PresencaUpsert>> upsertManyCalls = [];

  int _idCounter = 1;

  @override
  Future<void> upsert({required int aulaId, required int alunoId, required int aulaIndex, required bool presente, String? justificativa}) async {
    upsertCalls.add(PresencaUpsert(aulaId: aulaId, alunoId: alunoId, aulaIndex: aulaIndex, presente: presente, justificativa: justificativa));
    // simulate persistence
    final idx = storage.indexWhere((r) => r.aulaId == aulaId && r.alunoId == alunoId && r.aulaIndex == aulaIndex);
    if (idx >= 0) {
      storage[idx] = PresencaRecord(id: storage[idx].id, aulaId: aulaId, alunoId: alunoId, aulaIndex: aulaIndex, presente: presente, justificativa: justificativa);
    } else {
      storage.add(PresencaRecord(id: _idCounter++, aulaId: aulaId, alunoId: alunoId, aulaIndex: aulaIndex, presente: presente, justificativa: justificativa));
    }
    return;
  }

  @override
  Future<void> upsertMany(List<PresencaUpsert> entries) async {
    upsertManyCalls.add(entries);
    for (final e in entries) {
      await upsert(aulaId: e.aulaId, alunoId: e.alunoId, aulaIndex: e.aulaIndex, presente: e.presente, justificativa: e.justificativa);
    }
    return;
  }

  @override
  Future<List<PresencaRecord>> getAllForAula(int aulaId) async {
    return storage.where((r) => r.aulaId == aulaId).toList(growable: false);
  }
}

class _FakeAulaRepository implements ar.AulaRepository {
  final domain.Aula aula;
  _FakeAulaRepository(this.aula);

  @override
  Future<int> create(domain.Aula aula) async => aula.id ?? 1;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<domain.Aula>> getAllForTurma(int turmaId) async => [aula];

  @override
  Future<domain.Aula?> getById(int id) async => aula;

  @override
  Future<void> update(domain.Aula aula) async {}
}

void main() {
  testWidgets('auto-save on toggle calls presencaRepository.upsert', (tester) async {
    final fakePres = FakePresencaRepository();

    final aula = domain.Aula(
      id: 10,
      turmaId: 1,
      titulo: 'Aula dupla',
      data: DateTime(2026, 2, 3),
      tipo: domain.AulaTipo.dupla,
      duracaoMinutos: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aulaRepositoryProvider.overrideWithValue(_FakeAulaRepository(aula)),
          presencaRepositoryProvider.overrideWithValue(fakePres),
          alunosByTurmaProvider(1).overrideWith((ref) async => const [
                Aluno(id: 1, turmaId: 1, nome: 'Aluno 1'),
              ]),
        ],
        child: const MaterialApp(home: PresencaScreen(turmaId: 1, aulaId: 10, turmaName: 'Turma')),
      ),
    );

    // resolve providers
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Initially no persistence calls
    expect(fakePres.upsertCalls, isEmpty);

    // Tap the switch for the student
    final sw = find.byType(Switch).first;
    await tester.tap(sw);
    // allow async upsert to complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(fakePres.upsertCalls.length, 1);
    final call = fakePres.upsertCalls.first;
    expect(call.aulaId, 10);
    expect(call.alunoId, 1);
    // default tab index should be 0 when tapping in the visible tab (Aula 1)
    expect(call.aulaIndex, anyOf(0, 1));
  });

  testWidgets('copy Aula1->Aula2 uses upsertMany and shows success feedback', (tester) async {
    final fakePres = FakePresencaRepository();

    final aula = domain.Aula(
      id: 20,
      turmaId: 2,
      titulo: 'Aula dupla',
      data: DateTime(2026, 2, 3),
      tipo: domain.AulaTipo.dupla,
      duracaoMinutos: 2,
    );

    // Pre-populate storage with presenças for aulaIndex=0
    fakePres.storage.addAll([
      PresencaRecord(id: 1, aulaId: 20, alunoId: 10, aulaIndex: 0, presente: true, justificativa: null),
      PresencaRecord(id: 2, aulaId: 20, alunoId: 11, aulaIndex: 0, presente: false, justificativa: 'Motivo'),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aulaRepositoryProvider.overrideWithValue(_FakeAulaRepository(aula)),
          presencaRepositoryProvider.overrideWithValue(fakePres),
          alunosByTurmaProvider(2).overrideWith((ref) async => const [
                Aluno(id: 10, turmaId: 2, nome: 'A'),
                Aluno(id: 11, turmaId: 2, nome: 'B'),
              ]),
        ],
        child: const MaterialApp(home: PresencaScreen(turmaId: 2, aulaId: 20, turmaName: 'Turma')),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap the copy button (arrow_forward)
    final btn = find.byIcon(Icons.arrow_forward);
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // upsertMany should have been called once
    expect(fakePres.upsertManyCalls.length, 1);
    final entries = fakePres.upsertManyCalls.first;
    expect(entries.length, 2);
    for (final e in entries) {
      expect(e.aulaIndex, 1);
      expect(e.aulaId, 20);
    }

    // SnackBar feedback
    expect(find.text('Presenças da Aula 1 copiadas para a Aula 2.'), findsOneWidget);
  });
}
