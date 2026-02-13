import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/repositories/presenca_repository.dart';

class PresencaRepositoryImpl implements PresencaRepository {
  final db.AppDatabase database;

  PresencaRepositoryImpl(this.database);

  PresencaRecord _fromDb(db.Presenca p) {
    return PresencaRecord(
      id: p.id,
      aulaId: p.aulaId,
      alunoId: p.alunoId,
      aulaIndex: p.aulaIndex,
      presente: p.presente,
      justificativa: p.justificativa,
    );
  }

  @override
  Future<void> upsert({
    required int aulaId,
    required int alunoId,
    required int aulaIndex,
    required bool presente,
    String? justificativa,
  }) async {
    final now = DateTime.now();
    final companion = db.PresencasCompanion.insert(
      aulaId: aulaId,
      alunoId: alunoId,
      aulaIndex: drift.Value(aulaIndex),
      presente: drift.Value(presente),
      justificativa: drift.Value(justificativa),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    );

    // We have a unique key (aulaId, alunoId, aulaIndex) and will insertOrReplace.
    await database.into(database.presencas).insert(
          companion,
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> upsertMany(List<PresencaUpsert> entries) async {
    await database.batch((batch) {
      for (final e in entries) {
        final now = DateTime.now();
        batch.insert(
          database.presencas,
          db.PresencasCompanion.insert(
            aulaId: e.aulaId,
            alunoId: e.alunoId,
            aulaIndex: drift.Value(e.aulaIndex),
            presente: drift.Value(e.presente),
            justificativa: drift.Value(e.justificativa),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<List<PresencaRecord>> getAllForAula(int aulaId) async {
    final query = database.select(database.presencas)
      ..where((p) => p.aulaId.equals(aulaId));

    final rows = await query.get();
    return rows.map(_fromDb).toList();
  }
}
