import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart';

import 'package:educa_plus/data/database.dart';
import 'package:educa_plus/data/repositories/nota_repository_impl.dart';

void main() {
  group('NotaRepositoryImpl.upsertNotaAulaOnly', () {
    test('does not violate UNIQUE(aula_id) when called multiple times',
        () async {
      final db = AppDatabase.test(NativeDatabase.memory());
      final repo = NotaRepositoryImpl(db);

      await repo.upsertNotaAulaOnly(
        aulaId: 10,
        tipo: 'avaliacao',
        valorTotal: 5.0,
        titulo: 'A1',
      );

      await repo.upsertNotaAulaOnly(
        aulaId: 10,
        tipo: 'prova',
        valorTotal: 7.0,
        titulo: 'P1',
      );

      // There must be a single row for aula_id=10 and the latest values.
      final nota = await repo.getNotaAula(10);
      expect(nota, isNotNull);
      expect(nota!.aulaId, 10);
      expect(nota.tipo, 'prova');
      expect(nota.valorTotal, 7.0);
      expect(nota.titulo, 'P1');

      final rows = await (db.select(db.notasAula)
            ..where((t) => t.aulaId.equals(10)))
          .get();
      expect(rows.length, 1);

      await db.close();
    });

    test('replaceForAula does not touch notas_aula (titulo preserved)',
        () async {
      final db = AppDatabase.test(NativeDatabase.memory());
      final repo = NotaRepositoryImpl(db);

      await repo.upsertNotaAulaOnly(
        aulaId: 10,
        tipo: 'avaliacao',
        valorTotal: 5.0,
        titulo: 'Título persistido',
      );

      await repo.replaceForAula(
        aulaId: 10,
        tipo: 'prova',
        valorTotal: 9.0,
        notasPorAluno: {1: 4.0},
      );

      final nota = await repo.getNotaAula(10);
      expect(nota, isNotNull);
      expect(nota!.titulo, 'Título persistido');

      final rows = await (db.select(db.notasAula)
            ..where((t) => t.aulaId.equals(10)))
          .get();
      expect(rows.length, 1);

      await db.close();
    });
  });
}
