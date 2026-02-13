import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:educa_plus/data/database.dart';
import 'package:educa_plus/data/repositories/turma_repository_impl.dart';
import 'package:educa_plus/domain/entities/turma.dart' as domain;

void main() {
  group('TurmaRepositoryImpl (in-memory DB)', () {
    late AppDatabase db;
    late TurmaRepositoryImpl repo;

    setUp(() {
      db = AppDatabase.test(NativeDatabase.memory());
      repo = TurmaRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('create and getAll returns created turma', () async {
      final id =
          await repo.create(const domain.Turma(nome: '1º A', anoLetivo: 2025));
      expect(id, greaterThan(0));

      final list = await repo.getAll();
      expect(list, isNotEmpty);
      final t = list.first;
      expect(t.nome, '1º A');
      expect(t.anoLetivo, 2025);
    });

    test('getById returns null for missing and returns object after create',
        () async {
      final missing = await repo.getById(9999);
      expect(missing, isNull);

      final id =
          await repo.create(const domain.Turma(nome: '2º B', anoLetivo: 2024));
      final found = await repo.getById(id);
      expect(found, isNotNull);
      expect(found!.nome, '2º B');
    });

    test('deactivate sets ativa to false', () async {
      final id =
          await repo.create(const domain.Turma(nome: '3º C', anoLetivo: 2023));
      var all = await repo.getAll();
      expect(all.any((t) => t.id == id && t.ativa), isTrue);

      await repo.deactivate(id);
      final after = await repo.getById(id);
      expect(after, isNotNull);
      expect(after!.ativa, isFalse);

      final activeOnly = await repo.getAll();
      expect(activeOnly.where((t) => t.id == id), isEmpty);
    });
  });
}
