import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/domain/entities/aula.dart';
import 'package:educa_plus/domain/repositories/aula_repository.dart';
import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;
import 'package:educa_plus/providers/aula_provider.dart' show aulaProvider;

class AulaListNotifier extends Notifier<AsyncValue<List<Aula>>> {
  late final AulaRepository repository;

  @override
  AsyncValue<List<Aula>> build() {
    repository = ref.read(aulaRepositoryProvider);
    // A lista só começa a carregar quando houver contexto de turma.
    return const AsyncValue.data([]);
  }

  Future<void> loadForTurma(int turmaId) async {
    try {
      final list = await repository.getAllForTurma(turmaId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Aula aula) async {
    try {
      await repository.create(aula);
      await loadForTurma(aula.turmaId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Aula aula) async {
    try {
      await repository.update(aula);

      // Invalidate any caches/providers that may hold the old Aula data so
      // UI reading via providers (aulaProvider / aulaDateProvider) will
      // refetch the fresh value from repository. This enforces the single
      // source of truth rule: providers + repo.
      if (aula.id != null) {
        ref.invalidate(aulaProvider(aula.id!));
      }

      await loadForTurma(aula.turmaId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(int id, int turmaId) async {
    try {
      await repository.delete(id);
      await loadForTurma(turmaId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final aulaListProvider =
    NotifierProvider<AulaListNotifier, AsyncValue<List<Aula>>>(
  AulaListNotifier.new,
);
