import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/entities/turma.dart' as domain;
import 'package:educa_plus/domain/repositories/turma_repository.dart';

class TurmaRepositoryImpl implements TurmaRepository {
  final db.AppDatabase database;

  TurmaRepositoryImpl(this.database);

  domain.Turma _fromDb(db.Turma t) {
    return domain.Turma(
      id: t.id,
      nome: t.nome,
      disciplina: t.disciplina,
      anoLetivo: t.anoLetivo,
      ativa: t.ativa,
      isDeleted: t.isDeleted,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    );
  }

  @override
  Future<int> create(domain.Turma turma) async {
    final now = DateTime.now();
    final companion = db.TurmasCompanion.insert(
      nome: turma.nome,
      disciplina: drift.Value(turma.disciplina),
      anoLetivo: turma.anoLetivo,
      ativa: drift.Value(turma.ativa),
      isDeleted: drift.Value(turma.isDeleted),
      createdAt: drift.Value(turma.createdAt ?? now),
      updatedAt: drift.Value(turma.updatedAt ?? now),
    );
    return await database.into(database.turmas).insert(companion);
  }

  @override
  Future<void> deactivate(int id) async {
    await (database.update(database.turmas)..where((t) => t.id.equals(id)))
        .write(db.TurmasCompanion(
      ativa: const drift.Value(false),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  @override
  Future<List<domain.Turma>> getAll({bool? onlyActive = true}) async {
    final query = database.select(database.turmas);
    // onlyActive semantics:
    // - true  => only active turmas
    // - false => only inactive turmas
    // - null  => all turmas
    // Always exclude deleted turmas from the main listing.
    query.where((t) => t.isDeleted.equals(false));
    if (onlyActive == true) {
      query.where((t) => t.ativa.equals(true));
    } else if (onlyActive == false) {
      query.where((t) => t.ativa.equals(false));
    }
    final rows = await query.get();
    return rows.map(_fromDb).toList();
  }

  @override
  Future<domain.Turma?> getById(int id) async {
    final query = database.select(database.turmas)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _fromDb(row);
  }

  @override
  Future<void> update(domain.Turma turma) async {
    if (turma.id == null) throw ArgumentError('Turma id is required to update');
    await database.update(database.turmas).replace(
          db.Turma(
            id: turma.id!,
            nome: turma.nome,
            disciplina: turma.disciplina,
            anoLetivo: turma.anoLetivo,
            ativa: turma.ativa,
            isDeleted: turma.isDeleted,
            createdAt: turma.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<List<domain.Turma>> getDeleted() async {
    final query = database.select(database.turmas)
      ..where((t) => t.isDeleted.equals(true));
    final rows = await query.get();
    return rows.map(_fromDb).toList();
  }

  @override
  Future<void> moveToTrash(int id) async {
    await (database.update(database.turmas)..where((t) => t.id.equals(id)))
        .write(db.TurmasCompanion(
      isDeleted: const drift.Value(true),
      ativa: const drift.Value(false),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  @override
  Future<void> restoreFromTrash(int id) async {
    await (database.update(database.turmas)..where((t) => t.id.equals(id)))
        .write(db.TurmasCompanion(
      isDeleted: const drift.Value(false),
      // keep turma inactive after restore
      ativa: const drift.Value(false),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deletePermanently(int id) async {
    // Delete turma and all related entities in a transaction to ensure atomicity.
    await database.transaction(() async {
      // Delete notasAluno for aulas belonging to this turma
      final aulaIds = await (database.select(database.aulas)
            ..where((a) => a.turmaId.equals(id)))
          .get()
          .then((rows) => rows.map((r) => r.id).toList());

      if (aulaIds.isNotEmpty) {
        for (final aulaId in aulaIds) {
          await (database.delete(database.notasAluno)
                ..where((n) => n.aulaId.equals(aulaId)))
              .go();
          await (database.delete(database.notasAula)..where((n) => n.aulaId.equals(aulaId))).go();
          await (database.delete(database.presencas)..where((p) => p.aulaId.equals(aulaId))).go();
          await (database.delete(database.conteudosAula)..where((c) => c.aulaId.equals(aulaId))).go();
          await (database.delete(database.observacoesAula)..where((o) => o.aulaId.equals(aulaId))).go();
          await (database.delete(database.aulas)..where((a) => a.id.equals(aulaId))).go();
        }
      }

      // Delete alunos linked to this turma
      await (database.delete(database.alunos)..where((a) => a.turmaId.equals(id))).go();

      // Finally delete the turma row itself
      await (database.delete(database.turmas)..where((t) => t.id.equals(id))).go();
    });
  }
}
