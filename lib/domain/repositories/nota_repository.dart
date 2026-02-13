/// Offline-first repository for grades (notas) linked to an aula.
///
/// We keep two layers:
/// - NotaAula: metadata about the grade component for the aula (tipo + valorTotal)
/// - NotaAluno: per-student value (nullable in UI, but persisted only when set)
abstract class NotaRepository {
  Future<NotaAula?> getNotaAula(int aulaId);

  Future<List<NotaAluno>> getNotasAluno(int aulaId);

  /// Upserts ONLY NotaAula (metadata) for a given aula.
  ///
  /// Important: This must NOT touch any existing `notas_aluno` rows.
  ///
  /// Used for silent persistence when the user starts typing student grades.
  Future<void> upsertNotaAulaOnly({
    required int aulaId,
    required String tipo,
    required double? valorTotal,
    required String? titulo,
  });

  /// Replace all grade data for a given aula.
  ///
  /// Strategy:
  /// - delete previous NotaAula + NotaAluno for the aulaId
  /// - insert the provided data
  /// - ignore alunos with null value
  Future<void> replaceForAula({
    required int aulaId,
    required String tipo,
    required double? valorTotal,
    required Map<int, double?> notasPorAluno, // alunoId -> valor
  });
}

class NotaAula {
  final int aulaId;
  final String tipo; // avaliacao | prova | trabalho
  final double? valorTotal;
  final String? titulo;

  NotaAula({
    required this.aulaId,
    required this.tipo,
    required this.valorTotal,
    required this.titulo,
  });
}

class NotaAluno {
  final int aulaId;
  final int alunoId;
  final double valor;

  NotaAluno({
    required this.aulaId,
    required this.alunoId,
    required this.valor,
  });
}
