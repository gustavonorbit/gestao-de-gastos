import 'package:drift/drift.dart' as drift;
import 'package:educa_plus/data/database.dart' as db;
import 'package:educa_plus/domain/entities/nome_padrao.dart' as domain;
import 'package:educa_plus/domain/repositories/nome_padrao_repository.dart';

class NomePadraoRepositoryImpl implements NomePadraoRepository {
  final db.AppDatabase database;

  NomePadraoRepositoryImpl(this.database);

  domain.NomePadrao _fromDb(db.NomesPadraoData d) {
    return domain.NomePadrao(id: d.id, valor: d.valor, ordem: d.ordem);
  }

  @override
  Future<int> create(domain.NomePadrao item) async {
    final companion = db.NomesPadraoCompanion.insert(
        valor: item.valor, ordem: drift.Value(item.ordem));
    return await database.into(database.nomesPadrao).insert(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.nomesPadrao)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<List<domain.NomePadrao>> getAll() async {
    final rows = await database.select(database.nomesPadrao).get();
    return rows.map(_fromDb).toList();
  }

  @override
  Future<void> update(domain.NomePadrao item) async {
    if (item.id == null) throw ArgumentError('id required to update');
    await database.update(database.nomesPadrao).replace(db.NomesPadraoData(
          id: item.id!,
          valor: item.valor,
          ordem: item.ordem,
        ));
  }
}
