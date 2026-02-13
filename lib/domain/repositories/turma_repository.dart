import '../entities/turma.dart';

abstract class TurmaRepository {
  /// Returns turmas filtered by active status.
  /// - `onlyActive == true` => return only active turmas
  /// - `onlyActive == false` => return only inactive turmas
  /// - `onlyActive == null` => return all turmas
  Future<List<Turma>> getAll({bool? onlyActive = true});

  /// Returns turmas that were moved to the trash (is_deleted = true).
  Future<List<Turma>> getDeleted();

  /// Move a turma to the trash. Should set is_deleted = true and keep ativa = false.
  Future<void> moveToTrash(int id);

  /// Restore a turma from the trash. Should set is_deleted = false and keep ativa = false.
  Future<void> restoreFromTrash(int id);

  /// Permanently delete a turma and related data. Must be called only from the Trash UI.
  Future<void> deletePermanently(int id);

  Future<Turma?> getById(int id);

  /// Returns the inserted id
  Future<int> create(Turma turma);

  Future<void> update(Turma turma);

  /// Soft-delete (deactivate)
  Future<void> deactivate(int id);
}
