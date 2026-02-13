import 'package:educa_plus/domain/repositories/nota_repository.dart';

class FakeNotaRepository implements NotaRepository {
  /// aulaId -> NotaAula
  final Map<int, NotaAula> notaAulaByAulaId;

  /// aulaId -> (alunoId -> valor)
  final Map<int, Map<int, double>> notasAlunoByAulaId;

  int replaceCalls = 0;
  int upsertNotaAulaOnlyCalls = 0;

  FakeNotaRepository({
    Map<int, NotaAula>? notaAulaByAulaId,
    Map<int, Map<int, double>>? notasAlunoByAulaId,
  })  : notaAulaByAulaId = notaAulaByAulaId ?? <int, NotaAula>{},
        notasAlunoByAulaId = notasAlunoByAulaId ?? <int, Map<int, double>>{};

  @override
  Future<NotaAula?> getNotaAula(int aulaId) async {
    return notaAulaByAulaId[aulaId];
  }

  @override
  Future<List<NotaAluno>> getNotasAluno(int aulaId) async {
    final map = notasAlunoByAulaId[aulaId] ?? const <int, double>{};
    return map.entries
        .map((e) => NotaAluno(aulaId: aulaId, alunoId: e.key, valor: e.value))
        .toList(growable: false);
  }

  @override
  Future<void> upsertNotaAulaOnly({
    required int aulaId,
    required String tipo,
    required double? valorTotal,
    required String? titulo,
  }) async {
    upsertNotaAulaOnlyCalls++;

    final previous = notaAulaByAulaId[aulaId];
    notaAulaByAulaId[aulaId] = NotaAula(
      aulaId: aulaId,
      tipo: tipo,
      valorTotal: valorTotal,
      titulo: titulo,
    );

    // Important: do NOT mutate notasAlunoByAulaId here.
    // (this method is explicitly NotaAula-only)
    if (previous == null) {
      notasAlunoByAulaId.putIfAbsent(aulaId, () => <int, double>{});
    }
  }

  @override
  Future<void> replaceForAula({
    required int aulaId,
    required String tipo,
    required double? valorTotal,
    required Map<int, double?> notasPorAluno,
  }) async {
    replaceCalls++;

    final existingTitulo = notaAulaByAulaId[aulaId]?.titulo;

    // Replace strategy:
    notaAulaByAulaId[aulaId] = NotaAula(
      aulaId: aulaId,
      tipo: tipo,
      valorTotal: valorTotal,
      titulo: existingTitulo,
    );

    final cleaned = <int, double>{};
    for (final e in notasPorAluno.entries) {
      if (e.value == null) continue;
      cleaned[e.key] = e.value!;
    }
    notasAlunoByAulaId[aulaId] = cleaned;
  }
}
