import 'package:flutter_test/flutter_test.dart';

import 'package:educa_plus/domain/entities/aluno.dart';
import 'package:educa_plus/domain/repositories/nota_repository.dart';
import 'package:educa_plus/ui/screens/lessons/notas_controller.dart';

import 'fakes/fake_aluno_repository.dart';
import 'fakes/fake_nota_repository.dart';

void main() {
  group('NotasController (regressivo)', () {
    test(
        '1) Carregamento inicial sem dados: default + nulls + houveAlteracao=false',
        () async {
      final alunoRepo = FakeAlunoRepository(
        alunosByTurmaId: {
          1: const [
            Aluno(id: 1, turmaId: 1, nome: 'Ana'),
            Aluno(id: 2, turmaId: 1, nome: 'Bruno'),
          ],
        },
      );
      final notaRepo = FakeNotaRepository();

      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: alunoRepo,
        notaRepository: notaRepo,
      );

      await c.loadInitial();

      expect(c.tipoEditado, NotaTipo.avaliacao); // default
      expect(c.valorTotalEditado, isNull);
      expect(c.notaAlunoEditada(1), isNull);
      expect(c.notaAlunoEditada(2), isNull);
      expect(c.houveAlteracao, isFalse);
    });

    test('2) Carregamento com dados existentes: carrega sem sujar', () async {
      final alunoRepo = FakeAlunoRepository(
        alunosByTurmaId: {
          1: const [
            Aluno(id: 1, turmaId: 1, nome: 'Ana'),
            Aluno(id: 2, turmaId: 1, nome: 'Bruno'),
          ],
        },
      );

      final notaRepo = FakeNotaRepository(
        notaAulaByAulaId: {
          10: NotaAula(
              aulaId: 10, tipo: 'prova', valorTotal: 5.0, titulo: null),
        },
        notasAlunoByAulaId: {
          10: {
            2: 4.5,
          },
        },
      );

      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: alunoRepo,
        notaRepository: notaRepo,
      );

      await c.loadInitial();

      expect(c.tipoEditado, NotaTipo.prova);
      expect(c.valorTotalEditado, 5.0);
      expect(c.notaAlunoEditada(1), isNull);
      expect(c.notaAlunoEditada(2), 4.5);
      expect(c.houveAlteracao, isFalse);
    });

    test('3) Alterar tipo: muda editado, mantém original, e marca dirty',
        () async {
      final alunoRepo = FakeAlunoRepository(alunosByTurmaId: {1: const []});
      final notaRepo = FakeNotaRepository(
        notaAulaByAulaId: {
          10: NotaAula(
              aulaId: 10, tipo: 'avaliacao', valorTotal: null, titulo: null),
        },
      );

      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: alunoRepo,
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      expect(c.tipoOriginal, NotaTipo.avaliacao);
      c.setTipo(NotaTipo.trabalho);

      expect(c.tipoEditado, NotaTipo.trabalho);
      expect(c.tipoOriginal, NotaTipo.avaliacao);
      expect(c.houveAlteracao, isTrue);
    });

    test('4) Alterar valor total: reflete no editado e marca dirty', () async {
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: FakeNotaRepository(),
      );
      await c.loadInitial();

      c.setValorTotal(2.0);
      expect(c.valorTotalEditado, 2.0);
      expect(c.houveAlteracao, isTrue);
    });

    test('5) Lançar nota para aluno: só no editado, original intacto, dirty',
        () async {
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: FakeNotaRepository(
          notasAlunoByAulaId: {
            10: {1: 1.0},
          },
        ),
      );
      await c.loadInitial();

      expect(c.notaAlunoOriginal(1), 1.0);
      expect(c.notaAlunoEditada(1), 1.0);

      c.setNotaAluno(1, 1.5);
      expect(c.notaAlunoEditada(1), 1.5);
      expect(c.notaAlunoOriginal(1), 1.0);
      expect(c.houveAlteracao, isTrue);
    });

    test('6) Limpar nota de aluno: volta pra null e marca dirty', () async {
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: FakeNotaRepository(
          notasAlunoByAulaId: {
            10: {1: 1.0},
          },
        ),
      );
      await c.loadInitial();

      c.setNotaAluno(1, null);
      expect(c.notaAlunoEditada(1), isNull);
      expect(c.houveAlteracao, isTrue);
    });

    test(
        '7) Salvar com sucesso: persiste e volta houveAlteracao=false; ignora nulls',
        () async {
      final notaRepo = FakeNotaRepository();
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      c.setTipo(NotaTipo.prova);
      c.setValorTotal(5.0);
      await c.setNotaAluno(1, 4.0);
      await c.setNotaAluno(2, null);

      await c.save();

      // 1x: persistência silenciosa de NotaAula no primeiro lançamento
      // 1x: persistência explícita de NotaAula (incluindo título) no save()
      expect(notaRepo.upsertNotaAulaOnlyCalls, 2);
      expect(notaRepo.replaceCalls, 1);
      expect(notaRepo.notaAulaByAulaId[10]!.tipo, 'prova');
      expect(notaRepo.notaAulaByAulaId[10]!.valorTotal, 5.0);

      // only aluno 1 persisted
      expect(notaRepo.notasAlunoByAulaId[10], {1: 4.0});

      expect(c.houveAlteracao, isFalse);
    });

    test('8) Salvar sem alterações: não chama persistência', () async {
      final notaRepo = FakeNotaRepository();
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      await c.save();
      expect(notaRepo.replaceCalls, 0);
    });

    test(
        '9) Sair sem salvar com alterações: exige confirmação (shouldConfirmDiscard=true)',
        () async {
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: FakeNotaRepository(),
      );
      await c.loadInitial();

      c.setValorTotal(1.0);
      expect(c.shouldConfirmDiscard(), isTrue);
    });

    test(
        '10) Sair sem salvar sem alterações: permite saída (shouldConfirmDiscard=false)',
        () async {
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: FakeNotaRepository(),
      );
      await c.loadInitial();

      expect(c.shouldConfirmDiscard(), isFalse);
    });

    test('11) Persistência isolada por aula: salvar aula A não altera aula B',
        () async {
      final notaRepo = FakeNotaRepository(
        notaAulaByAulaId: {
          20: NotaAula(
              aulaId: 20, tipo: 'avaliacao', valorTotal: 2.0, titulo: null),
        },
        notasAlunoByAulaId: {
          20: {1: 1.0},
        },
      );

      final cA = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await cA.loadInitial();

      cA.setTipo(NotaTipo.trabalho);
      cA.setValorTotal(5.0);
      cA.setNotaAluno(1, 4.0);
      await cA.save();

      // aula B intact
      expect(notaRepo.notaAulaByAulaId[20]!.tipo, 'avaliacao');
      expect(notaRepo.notasAlunoByAulaId[20], {1: 1.0});
    });

    test('12) Não calcular nota final: não altera valores implicitamente',
        () async {
      final notaRepo = FakeNotaRepository(
        notaAulaByAulaId: {
          10: NotaAula(
              aulaId: 10, tipo: 'avaliacao', valorTotal: 5.0, titulo: null),
        },
        notasAlunoByAulaId: {
          10: {1: 4.0, 2: 1.0},
        },
      );

      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      // Without edits, saving is a no-op; this guarantees no normalization/sum.
      await c.save();
      expect(notaRepo.replaceCalls, 0);

      // Values remain exactly as loaded.
      expect(c.valorTotalEditado, 5.0);
      expect(c.notaAlunoEditada(1), 4.0);
      expect(c.notaAlunoEditada(2), 1.0);
    });

    test(
        '13) Sanitização: antes de valorTotal definido, permite acima do futuro limite (sem clamp)',
        () async {
      final notaRepo = FakeNotaRepository();
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      // valorTotal ainda é null: não deve clamp
      await c.setNotaAluno(1, 9.0);
      expect(c.notaAlunoEditada(1), 9.0);
      expect(
        notaRepo.upsertNotaAulaOnlyCalls,
        0,
        reason: 'Não deve persistir NotaAula silenciosamente sem valorTotal',
      );
    });

    test(
        '14) Sanitização: com valorTotal definido, clamp no momento da digitação',
        () async {
      final notaRepo = FakeNotaRepository();
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      c.setValorTotal(5.0);
      await c.setNotaAluno(1, 7.0);

      expect(c.notaAlunoEditada(1), 5.0);
    });

    test(
        '15) Formatação/normalização: inteiro vira uma casa decimal e número é arredondado para 1 casa',
        () async {
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: FakeNotaRepository(),
      );
      await c.loadInitial();
      c.setValorTotal(10.0);

      await c.setNotaAluno(1, 2);
      expect(c.notaAlunoEditada(1), 2.0);

      await c.setNotaAluno(1, 2.34);
      expect(c.notaAlunoEditada(1), 2.3);
    });

    test(
        '16) Persistência silenciosa: primeiro lançamento persiste só NotaAula (sem notas aluno)',
        () async {
      final notaRepo = FakeNotaRepository();
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      c.setTipo(NotaTipo.prova);
      c.setValorTotal(5.0);

      await c.setNotaAluno(1, 4.0);

      expect(notaRepo.upsertNotaAulaOnlyCalls, 1);
      expect(notaRepo.notaAulaByAulaId[10]!.tipo, 'prova');
      expect(notaRepo.notaAulaByAulaId[10]!.valorTotal, 5.0);
      expect(notaRepo.notasAlunoByAulaId[10], isEmpty,
          reason: 'Notas de aluno só no clique em Salvar');
    });

    test(
        '17) Persistência silenciosa não é retroativa: não altera outras notas ao editar uma',
        () async {
      final notaRepo = FakeNotaRepository(
        notaAulaByAulaId: {
          10: NotaAula(
              aulaId: 10, tipo: 'avaliacao', valorTotal: 5.0, titulo: null),
        },
        notasAlunoByAulaId: {
          10: {2: 4.0},
        },
      );

      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      // Config já existe no banco. Ajusta valorTotal e edita aluno 1.
      c.setValorTotal(3.0);
      await c.setNotaAluno(1, 9.0); // clamp para 3.0

      // Nota do aluno 2 não deve ser alterada automaticamente.
      expect(c.notaAlunoEditada(2), 4.0);
    });

    test(
        '18) Sanitização FINAL no save(): clampa valorTotal para 10 e notas para [0, valorTotal]',
        () async {
      final notaRepo = FakeNotaRepository();
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      // valorTotal acima do permitido
      c.setValorTotal(12);
      // notas fora da faixa
      await c.setNotaAluno(1, 15);
      await c.setNotaAluno(2, -3);
      await c.setNotaAluno(3, 2);

      await c.save();

      expect(notaRepo.replaceCalls, 1);
      expect(notaRepo.notaAulaByAulaId[10]!.valorTotal, 10.0);
      expect(notaRepo.notasAlunoByAulaId[10], {
        1: 10.0,
        2: 0.0,
        3: 2.0,
      });

      // In-memory state should also reflect exactly what was persisted.
      expect(c.valorTotalEditado, 10.0);
      expect(c.notaAlunoEditada(1), 10.0);
      expect(c.notaAlunoEditada(2), 0.0);
      expect(c.notaAlunoEditada(3), 2.0);
    });

    test('19) Título: alterar título NÃO persiste até salvar', () async {
      final notaRepo = FakeNotaRepository(
        notasAlunoByAulaId: {
          10: {2: 4.0},
        },
      );
      final c = NotasController(
        aulaId: 10,
        turmaId: 1,
        alunoRepository: FakeAlunoRepository(alunosByTurmaId: {1: const []}),
        notaRepository: notaRepo,
      );
      await c.loadInitial();

      // Config ready
      c.setValorTotal(5.0);

      c.setTitulo('  Avaliação 1  ');

      // Title should not be persisted until explicit save.
      expect(notaRepo.upsertNotaAulaOnlyCalls, 0);
      expect(notaRepo.replaceCalls, 0);

      await c.save();
      expect(notaRepo.upsertNotaAulaOnlyCalls, 1);
      expect(notaRepo.replaceCalls, 1);

      expect(notaRepo.notaAulaByAulaId[10]!.titulo, 'Avaliação 1');
      expect(
        notaRepo.notasAlunoByAulaId[10],
        {2: 4.0},
        reason:
            'Persistência silenciosa não pode alterar/apagar notas de aluno',
      );
    });

    test('parsing MVP: aceita vírgula e ponto', () {
      expect(NotasController.parseDoubleLoose('1,5'), 1.5);
      expect(NotasController.parseDoubleLoose('2.25'), 2.25);
      expect(NotasController.parseDoubleLoose(' '), isNull);
    });
  });
}
