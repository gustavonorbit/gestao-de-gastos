import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/app/providers.dart' show turmaRepositoryProvider;
import 'package:educa_plus/providers/turma_notifier.dart' show turmaListProvider;

class TrashTurmaListNotifier extends Notifier<AsyncValue<List<Turma>>> {
  // Avoid late initialization issues: read repository from ref on demand.
  TurmaRepository get repository => ref.read(turmaRepositoryProvider);

  @override
  AsyncValue<List<Turma>> build() {
    load();
    return const AsyncValue.loading();
  }

  Future<void> load() async {
    try {
      final list = await repository.getDeleted();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restore(int id) async {
    try {
      await repository.restoreFromTrash(id);
      // Refresh both lists
      await load();
      // Ensure main list is refreshed/invalidated so UI updates everywhere
      ref.invalidate(turmaListProvider);
      // Also explicitly trigger a reload of the main list so mounted screens
      // reflect the restored turma immediately.
      await ref.read(turmaListProvider.notifier).load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePermanently(int id) async {
    try {
      await repository.deletePermanently(id);
      await load();
      // Ensure main list is refreshed/invalidated so UI updates everywhere
      ref.invalidate(turmaListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Move a turma to the trash. This ensures the trash list is reloaded and
  /// the main turma list is invalidated so both UIs reflect the change.
  Future<void> moveToTrash(int id) async {
    try {
      await repository.moveToTrash(id);
      await load();
      ref.invalidate(turmaListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final trashTurmaListProvider =
    NotifierProvider<TrashTurmaListNotifier, AsyncValue<List<Turma>>>(
  TrashTurmaListNotifier.new,
);
