/// Filtering helpers for the Turmas list.
///
/// Notes:
/// - We don't have dedicated fields in the database for instituição/série/letra.
/// - `Turma.nome` is stored as a single composed string: "<instituição> <série> <letra>".
/// - This filter applies best-effort parsing without mutating data.
library;

import 'package:educa_plus/domain/entities/turma.dart';

class TurmaFilter {
  final String query;
  final int? serieNumero; // 1..10
  final String? letra; // A..Z
  final String? disciplinaQuery;
  final bool? ativa;

  const TurmaFilter({
    this.query = '',
    this.serieNumero,
    this.letra,
    this.disciplinaQuery,
    this.ativa,
  });

  bool get isEmpty {
    return query.trim().isEmpty &&
        serieNumero == null &&
        (letra == null || letra!.trim().isEmpty) &&
        (disciplinaQuery == null || disciplinaQuery!.trim().isEmpty) &&
        ativa == null;
  }

  TurmaFilter copyWith({
    String? query,
    int? serieNumero,
    String? letra,
    String? disciplinaQuery,
    bool? ativa,
    bool clearSerie = false,
    bool clearLetra = false,
    bool clearDisciplina = false,
    bool clearAtiva = false,
  }) {
    return TurmaFilter(
      query: query ?? this.query,
      serieNumero: clearSerie ? null : (serieNumero ?? this.serieNumero),
      letra: clearLetra ? null : (letra ?? this.letra),
      disciplinaQuery:
          clearDisciplina ? null : (disciplinaQuery ?? this.disciplinaQuery),
      ativa: clearAtiva ? null : (ativa ?? this.ativa),
    );
  }

  static TurmaFilter empty() => const TurmaFilter();
}

String _norm(String s) => s.trim().toLowerCase();

List<Turma> applyTurmaFilter(List<Turma> turmas, TurmaFilter filter) {
  if (filter.isEmpty) return turmas;

  final q = _norm(filter.query);
  final discQ = _norm(filter.disciplinaQuery ?? '');
  final letra = filter.letra?.trim().toUpperCase();

  return turmas.where((t) {
    if (filter.serieNumero != null) {
      if (t.anoLetivo != filter.serieNumero) return false;
    }

    if (letra != null && letra.isNotEmpty) {
      final tokens = t.nome.trim().split(RegExp(r'\s+'));
      final last = tokens.isEmpty ? '' : tokens.last.toUpperCase();
      if (last != letra) return false;
    }

    if (discQ.isNotEmpty) {
      final d = _norm(t.disciplina ?? '');
      if (!d.contains(discQ)) return false;
    }

    if (q.isNotEmpty) {
      // Best-effort: search in the full composed name.
      // Since `Turma.nome` begins with the institution, this works well for institution search.
      final nome = _norm(t.nome);
      if (!nome.contains(q)) return false;
    }

    return true;
  }).toList();
}
