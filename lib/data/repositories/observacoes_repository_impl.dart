import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/repositories/observacoes_repository.dart';

class ObservacoesRepositoryImpl implements ObservacoesRepository {
  final db.AppDatabase database;

  ObservacoesRepositoryImpl(this.database);

  @override
  Future<List<ObservacaoAula>> getAllForAula(int aulaId) async {
    final query = database.select(database.observacoesAula)
      ..where((o) => o.aulaId.equals(aulaId))
      ..orderBy([(o) => drift.OrderingTerm.asc(o.id)]);

    final rows = await query.get();
    return rows
        .map((r) => ObservacaoAula(aulaId: r.aulaId, texto: r.texto))
        .toList(growable: false);
  }

  @override
  Future<void> replaceForAula(int aulaId, List<String> observacoes) async {
    final now = DateTime.now();
    final cleaned = observacoes
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);

    await database.transaction(() async {
      await (database.delete(database.observacoesAula)
            ..where((o) => o.aulaId.equals(aulaId)))
          .go();

      if (cleaned.isEmpty) return;

      await database.batch((batch) {
        for (final texto in cleaned) {
          batch.insert(
            database.observacoesAula,
            db.ObservacoesAulaCompanion.insert(
              aulaId: aulaId,
              texto: texto,
              createdAt: drift.Value(now),
              updatedAt: drift.Value(now),
            ),
          );
        }
      });
    });
  }
}
