abstract class PresencaRepository {
  /// Upsert a single attendance record for (aulaId, alunoId, aulaIndex).
  Future<void> upsert({
    required int aulaId,
    required int alunoId,
    required int aulaIndex,
    required bool presente,
    String? justificativa,
  });

  /// Upsert many attendance records.
  Future<void> upsertMany(List<PresencaUpsert> entries);

  /// Fetch all presence records for a given aula.
  Future<List<PresencaRecord>> getAllForAula(int aulaId);
}

class PresencaUpsert {
  final int aulaId;
  final int alunoId;
  final int aulaIndex;
  final bool presente;
  final String? justificativa;

  PresencaUpsert({
    required this.aulaId,
    required this.alunoId,
    required this.aulaIndex,
    required this.presente,
    this.justificativa,
  });
}

class PresencaRecord {
  final int id;
  final int aulaId;
  final int alunoId;
  final int aulaIndex;
  final bool presente;
  final String? justificativa;

  PresencaRecord({
    required this.id,
    required this.aulaId,
    required this.alunoId,
    required this.aulaIndex,
    required this.presente,
    this.justificativa,
  });
}
