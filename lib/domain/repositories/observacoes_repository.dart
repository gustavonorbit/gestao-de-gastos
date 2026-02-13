abstract class ObservacoesRepository {
  /// Returns all observations for a given aula.
  Future<List<ObservacaoAula>> getAllForAula(int aulaId);

  /// Replaces all observations for a given aula:
  /// - delete previous items
  /// - insert new items
  ///
  /// Implementations must ignore blank strings.
  Future<void> replaceForAula(int aulaId, List<String> observacoes);
}

class ObservacaoAula {
  final int aulaId;
  final String texto;

  ObservacaoAula({
    required this.aulaId,
    required this.texto,
  });
}
