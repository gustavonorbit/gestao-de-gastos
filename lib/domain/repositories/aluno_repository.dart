import '../entities/aluno.dart';

abstract class AlunoRepository {
  /// Lista alunos cadastrados para uma turma.
  Future<List<Aluno>> getAllForTurma(int turmaId, {bool onlyActive = true});

  /// Insere/mescla alunos por nome (dedupe case-insensitive) para uma turma.
  /// Retorna quantos foram inseridos (novos).
  Future<int> upsertManyByName(int turmaId, List<String> nomes);

  Future<void> updateAluno({
    required int id,
    required String nome,
    int? numeroChamada,
    bool? ativo,
  });

  Future<void> delete(int id);

  Future<void> deactivate(int id);
}
