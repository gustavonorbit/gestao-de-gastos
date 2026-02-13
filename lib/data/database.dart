import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Tabela de turmas (persistência).
class Turmas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 255)();
  TextColumn get disciplina => text().nullable()();
  IntColumn get anoLetivo => integer().named('ano_letivo')();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
}

/// Tabela para nomes padrão de turmas (opções editáveis pelo usuário).
class NomesPadrao extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get valor => text().withLength(min: 1, max: 100)();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
}

/// Tabela de aulas (lessons) vinculadas a uma turma.
class Aulas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get turmaId => integer().named('turma_id')();
  TextColumn get titulo => text().withLength(min: 1, max: 255)();
  TextColumn get descricao => text().nullable()();
  DateTimeColumn get data => dateTime().named('data')();

  /// Tipo explícito da aula:
  /// - 1 = individual
  /// - 2 = dupla
  ///
  /// Mantemos inteiro para permitir migração simples a partir do legado
  /// `duracao_minutos` (que já usava 1/2 para sinalizar tipo).
  IntColumn get aulaTipo =>
      integer().named('aula_tipo').withDefault(const Constant(1))();
  IntColumn get duracaoMinutos =>
      integer().named('duracao_minutos').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
}

/// Tabela de alunos vinculados a uma turma.
class Alunos extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Add a foreign key reference to Turmas.id to enforce referential integrity.
  // We use RESTRICT on delete because turmas are soft-deleted (ativa=false)
  // and we don't want accidental cascade removals.
  IntColumn get turmaId => integer()
      .named('turma_id')
      .references(Turmas, #id, onDelete: KeyAction.restrict)();
  TextColumn get nome => text().withLength(min: 1, max: 255)();
  IntColumn get numeroChamada => integer().named('numero_chamada').nullable()();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
}

/// Tabela de presenças (attendance) por aula/aluno.
///
/// - [aulaIndex] representa qual aba da aula dupla (0 = Aula 1, 1 = Aula 2).
///   Para aula individual, sempre salvamos como 0.
/// - [presente] indica presença.
/// - [justificativa] é opcional (quando falta justificada).
class Presencas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aulaId => integer().named('aula_id')();
  IntColumn get alunoId => integer().named('aluno_id')();
  IntColumn get aulaIndex =>
      integer().named('aula_index').withDefault(const Constant(0))();
  BoolColumn get presente => boolean().withDefault(const Constant(true))();
  TextColumn get justificativa => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {aulaId, alunoId, aulaIndex},
      ];
}

/// Conteúdos registrados para uma aula.
///
/// Cada linha representa um item de conteúdo. Para exportação, os itens podem
/// ser concatenados com "; ".
class ConteudosAula extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aulaId => integer().named('aula_id')();
  TextColumn get texto => text().withLength(min: 0, max: 5000)();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  List<Set<Column>> get indexes => [
        {aulaId},
      ];
}

/// Observações registradas para uma aula.
///
/// Cada linha representa um item de observação (texto livre) vinculado a uma aula.
class ObservacoesAula extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aulaId => integer().named('aula_id')();
  TextColumn get texto => text().withLength(min: 0, max: 5000)();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  List<Set<Column>> get indexes => [
        {aulaId},
      ];
}

/// Nota (metadata) registrada para uma aula.
///
/// - Uma linha por aula.
/// - `tipo` é um dos valores: avaliacao | prova | trabalho
/// - `valor_total` é opcional (o professor pode deixar em branco no MVP).
class NotasAula extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aulaId => integer().named('aula_id')();
  TextColumn get tipo => text().withLength(min: 1, max: 30)();
  RealColumn get valorTotal => real().named('valor_total').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get titulo => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {aulaId},
      ];
}

/// Notas (valores) por aluno em uma aula.
class NotasAluno extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get aulaId => integer().named('aula_id')();
  IntColumn get alunoId => integer().named('aluno_id')();
  RealColumn get valor => real()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {aulaId, alunoId},
      ];

  List<Set<Column>> get indexes => [
        {aulaId},
      ];
}

