import '../entities/aula.dart';

abstract class AulaRepository {
  Future<List<Aula>> getAllForTurma(int turmaId);

  Future<Aula?> getById(int id);

  /// Returns inserted id
  Future<int> create(Aula aula);

  Future<void> update(Aula aula);

  Future<void> delete(int id);
}
