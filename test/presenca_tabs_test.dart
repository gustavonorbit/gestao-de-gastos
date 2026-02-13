import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/ui/screens/lessons/presenca_screen.dart';
import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;
import 'package:educa_plus/domain/entities/aula.dart' as domain;
import 'package:educa_plus/domain/repositories/aula_repository.dart';

import 'package:educa_plus/domain/entities/aluno.dart';
import 'package:educa_plus/providers/alunos_provider.dart';

void main() {
  testWidgets('Presença dupla mostra abas Aula 1 e Aula 2', (tester) async {
    final fakeRepo = _FakeAulaRepository(
      domain.Aula(
        id: 1,
        turmaId: 1,
        titulo: 'Aula',
        data: DateTime(2026, 1, 24),
        tipo: domain.AulaTipo.dupla,
        duracaoMinutos: 2,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aulaRepositoryProvider.overrideWithValue(fakeRepo),
          alunosByTurmaProvider(1).overrideWith(
            (ref) async => const [
              Aluno(id: 1, turmaId: 1, nome: 'Aluno 1', ativo: true),
            ],
          ),
        ],
        child: const MaterialApp(
          home: PresencaScreen(
            turmaId: 1,
            aulaId: 1,
            turmaName: 'Escola X • 1º A',
          ),
        ),
      ),
    );

    // Resolve the FutureProvider.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Presença'), findsOneWidget);
    expect(find.text('Aula 1'), findsOneWidget);
    expect(find.text('Aula 2'), findsOneWidget);
  });

  testWidgets('Presença individual mostra somente Aula 1', (tester) async {
    final fakeRepo = _FakeAulaRepository(
      domain.Aula(
        id: 1,
        turmaId: 1,
        titulo: 'Aula',
        data: DateTime(2026, 1, 24),
        tipo: domain.AulaTipo.individual,
        duracaoMinutos: 1,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aulaRepositoryProvider.overrideWithValue(fakeRepo),
          alunosByTurmaProvider(1).overrideWith(
            (ref) async => const [
              Aluno(id: 1, turmaId: 1, nome: 'Aluno 1', ativo: true),
            ],
          ),
        ],
        child: const MaterialApp(
          home: PresencaScreen(
            turmaId: 1,
            aulaId: 1,
            turmaName: 'Escola X • 1º A',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Presença'), findsOneWidget);
    expect(find.text('Aula 1'), findsOneWidget);
    expect(find.text('Aula 2'), findsNothing);
  });
}

class _FakeAulaRepository implements AulaRepository {
  domain.Aula? _aula;

  _FakeAulaRepository(this._aula);

  @override
  Future<int> create(domain.Aula aula) async {
    _aula = aula;
    return aula.id ?? 1;
  }

  @override
  Future<void> delete(int id) async {
    if (_aula?.id == id) _aula = null;
  }

  @override
  Future<List<domain.Aula>> getAllForTurma(int turmaId) async {
    final a = _aula;
    if (a == null) return [];
    if (a.turmaId != turmaId) return [];
    return [a];
  }

  @override
  Future<domain.Aula?> getById(int id) async {
    final a = _aula;
    if (a == null) return null;
    if ((a.id ?? id) != id) return null;
    return a;
  }

  @override
  Future<void> update(domain.Aula aula) async {
    _aula = aula;
  }
}
