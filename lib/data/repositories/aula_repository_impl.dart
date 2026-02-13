import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/entities/aula.dart' as domain;
import 'package:educa_plus/domain/repositories/aula_repository.dart';

class AulaRepositoryImpl implements AulaRepository {
  final db.AppDatabase database;

  AulaRepositoryImpl(this.database);

  domain.Aula _fromDb(db.Aula a) {
    return domain.Aula(
      id: a.id,
      turmaId: a.turmaId,
      titulo: a.titulo,
      descricao: a.descricao,
      data: a.data,
      tipo: domain.AulaTipoX.fromDbValue(a.aulaTipo),
      duracaoMinutos: a.duracaoMinutos,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
    );
  }

  @override
  Future<int> create(domain.Aula aula) async {
    final companion = db.AulasCompanion.insert(
      turmaId: aula.turmaId,
      titulo: aula.titulo,
      descricao: drift.Value(aula.descricao),
      data: aula.data,
      aulaTipo: drift.Value(aula.tipo.dbValue),
      duracaoMinutos: drift.Value(aula.duracaoMinutos),
    );
    return await database.into(database.aulas).insert(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.aulas)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<domain.Aula>> getAllForTurma(int turmaId) async {
    final query = database.select(database.aulas)
      ..where((a) => a.turmaId.equals(turmaId));
    final rows = await query.get();
    return rows.map(_fromDb).toList();
  }

  @override
  Future<domain.Aula?> getById(int id) async {
    final query = database.select(database.aulas)
      ..where((a) => a.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _fromDb(row);
  }

  @override
  Future<void> update(domain.Aula aula) async {
    if (aula.id == null) throw ArgumentError('Aula id is required to update');
    await database.update(database.aulas).replace(
          db.Aula(
            id: aula.id!,
            turmaId: aula.turmaId,
            titulo: aula.titulo,
            descricao: aula.descricao,
            data: aula.data,
            aulaTipo: aula.tipo.dbValue,
            duracaoMinutos: aula.duracaoMinutos,
            createdAt: aula.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
  }
}
