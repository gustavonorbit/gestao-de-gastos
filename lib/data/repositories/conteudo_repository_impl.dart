import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/repositories/conteudo_repository.dart';

class ConteudoRepositoryImpl implements ConteudoRepository {
  final db.AppDatabase database;

  ConteudoRepositoryImpl(this.database);

  @override
  Future<List<ConteudoAula>> getAllForAula(int aulaId) async {
    final query = database.select(database.conteudosAula)
      ..where((c) => c.aulaId.equals(aulaId))
      ..orderBy([(c) => drift.OrderingTerm.asc(c.id)]);

    final rows = await query.get();
    return rows
        .map((r) => ConteudoAula(aulaId: r.aulaId, texto: r.texto))
        .toList();
  }

  @override
  Future<void> replaceForAula(int aulaId, List<String> textos) async {
    final now = DateTime.now();
    final cleaned = textos
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);

    await database.transaction(() async {
      await (database.delete(database.conteudosAula)
            ..where((c) => c.aulaId.equals(aulaId)))
          .go();

      if (cleaned.isEmpty) return;

      await database.batch((batch) {
        for (final texto in cleaned) {
          batch.insert(
            database.conteudosAula,
            db.ConteudosAulaCompanion.insert(
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
