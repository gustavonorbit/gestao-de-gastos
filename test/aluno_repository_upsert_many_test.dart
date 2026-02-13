import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educa_plus/data/database.dart';
import 'package:educa_plus/data/repositories/aluno_repository_impl.dart';

void main() {
  test('upsertManyByName inserts new unique names (case-insensitive) per turma',
      () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    final repo = AlunoRepositoryImpl(db);

    addTearDown(() async => db.close());

    // Create turma
    final turmaId = await db.into(db.turmas).insert(
          TurmasCompanion.insert(nome: 'Escola X 1º A', anoLetivo: 1),
        );

    final inserted1 =
        await repo.upsertManyByName(turmaId, ['Ana', '  ana  ', 'Bruno', '']);
    expect(inserted1, 2);

    final list1 = await repo.getAllForTurma(turmaId);
    expect(list1.map((e) => e.nome), ['Ana', 'Bruno']);

    // Second insert should only add genuinely new ones
    final inserted2 = await repo.upsertManyByName(turmaId, ['BRUNO', 'Carla']);
    expect(inserted2, 1);

    final list2 = await repo.getAllForTurma(turmaId);
    expect(list2.map((e) => e.nome), ['Ana', 'Bruno', 'Carla']);
  });

  test('updateAluno sets numeroChamada and affects ordering', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    final repo = AlunoRepositoryImpl(db);

    addTearDown(() async => db.close());

    final turmaId = await db.into(db.turmas).insert(
          TurmasCompanion.insert(nome: 'Turma', anoLetivo: 1),
        );

    await repo.upsertManyByName(turmaId, ['Bruno', 'Ana', 'Carla']);
    final before = await repo.getAllForTurma(turmaId);
    // No numeroChamada => alphabetical
    expect(before.map((e) => e.nome), ['Ana', 'Bruno', 'Carla']);

    final ana = before.firstWhere((e) => e.nome == 'Ana');
    final carla = before.firstWhere((e) => e.nome == 'Carla');

    await repo.updateAluno(id: ana.id!, nome: 'Ana', numeroChamada: 2);
    await repo.updateAluno(id: carla.id!, nome: 'Carla', numeroChamada: 1);

    final after = await repo.getAllForTurma(turmaId);
    // numeroChamada first (1,2), then remaining nulls ordered by name
    expect(after.map((e) => '${e.nome}:${e.numeroChamada ?? '-'}'),
        ['Carla:1', 'Ana:2', 'Bruno:-']);
  });

  test('upsertManyByName does not dedupe across different turmas', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    final repo = AlunoRepositoryImpl(db);

    addTearDown(() async => db.close());

    final turmaA = await db.into(db.turmas).insert(
          TurmasCompanion.insert(nome: 'Turma A', anoLetivo: 1),
        );
    final turmaB = await db.into(db.turmas).insert(
          TurmasCompanion.insert(nome: 'Turma B', anoLetivo: 1),
        );

    final insertedA = await repo.upsertManyByName(turmaA, ['Ana']);
    final insertedB = await repo.upsertManyByName(turmaB, ['Ana']);

    expect(insertedA, 1);
    expect(insertedB, 1);

    final listA = await repo.getAllForTurma(turmaA);
    final listB = await repo.getAllForTurma(turmaB);

    expect(listA.length, 1);
    expect(listB.length, 1);
  });
}
