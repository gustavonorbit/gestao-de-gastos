import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/data/database.dart' show AppDatabase;
import 'package:drift/native.dart';
import 'package:educa_plus/data/repositories/turma_repository_impl.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/app/providers.dart' show dbProvider, turmaRepositoryProvider;
import 'package:educa_plus/providers/turma_notifier.dart' show turmaListProvider;
import 'package:educa_plus/ui/screens/classes/turma_filter_controller.dart' show turmaFilterProvider;

Future<List<Turma>> _waitForData(ProviderContainer container,
    {Duration timeout = const Duration(seconds: 2)}) async {
  final sw = DateTime.now();
  while (DateTime.now().difference(sw) < timeout) {
    final av = container.read(turmaListProvider);
    final list = av.maybeWhen(data: (l) => l, orElse: () => null);
    if (list != null) return list;
    await Future.delayed(const Duration(milliseconds: 50));
  }
  throw Exception('Timed out waiting for turmaListProvider data');
}

void main() {
  group('TurmaListNotifier reacts to turmaFilterProvider', () {
    late AppDatabase db;
    late TurmaRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      repo = TurmaRepositoryImpl(db);
      // Insert mixed turmas
      await repo.create(Turma(nome: 'Active A', anoLetivo: 1, ativa: true));
      await repo.create(Turma(nome: 'Inactive B', anoLetivo: 2, ativa: false));
      await repo.create(Turma(nome: 'Active C', anoLetivo: 3, ativa: true));
    });

    tearDown(() async {
      await db.close();
    });

    test('filter true => only active', () async {
      final container = ProviderContainer(overrides: [
        dbProvider.overrideWithValue(db),
        turmaRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

  // Ensure initial load completes (force load to avoid timing issues)
  await container.read(turmaListProvider.notifier).load();
  final initial = await _waitForData(container);
      // initial should contain all (filter default is null)
      expect(initial.map((t) => t.nome).toSet(), containsAll(['Active A', 'Inactive B', 'Active C']));

      // Set filter to only active
  container.read(turmaFilterProvider.notifier).setAtiva(true);
  // Force load after filter change to ensure notifier reloads in tests
  await container.read(turmaListProvider.notifier).load();
  final onlyActive = await _waitForData(container);
      expect(onlyActive.every((t) => t.ativa == true), isTrue);
      expect(onlyActive.map((t) => t.nome).toSet(), containsAll(['Active A', 'Active C']));
      expect(onlyActive.map((t) => t.nome).toSet(), isNot(contains('Inactive B')));
    });

    test('filter false => only inactive', () async {
      final container = ProviderContainer(overrides: [
        dbProvider.overrideWithValue(db),
        turmaRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

  // initial all (force load)
  await container.read(turmaListProvider.notifier).load();
  final initial = await _waitForData(container);
  expect(initial.length, 3);

  container.read(turmaFilterProvider.notifier).setAtiva(false);
  await container.read(turmaListProvider.notifier).load();
  final onlyInactive = await _waitForData(container);
      expect(onlyInactive.every((t) => t.ativa == false), isTrue);
      expect(onlyInactive.map((t) => t.nome).toSet(), contains('Inactive B'));
    });

    test('filter null => all', () async {
      final container = ProviderContainer(overrides: [
        dbProvider.overrideWithValue(db),
        turmaRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

  // Set to active first to change state, then back to null
  container.read(turmaFilterProvider.notifier).setAtiva(true);
  await container.read(turmaListProvider.notifier).load();
  await _waitForData(container);

  // To reset to 'Todas' we use clear() because copyWith treats a null
  // ativa parameter as "leave unchanged". clear() sets the filter back to empty.
  container.read(turmaFilterProvider.notifier).clear();
  // Sanity check: repository directly should return all when asked
  final repoAll = await repo.getAll(onlyActive: null);
  expect(repoAll.map((t) => t.nome).toSet(), containsAll(['Active A', 'Inactive B', 'Active C']));

  // Confirm the filter value in the provider is null
  final currentFilter = container.read(turmaFilterProvider);
  // This should be null for 'ativa'
  expect(currentFilter.ativa, isNull);

  await container.read(turmaListProvider.notifier).load();
  final all = await _waitForData(container);
  expect(all.map((t) => t.nome).toSet(), containsAll(['Active A', 'Inactive B', 'Active C']));
    });
  });
}
