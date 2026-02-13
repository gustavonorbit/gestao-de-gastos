import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/app/providers.dart'
    show nomePadraoRepositoryProvider;
import 'package:educa_plus/domain/entities/nome_padrao.dart';

/// Provides the list of turma name options (strings) from the repository.
final nomePadraoListProvider = FutureProvider<List<NomePadrao>>((ref) async {
  final repo = ref.read(nomePadraoRepositoryProvider);
  final list = await repo.getAll();
  // sort by ordem
  list.sort((a, b) => a.ordem.compareTo(b.ordem));
  return list;
});
