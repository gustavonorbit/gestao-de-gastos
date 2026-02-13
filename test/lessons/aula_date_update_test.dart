import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:educa_plus/domain/entities/aula.dart';
import 'package:educa_plus/domain/repositories/aula_repository.dart';
import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;
import 'package:educa_plus/providers/aula_provider.dart';
import 'package:educa_plus/providers/aula_notifier.dart' show aulaListProvider;
import 'package:educa_plus/ui/screens/lessons/aula_hub_screen.dart';

class FakeAulaRepository implements AulaRepository {
  final Map<int, Aula> _store;

  FakeAulaRepository(this._store);

  @override
  Future<int> create(Aula aula) async {
    final id = (_store.keys.isEmpty) ? 1 : (_store.keys.reduce((a, b) => a > b ? a : b) + 1);
    _store[id] = aula.copyWith(id: id);
    return id;
  }

  @override
  Future<void> delete(int id) async {
    _store.remove(id);
  }

  @override
  Future<List<Aula>> getAllForTurma(int turmaId) async {
    return _store.values.where((a) => a.turmaId == turmaId).toList();
  }

  @override
  Future<Aula?> getById(int id) async {
    return _store[id];
  }

  @override
  Future<void> update(Aula aula) async {
    if (aula.id == null) throw StateError('id required');
    _store[aula.id!] = aula;
  }
}

void main() {
  testWidgets('editing aula date updates DB, provider and topbar', (tester) async {
    final initial = Aula(id: 1, turmaId: 10, titulo: 'Aula 1', data: DateTime(2025, 1, 1));
    final store = {1: initial};
    final fakeRepo = FakeAulaRepository(store);

    final container = ProviderContainer(overrides: [
      aulaRepositoryProvider.overrideWithValue(fakeRepo),
    ]);
    addTearDown(container.dispose);

    // Build the app with the ProviderContainer so providers use the fake repo.
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: AulaHubScreen(
          turmaId: 10,
          aulaId: 1,
          aulaTitle: 'Aula 1',
          turmaName: 'Turma X',
        ),
      ),
    ));

    // Allow initial futures to resolve.
    await tester.pumpAndSettle();

    // Initial date displayed
    final initialDateText = DateFormat('dd/MM/yyyy').format(initial.data);
    expect(find.text(initialDateText), findsOneWidget);

    // Update date via the notifier (simulates the edit flow)
    final newDate = DateTime(2025, 2, 2);
    final updated = initial.copyWith(data: newDate);

    // Call update on the list notifier which will persist and invalidate providers
    await container.read(aulaListProvider.notifier).update(updated);

    // Wait for providers to settle and widget to rebuild
    await tester.pumpAndSettle();

    // DB has new date
    final fromDb = await fakeRepo.getById(1);
    expect(fromDb, isNotNull);
    expect(fromDb!.data, equals(newDate));

    // Provider has new date
    final aulaFromProvider = await container.read(aulaProvider(1).future);
    expect(aulaFromProvider, isNotNull);
    expect(aulaFromProvider!.data, equals(newDate));

    // UI topbar updated
    final newDateText = DateFormat('dd/MM/yyyy').format(newDate);
    expect(find.text(newDateText), findsOneWidget);
  });
}
