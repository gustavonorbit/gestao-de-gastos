import 'package:drift/native.dart';
import 'package:educa_plus/data/database.dart';
import 'package:educa_plus/data/repositories/conteudo_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConteudoRepository replaceForAula isolates by aulaId', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = ConteudoRepositoryImpl(db);

    await repo.replaceForAula(1, ['A', 'B']);
    await repo.replaceForAula(2, ['X']);

    final aula1 = await repo.getAllForAula(1);
    final aula2 = await repo.getAllForAula(2);

    expect(aula1.map((e) => e.texto).toList(), ['A', 'B']);
    expect(aula2.map((e) => e.texto).toList(), ['X']);

    // Replace aula1 should not affect aula2
    await repo.replaceForAula(1, ['C']);

    final aula1b = await repo.getAllForAula(1);
    final aula2b = await repo.getAllForAula(2);

    expect(aula1b.map((e) => e.texto).toList(), ['C']);
    expect(aula2b.map((e) => e.texto).toList(), ['X']);
  });

  test('ConteudoRepository ignores blanks and can clear by saving empty list',
      () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = ConteudoRepositoryImpl(db);

    await repo.replaceForAula(1, ['  ', 'A', '']);
    final aula1 = await repo.getAllForAula(1);
    expect(aula1.map((e) => e.texto).toList(), ['A']);

    await repo.replaceForAula(1, []);
    final aula1cleared = await repo.getAllForAula(1);
    expect(aula1cleared, isEmpty);
  });
}