@DriftDatabase(tables: [
  Turmas,
  Aulas,
  NomesPadrao,
  Alunos,
  Presencas,
  ConteudosAula,
  ObservacoesAula,
  NotasAula,
  NotasAluno
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor intended for tests where you want to inject an in-memory
  /// [QueryExecutor]. Use like: `AppDatabase.test(NativeDatabase.memory())`.
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // Called when the database is first created
        onCreate: (m) async {
          await m.createAll();
        },
        // Called when opening the database and the schema version has
        // been increased. We handle upgrades progressively:
        // - v1 -> v2: create `aulas`
        // - v2 -> v3: create `nomes_padrao`
        // - v3 -> v4: create `alunos`
        // - v4 -> v5: create `presencas`
        // - v5 -> v6: create `conteudos_aula`
        // - v6 -> v7: create `notas_aula` and `notas_aluno`
        // - v7 -> v8: add `titulo` to `notas_aula`
        // - v9 -> v10: add `aula_tipo` to `aulas` (explicit lesson type)
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // create the new table introduced in schemaVersion 2
            await m.createTable(aulas);
          }
          if (from < 3) {
            // create the new table introduced in schemaVersion 3
            await m.createTable(nomesPadrao);
            // no seeding here to keep migration simple; initial defaults can be
            // inserted by the app on first run or via a separate migration helper.
          }
          if (from < 4) {
            // Generated by drift in database.g.dart after codegen.
            // ignore: undefined_getter
            await m.createTable(alunos);
          }
          if (from < 5) {
            // Generated by drift in database.g.dart after codegen.
            // ignore: undefined_getter
            await m.createTable(presencas);
          }
          if (from < 6) {
            // Create the table introduced in schemaVersion 6.
            // We use raw SQL here to avoid depending on generated identifiers
            // during analysis/codegen steps.
            await m.database.customStatement(''
                'CREATE TABLE IF NOT EXISTS conteudos_aula ('
                'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
                'aula_id INTEGER NOT NULL, '
                'texto TEXT NOT NULL, '
                'created_at TEXT NULL, '
                'updated_at TEXT NULL'
                ');');
            await m.database.customStatement(
                'CREATE INDEX IF NOT EXISTS idx_conteudos_aula_aula_id ON conteudos_aula(aula_id);');
          }

          if (from < 7) {
            // Create the tables introduced in schemaVersion 7.
            // Raw SQL keeps migrations robust during analysis/codegen.
            await m.database.customStatement(''
                'CREATE TABLE IF NOT EXISTS notas_aula ('
                'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
                'aula_id INTEGER NOT NULL, '
                'tipo TEXT NOT NULL, '
                'titulo TEXT NULL, '
                'valor_total REAL NULL, '
                'created_at TEXT NULL, '
                'updated_at TEXT NULL, '
                'UNIQUE(aula_id)'
                ');');

            await m.database.customStatement(''
                'CREATE TABLE IF NOT EXISTS notas_aluno ('
                'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
                'aula_id INTEGER NOT NULL, '
                'aluno_id INTEGER NOT NULL, '
                'valor REAL NOT NULL, '
                'created_at TEXT NULL, '
                'updated_at TEXT NULL, '
                'UNIQUE(aula_id, aluno_id)'
                ');');

            await m.database.customStatement(
                'CREATE INDEX IF NOT EXISTS idx_notas_aluno_aula_id ON notas_aluno(aula_id);');
          }

          if (from < 8) {
            // v7 -> v8: add `titulo` to existing `notas_aula` table.
            await m.database.customStatement(
                'ALTER TABLE notas_aula ADD COLUMN titulo TEXT NULL;');
          }

          if (from < 9) {
            // v8 -> v9: create `observacoes_aula`.
            await m.database.customStatement(''
                'CREATE TABLE IF NOT EXISTS observacoes_aula ('
                'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
                'aula_id INTEGER NOT NULL, '
                'texto TEXT NOT NULL, '
                'created_at TEXT NULL, '
                'updated_at TEXT NULL'
                ');');
            await m.database.customStatement(
                'CREATE INDEX IF NOT EXISTS idx_observacoes_aula_aula_id ON observacoes_aula(aula_id);');
          }

          if (from < 10) {
            // v9 -> v10: add explicit `aula_tipo` to `aulas`.
            //
            // Compatibilidade:
            // - Se houver `duracao_minutos==2`, consideramos aula dupla.
            // - Caso contrário, individual.
            await m.database.customStatement(
                'ALTER TABLE aulas ADD COLUMN aula_tipo INTEGER NOT NULL DEFAULT 1;');
            await m.database.customStatement('UPDATE aulas '
                'SET aula_tipo = CASE WHEN duracao_minutos = 2 THEN 2 ELSE 1 END '
                'WHERE aula_tipo IS NULL OR aula_tipo = 1;');
          }

          if (from < 11) {
            // v10 -> v11: add foreign key constraint from alunos.turma_id -> turmas.id
            // SQLite does not support adding FK constraints via ALTER TABLE, so
            // we recreate the table with the constraint and copy the data.
            // This operation is wrapped in a transaction for safety.

            // Disable foreign keys enforcement during schema change to avoid
            // constraint checks while moving data. We'll re-enable afterwards.
            await m.database.customStatement('PRAGMA foreign_keys = OFF;');
            await m.database.customStatement('BEGIN TRANSACTION;');

            // Create new table with the same columns but with a FOREIGN KEY.
            await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS alunos_new (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            turma_id INTEGER NOT NULL,
            nome TEXT NOT NULL,
            numero_chamada INTEGER NULL,
            ativo INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NULL,
            updated_at TEXT NULL,
            FOREIGN KEY(turma_id) REFERENCES turmas(id) ON DELETE RESTRICT
          );
        ''');

            // Copy existing data. Rows with NULL or invalid turma_id will be
            // preserved as-is; referential checks are enforced only when
            // foreign_keys is ON, so we re-enable it after the swap.
            await m.database.customStatement('''
          INSERT INTO alunos_new (id, turma_id, nome, numero_chamada, ativo, created_at, updated_at)
          SELECT id, turma_id, nome, numero_chamada, ativo, created_at, updated_at FROM alunos;
        ''');

            await m.database.customStatement('DROP TABLE alunos;');
            await m.database
                .customStatement('ALTER TABLE alunos_new RENAME TO alunos;');

            await m.database.customStatement('COMMIT;');
            await m.database.customStatement('PRAGMA foreign_keys = ON;');
          }
          if (from < 12) {
            // v11 -> v12: add is_deleted to turmas for soft-trash support
            await m.database.customStatement(
                'ALTER TABLE turmas ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;');
          }
        },
        // Optionally run code before open
        beforeOpen: (details) async {
          // no-op for now; future hooks (e.g., migrations or data fixes)
          // can be placed here.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'educa_plus.sqlite'));
    return NativeDatabase(file);
  });
}
