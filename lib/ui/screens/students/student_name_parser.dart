/// Utilities to turn OCR text into a clean list of student names.
///
/// Goals:
/// - Fast (runs on-device)
/// - Robust against OCR quirks (extra spaces, bullets, numbering)
/// - Safe (never mutates existing DB data here)
library;

List<String> parseStudentNamesFromOcrText(String text) {
  final lines = text
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  final cleaned = <String>[];
  final seen = <String>{};

  const connectors = <String>{'de', 'da', 'do', 'dos', 'das', 'e'};
  const singleWordStoplist = <String>{
    // Common OCR noise from school documents.
    'matutino',
    'vespertino',
    'noturno',
    'turma',
    'ano',
    'anos',
    'serie',
    'série',
    'turno',
    'aluno',
    'alunos',
    'nome',
    'nomes',
    'chamada',
    'lista',
    'professor',
    'professora',
    'disciplina',
    'matematica',
    'matemática',
    'portugues',
    'português',
    'historia',
    'história',
    'geografia',
    'ciencias',
    'ciências',
    'educacao',
    'educação',
    'fisica',
    'física',
    'quimica',
    'química',
    'biologia',
    'escola',
    'instituicao',
    'instituição',
    // Common abbreviations/noise
    'ns',
    'n',
    'no',
    'na',
    'se',
    'sim',
    'não',
  };
  final letterToken = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ]{2,}$");

  for (final line in lines) {
    var s = line;

    // Remove common prefixes: bullets, numbering, dashes.
    s = s.replaceFirst(RegExp(r'^[•\-–—]+\s*'), '');
    s = s.replaceFirst(RegExp(r'^(\d+)[\).\-:]\s*'), '');

    // Some OCR outputs keep numbering like "03 - Maria" (space before dash).
    // Strip that pattern too.
    s = s.replaceFirst(RegExp(r'^(\d+)\s+[\-–—:]\s*'), '');

    // If there are digits remaining after stripping known prefixes,
    // it's probably noise (call numbers, years, etc).
    if (RegExp(r'\d').hasMatch(s)) continue;

    // Treat hyphens as word separators (common in OCR for surnames).
    s = s.replaceAll(RegExp(r"[\-–—]"), ' ');

    // Replace punctuation/symbols with spaces but keep letters, spaces and apostrophes.
    s = s.replaceAll(RegExp(r"[^A-Za-zÀ-ÖØ-öø-ÿ\s']"), ' ');

    // Collapse internal whitespace.
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.isEmpty) continue;

    // Tokenize and keep only plausible name tokens.
    final rawParts = s.split(' ').where((p) => p.isNotEmpty).toList();
    if (rawParts.isEmpty) continue;

    // Discard lines that are just a single letter or short token.
    if (rawParts.length == 1 && rawParts.first.length < 2) continue;

    // Discard one-word lines that belong to common noise,
    // and also discard very short tokens (like "ns").
    if (rawParts.length == 1) {
      final lower = rawParts.first.toLowerCase();
      if (lower.length <= 2) continue;
      if (singleWordStoplist.contains(lower)) continue;
    }

    final kept = <String>[];
    for (final p in rawParts) {
      final lower = p.toLowerCase();

      if (connectors.contains(lower)) {
        kept.add(lower);
        continue;
      }

      // Accept only letter tokens with len >= 2.
      if (!letterToken.hasMatch(p)) continue;

      // Capitalize token (handles already-uppercased OCR nicely).
      final normalized = lower[0].toUpperCase() + lower.substring(1);
      kept.add(normalized);
    }

    // Must have at least one real name piece (not only connectors).
    final hasNamePiece = kept.any((t) => !connectors.contains(t));
    if (!hasNamePiece) continue;

    // Stoplist again after normalization: a line like "Turma" would become "Turma".
    if (kept.length == 1) {
      final lower = kept.first.toLowerCase();
      if (lower.length <= 2) continue;
      if (singleWordStoplist.contains(lower)) continue;
    }

    // Remove leading/trailing connectors.
    while (kept.isNotEmpty && connectors.contains(kept.first)) {
      kept.removeAt(0);
    }
    while (kept.isNotEmpty && connectors.contains(kept.last)) {
      kept.removeLast();
    }
    if (kept.isEmpty) continue;

    // If more than one token, avoid connector-only results again.
    final result = kept.join(' ');
    if (result.isEmpty) continue;

    final key = result.toLowerCase();
    if (seen.add(key)) cleaned.add(result);
  }

  return cleaned;
}
