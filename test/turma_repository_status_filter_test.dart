import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/data/database.dart' show AppDatabase;
import 'package:drift/native.dart';
import 'package:educa_plus/data/repositories/turma_repository_impl.dart';
import 'package:educa_plus/domain/entities/turma.dart';

void main() {
  group('TurmaRepositoryImpl - status filtering', () {
    late AppDatabase db;
    late TurmaRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      repo = TurmaRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getAll(onlyActive: true) returns only active turmas', () async {
      // Arrange: create some turmas with mixed active flag
      final t1 = Turma(nome: 'A1', anoLetivo: 1, ativa: true);
      final id1 = await repo.create(t1);

      final t2 = Turma(nome: 'B1', anoLetivo: 2, ativa: false);
      final id2 = await repo.create(t2);

      final t3 = Turma(nome: 'C1', anoLetivo: 3, ativa: true);
      final id3 = await repo.create(t3);

      // Act
      final active = await repo.getAll(onlyActive: true);

      // Assert
      expect(active.every((t) => t.ativa == true), isTrue);
      expect(active.map((t) => t.nome).toSet(), containsAll([t1.nome, t3.nome]));
      expect(active.map((t) => t.nome).toSet(), isNot(contains(t2.nome)));
    });

    test('getAll(onlyActive: false) returns only inactive turmas', () async {
      final t1 = Turma(nome: 'A2', anoLetivo: 1, ativa: true);
      await repo.create(t1);

      final t2 = Turma(nome: 'B2', anoLetivo: 2, ativa: false);
      await repo.create(t2);

      final list = await repo.getAll(onlyActive: false);
      expect(list.every((t) => t.ativa == false), isTrue);
      expect(list.map((t) => t.nome).toSet(), contains(t2.nome));
    });

    test('getAll(onlyActive: null) returns all turmas', () async {
      final t1 = Turma(nome: 'A3', anoLetivo: 1, ativa: true);
      await repo.create(t1);

      final t2 = Turma(nome: 'B3', anoLetivo: 2, ativa: false);
      await repo.create(t2);

      final all = await repo.getAll(onlyActive: null);
      final names = all.map((t) => t.nome).toSet();
      expect(names, containsAll([t1.nome, t2.nome]));
    });

    test('getById returns inactive turma even if filter would exclude it', () async {
      final inactive = Turma(nome: 'X-inactive', anoLetivo: 4, ativa: false);
      final id = await repo.create(inactive);

      final byId = await repo.getById(id);
      expect(byId, isNotNull);
      expect(byId!.ativa, isFalse);
    });
  });
}
