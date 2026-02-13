import 'package:educa_plus/domain/entities/aluno.dart';
import 'package:educa_plus/domain/repositories/aluno_repository.dart';

class FakeAlunoRepository implements AlunoRepository {
  final Map<int, List<Aluno>> alunosByTurmaId;

  FakeAlunoRepository({
    required this.alunosByTurmaId,
  });

  @override
  Future<List<Aluno>> getAllForTurma(int turmaId,
      {bool onlyActive = true}) async {
    final list = alunosByTurmaId[turmaId] ?? const <Aluno>[];
    if (!onlyActive) return list;
    return list.where((a) => a.ativo).toList(growable: false);
  }

  @override
  Future<int> upsertManyByName(int turmaId, List<String> nomes) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateAluno(
      {required int id,
      required String nome,
      int? numeroChamada,
      bool? ativo}) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deactivate(int id) {
    throw UnimplementedError();
  }
}
