import 'package:educa_plus/domain/entities/aluno.dart';
import 'package:educa_plus/domain/entities/aula.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/domain/repositories/aluno_repository.dart';
import 'package:educa_plus/domain/repositories/aula_repository.dart';
import 'package:educa_plus/domain/repositories/conteudo_repository.dart';
import 'package:educa_plus/domain/repositories/presenca_repository.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/services/aula_csv_export_assembler.dart';

import 'package:flutter_test/flutter_test.dart';

class _FakeAulaRepo implements AulaRepository {
  final Map<int, Aula> aulas;
  _FakeAulaRepo(this.aulas);

  @override
  Future<int> create(Aula aula) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();

  @override
  Future<List<Aula>> getAllForTurma(int turmaId) => throw UnimplementedError();

  @override
  Future<Aula?> getById(int id) async => aulas[id];

  @override
  Future<void> update(Aula aula) => throw UnimplementedError();
}

class _FakeTurmaRepo implements TurmaRepository {
  final Map<int, Turma> turmas;
  _FakeTurmaRepo(this.turmas);

  @override
  Future<int> create(Turma turma) => throw UnimplementedError();

  @override
  Future<void> deactivate(int id) => throw UnimplementedError();

  @override
  Future<List<Turma>> getAll({bool? onlyActive}) async {
    final list = turmas.values.toList();
    if (onlyActive == null) return list;
    return list.where((t) => t.ativa == onlyActive).toList();
  }

  @override
  Future<Turma?> getById(int id) async => turmas[id];

  @override
  Future<void> update(Turma turma) => throw UnimplementedError();
  // Trash-related stubs
  @override
  Future<List<Turma>> getDeleted() async {
    return turmas.values.where((t) => t.isDeleted).toList();
  }

  @override
  Future<void> moveToTrash(int id) async => throw UnimplementedError();

  @override
  Future<void> restoreFromTrash(int id) async => throw UnimplementedError();

  @override
  Future<void> deletePermanently(int id) async => throw UnimplementedError();
}

class _FakeAlunoRepo implements AlunoRepository {
  final Map<int, List<Aluno>> alunosByTurma;
  _FakeAlunoRepo(this.alunosByTurma);

  @override
  Future<void> deactivate(int id) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();

  @override
  Future<List<Aluno>> getAllForTurma(int turmaId,
      {bool onlyActive = true}) async {
    final list = alunosByTurma[turmaId] ?? const <Aluno>[];
    if (!onlyActive) return list;
    return list.where((a) => a.ativo).toList();
  }

  @override
  Future<int> upsertManyByName(int turmaId, List<String> nomes) =>
      throw UnimplementedError();

  @override
  Future<void> updateAluno(
          {required int id,
          required String nome,
          int? numeroChamada,
          bool? ativo}) =>
      throw UnimplementedError();
}

class _FakePresencaRepo implements PresencaRepository {
  final Map<int, List<PresencaRecord>> presencasByAula;
  _FakePresencaRepo(this.presencasByAula);

  @override
  Future<List<PresencaRecord>> getAllForAula(int aulaId) async =>
      presencasByAula[aulaId] ?? const <PresencaRecord>[];

  @override
  Future<void> upsert(
          {required int aulaId,
          required int alunoId,
          required int aulaIndex,
          required bool presente,
          String? justificativa}) =>
      throw UnimplementedError();

  @override
  Future<void> upsertMany(List<PresencaUpsert> entries) =>
      throw UnimplementedError();
}

class _FakeConteudoRepo implements ConteudoRepository {
  final Map<int, List<ConteudoAula>> conteudosByAula;
  _FakeConteudoRepo(this.conteudosByAula);

  @override
  Future<List<ConteudoAula>> getAllForAula(int aulaId) async =>
      conteudosByAula[aulaId] ?? const <ConteudoAula>[];

  @override
  Future<void> replaceForAula(int aulaId, List<String> textos) =>
      throw UnimplementedError();
}

