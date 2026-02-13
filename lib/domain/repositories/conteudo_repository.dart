abstract class ConteudoRepository {
  /// Returns all content items for a given aula.
  Future<List<ConteudoAula>> getAllForAula(int aulaId);

  /// Replaces all content items for a given aula:
  /// - delete previous items
  /// - insert new items
  Future<void> replaceForAula(int aulaId, List<String> textos);
}

class ConteudoAula {
  final int aulaId;
  final String texto;

  ConteudoAula({
    required this.aulaId,
    required this.texto,
  });
}
