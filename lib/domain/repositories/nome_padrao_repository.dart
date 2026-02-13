import '../entities/nome_padrao.dart';

abstract class NomePadraoRepository {
  Future<List<NomePadrao>> getAll();

  Future<int> create(NomePadrao item);

  Future<void> update(NomePadrao item);

  Future<void> delete(int id);
}
