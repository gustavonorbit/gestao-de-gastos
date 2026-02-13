import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/repositories/nota_repository.dart';

class NotaRepositoryImpl implements NotaRepository {
  final db.AppDatabase database;

  NotaRepositoryImpl(this.database);

  @override
  Future<NotaAula?> getNotaAula(int aulaId) async {
    final query = database.select(database.notasAula)
      ..where((t) => t.aulaId.equals(aulaId));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return NotaAula(
      aulaId: row.aulaId,
      tipo: row.tipo,
      valorTotal: row.valorTotal,
      titulo: row.titulo,
    );
  }

  @override
  Future<List<NotaAluno>> getNotasAluno(int aulaId) async {
    final query = database.select(database.notasAluno)
      ..where((t) => t.aulaId.equals(aulaId));

    final rows = await query.get();
    return rows
        .map((r) =>
            NotaAluno(aulaId: r.aulaId, alunoId: r.alunoId, valor: r.valor))
        .toList(growable: false);
  }

  @override
  Future<void> upsertNotaAulaOnly({
    required int aulaId,
    required String tipo,
    required double? valorTotal,
    required String? titulo,
  }) async {
    final now = DateTime.now();

    // Upsert by UNIQUE(aula_id) without touching student grades.
    // Strategy: UPDATE by aula_id; if no rows updated, INSERT.
    final updated = await (database.update(database.notasAula)
          ..where((t) => t.aulaId.equals(aulaId)))
        .write(
      db.NotasAulaCompanion(
        tipo: drift.Value(tipo),
        valorTotal: drift.Value(valorTotal),
        titulo: drift.Value(titulo),
        updatedAt: drift.Value(now),
      ),
    );

    if (updated > 0) return;

    await database.into(database.notasAula).insert(
          db.NotasAulaCompanion.insert(
            aulaId: aulaId,
            tipo: tipo,
            valorTotal: drift.Value(valorTotal),
            titulo: drift.Value(titulo),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
  }

  @override
  Future<void> replaceForAula({
    required int aulaId,
    required String tipo,
    required double? valorTotal,
    required Map<int, double?> notasPorAluno,
  }) async {
    final now = DateTime.now();

    await database.transaction(() async {
      await (database.delete(database.notasAluno)
            ..where((t) => t.aulaId.equals(aulaId)))
          .go();

      final entries = notasPorAluno.entries
          .where((e) => e.value != null)
          .map((e) => MapEntry(e.key, e.value!))
          .toList(growable: false);

      if (entries.isEmpty) return;

      await database.batch((batch) {
        for (final e in entries) {
          batch.insert(
            database.notasAluno,
            db.NotasAlunoCompanion.insert(
              aulaId: aulaId,
              alunoId: e.key,
              valor: e.value,
              createdAt: drift.Value(now),
              updatedAt: drift.Value(now),
            ),
          );
        }
      });
    });
  }
}
