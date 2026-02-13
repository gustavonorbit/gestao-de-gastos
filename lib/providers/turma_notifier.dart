import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/app/providers.dart'
    show turmaRepositoryProvider, dbProvider, alunoRepositoryProvider;
import 'package:educa_plus/ui/screens/classes/turma_filter_controller.dart'
    show turmaFilterProvider;

class TurmaListNotifier extends Notifier<AsyncValue<List<Turma>>> {
  // Avoid late initialization issues by reading the repository from `ref`
  // when needed. This makes the notifier safe to rebuild after
  // `ref.invalidate(...)` without causing a LateInitializationError.
  TurmaRepository get repository => ref.read(turmaRepositoryProvider);

  @override
  AsyncValue<List<Turma>> build() {
    // Carrega ao iniciar.
    // Load initially and whenever the turma filter changes (ativa / inativa / all).
    load();
    ref.listen(turmaFilterProvider, (prev, next) {
      // When the filter changes, reload the list from the repository
      // taking the filter into account in `load()`.
      load();
    });
    return const AsyncValue.loading();
  }

  Future<void> load() async {
    try {
      // Determine how to load from DB based on the global turma filter.
      final filter = ref.read(turmaFilterProvider);

      // Map filter.ativa (bool? true/false/null) directly to repository call:
      // - true  => only active
      // - false => only inactive
      // - null  => all
      final listFromDb = await repository.getAll(onlyActive: filter.ativa);

      final list = listFromDb;
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Turma turma) async {
    try {
      await repository.create(turma);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a turma and returns the inserted id.
  ///
  /// This is useful for routing to a turma-specific screen right after creating it.
  Future<int> addAndReturnId(Turma turma) async {
    try {
      final id = await repository.create(turma);
      await load();
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Creates a turma and persists pending/edited students atomically.
  /// Returns the inserted id.
  Future<int> addWithStudentsAndReturnId(
    Turma turma,
    List<String> pendingNames,
    Map<int, String> editedActiveStudentNames,
  ) async {
    try {
      final db = ref.read(dbProvider);
      final alunoRepo = ref.read(alunoRepositoryProvider);

      final id = await db.transaction(() async {
        final insertedId = await repository.create(turma);

        final cleaned = pendingNames
            .map((e) => e.trim().replaceAll(RegExp(r"\s+"), ' '))
            .where((e) => e.isNotEmpty)
            .toList();
        if (cleaned.isNotEmpty) {
          await alunoRepo.upsertManyByName(insertedId, cleaned);
        }

        if (editedActiveStudentNames.isNotEmpty) {
          for (final entry in editedActiveStudentNames.entries) {
            final idAluno = entry.key;
            final trimmed = entry.value.trim().replaceAll(RegExp(r"\s+"), ' ');
            if (trimmed.isEmpty) continue;
            await alunoRepo.updateAluno(id: idAluno, nome: trimmed);
          }
        }

        return insertedId;
      });

      await load();
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates a turma and persists pending/edited students atomically.
  Future<void> updateWithStudents(
    Turma turma,
    List<String> pendingNames,
    Map<int, String> editedActiveStudentNames,
  ) async {
    try {
      final db = ref.read(dbProvider);
      final alunoRepo = ref.read(alunoRepositoryProvider);

      await db.transaction(() async {
        await repository.update(turma);

        final cleaned = pendingNames
            .map((e) => e.trim().replaceAll(RegExp(r"\s+"), ' '))
            .where((e) => e.isNotEmpty)
            .toList();
        if (cleaned.isNotEmpty && turma.id != null) {
          await alunoRepo.upsertManyByName(turma.id!, cleaned);
        }

        if (editedActiveStudentNames.isNotEmpty) {
          for (final entry in editedActiveStudentNames.entries) {
            final idAluno = entry.key;
            final trimmed = entry.value.trim().replaceAll(RegExp(r"\s+"), ' ');
            if (trimmed.isEmpty) continue;
            await alunoRepo.updateAluno(id: idAluno, nome: trimmed);
          }
        }
      });

      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> update(Turma turma) async {
    try {
      await repository.update(turma);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deactivate(int id) async {
    try {
      await repository.deactivate(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final turmaListProvider =
    NotifierProvider<TurmaListNotifier, AsyncValue<List<Turma>>>(
  TurmaListNotifier.new,
);