void main() {
  test(
      'assembleForAulaIds monta turmaNome, alunos, presencas (aulaIndex=0) e conteudos',
      () async {
    final aulaRepo = _FakeAulaRepo({
      10: Aula(
          id: 10, turmaId: 1, titulo: 'Aula 10', data: DateTime(2026, 1, 24)),
    });

    final turmaRepo = _FakeTurmaRepo({
      1: const Turma(id: 1, nome: 'Turma A', anoLetivo: 2026),
    });

    final alunoRepo = _FakeAlunoRepo({
      1: const [
        Aluno(id: 1, turmaId: 1, nome: 'Ana', ativo: true),
        Aluno(id: 2, turmaId: 1, nome: 'Bruno', ativo: true),
      ],
    });

    final presencaRepo = _FakePresencaRepo({
      10: [
        PresencaRecord(
            id: 1,
            aulaId: 10,
            alunoId: 1,
            aulaIndex: 0,
            presente: true,
            justificativa: null),
        PresencaRecord(
            id: 2,
            aulaId: 10,
            alunoId: 2,
            aulaIndex: 0,
            presente: false,
            justificativa: 'Médico'),
        // Should be ignored for CSV (aula dupla / tab 2)
        PresencaRecord(
            id: 3,
            aulaId: 10,
            alunoId: 1,
            aulaIndex: 1,
            presente: false,
            justificativa: 'Outra'),
      ],
    });

    final conteudoRepo = _FakeConteudoRepo({
      10: [
        ConteudoAula(aulaId: 10, texto: 'C1'),
        ConteudoAula(aulaId: 10, texto: 'C2'),
      ],
    });

    final assembler = AulaCsvExportAssembler(
      aulaRepository: aulaRepo,
      turmaRepository: turmaRepo,
      alunoRepository: alunoRepo,
      presencaRepository: presencaRepo,
      conteudoRepository: conteudoRepo,
    );

    final assembled = await assembler.assembleForAulaIds([10]);

    expect(assembled.aulas.length, 1);
    expect(assembled.aulas.single.turmaNome, 'Turma A');

    expect(assembled.alunos.map((a) => a.nome).toList(), ['Ana', 'Bruno']);

    // Only aulaIndex = 0
    expect(assembled.presencas.length, 2);

    expect(assembled.conteudosPorAulaId[10], ['C1', 'C2']);
  });

  test('assembleForAulaIds ignora aulaIds inexistentes', () async {
    final assembler = AulaCsvExportAssembler(
      aulaRepository: _FakeAulaRepo({}),
      turmaRepository: _FakeTurmaRepo({}),
      alunoRepository: _FakeAlunoRepo({}),
      presencaRepository: _FakePresencaRepo({}),
      conteudoRepository: _FakeConteudoRepo({}),
    );

    final assembled = await assembler.assembleForAulaIds([999]);
    expect(assembled.aulas, isEmpty);
    expect(assembled.alunos, isEmpty);
  });

  test('quando aulaIds têm múltiplas turmas, lança erro (contrato atual)',
      () async {
    final assembler = AulaCsvExportAssembler(
      aulaRepository: _FakeAulaRepo({
        10: Aula(
            id: 10, turmaId: 1, titulo: 'Aula 10', data: DateTime(2026, 1, 24)),
        11: Aula(
            id: 11, turmaId: 2, titulo: 'Aula 11', data: DateTime(2026, 1, 25)),
      }),
      turmaRepository: _FakeTurmaRepo({
        1: const Turma(id: 1, nome: 'Turma A', anoLetivo: 2026),
        2: const Turma(id: 2, nome: 'Turma B', anoLetivo: 2026),
      }),
      alunoRepository: _FakeAlunoRepo({
        1: const [Aluno(id: 1, turmaId: 1, nome: 'Ana', ativo: true)],
        2: const [Aluno(id: 2, turmaId: 2, nome: 'Bruno', ativo: true)],
      }),
      presencaRepository: _FakePresencaRepo({}),
      conteudoRepository: _FakeConteudoRepo({}),
    );

    expect(() => assembler.assembleForAulaIds([10, 11]), throwsStateError);
  });
}
