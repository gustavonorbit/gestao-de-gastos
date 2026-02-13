import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/entities/aluno.dart' as domain;
import 'package:educa_plus/domain/repositories/aluno_repository.dart';

class AlunoRepositoryImpl implements AlunoRepository {
  final db.AppDatabase database;

  AlunoRepositoryImpl(this.database);

  domain.Aluno _fromDb(db.Aluno a) {
    return domain.Aluno(
      id: a.id,
      turmaId: a.turmaId,
      nome: a.nome,
      numeroChamada: a.numeroChamada,
      ativo: a.ativo,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
    );
  }

  @override
  Future<List<domain.Aluno>> getAllForTurma(int turmaId,
      {bool onlyActive = true}) async {
    final query = database.select(database.alunos)
      ..where((a) => a.turmaId.equals(turmaId));
    if (onlyActive) query.where((a) => a.ativo.equals(true));
    // Prefer ordering by numeroChamada when available; keep nulls at the end.
    query.orderBy([
      (a) => drift.OrderingTerm(
            expression: a.numeroChamada.isNotNull(),
            mode: drift.OrderingMode.desc,
          ),
      (a) => drift.OrderingTerm(expression: a.numeroChamada),
      (a) => drift.OrderingTerm(expression: a.nome),
    ]);
    final rows = await query.get();
    return rows.map(_fromDb).toList();
  }

  @override
  Future<void> updateAluno({
    required int id,
    required String nome,
    int? numeroChamada,
    bool? ativo,
  }) async {
    final fixedName = nome.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (fixedName.isEmpty) throw ArgumentError('nome cannot be empty');

    await (database.update(database.alunos)..where((a) => a.id.equals(id)))
        .write(
      db.AlunosCompanion(
        nome: drift.Value(fixedName),
        // If caller doesn't provide numeroChamada, don't overwrite what's in DB.
        numeroChamada: numeroChamada == null
            ? const drift.Value.absent()
            : drift.Value(numeroChamada),
        ativo: ativo == null ? const drift.Value.absent() : drift.Value(ativo),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> upsertManyByName(int turmaId, List<String> nomes) async {
    // Normalize input: trim, collapse spaces, dedupe case-insensitive.
    final seen = <String>{};
    final normalized = <String>[];
    for (final raw in nomes) {
      final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (seen.add(key)) normalized.add(name);
    }
    if (normalized.isEmpty) return 0;

    return await database.transaction(() async {
      // Fetch existing names for turma
      final existing = await (database.select(database.alunos)
            ..where((a) => a.turmaId.equals(turmaId)))
          .get();
      final existingKeys = existing
          .map((e) =>
              e.nome.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase())
          .toSet();

      final now = DateTime.now();
      final toInsert = <db.AlunosCompanion>[];
      for (final name in normalized) {
        final key = name.toLowerCase();
        if (existingKeys.contains(key)) continue;
        toInsert.add(
          db.AlunosCompanion.insert(
            turmaId: turmaId,
            nome: name,
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
      }

      if (toInsert.isEmpty) return 0;

      await database.batch((b) {
        b.insertAll(database.alunos, toInsert);
      });

      return toInsert.length;
    });
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.alunos)..where((a) => a.id.equals(id)))
        .go();
  }

  @override
  Future<void> deactivate(int id) async {
    await (database.update(database.alunos)..where((a) => a.id.equals(id)))
        .write(
      db.AlunosCompanion(
        ativo: const drift.Value(false),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }
}
