/// Builds the final exportable text for an aula content list.
///
/// Rules:
/// - trim each item
/// - drop blanks
/// - join using '; '
String buildConteudoTextoFinal(List<String> conteudos) {
  final parts = conteudos
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList(growable: false);

  return parts.join('; ');
}
