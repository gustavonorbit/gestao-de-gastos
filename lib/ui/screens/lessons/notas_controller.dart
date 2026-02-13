import 'package:flutter/foundation.dart';

import 'package:educa_plus/domain/repositories/aluno_repository.dart';
import 'package:educa_plus/domain/repositories/nota_repository.dart';

/// Controller (pure business logic) for the Notas screen.
///
/// Design goals:
/// - No UI dependency (no BuildContext)
/// - Offline-first: uses repositories injected (can be faked in tests)
/// - Explicit save (no autosave)
/// - Keeps original vs edited state
class NotasController extends ChangeNotifier {
  final int aulaId;
  final int turmaId;
  final AlunoRepository alunoRepository;
  final NotaRepository notaRepository;

  NotasController({
    required this.aulaId,
    required this.turmaId,
    required this.alunoRepository,
    required this.notaRepository,
  });

  bool _loading = false;
  bool get loading => _loading;

  bool _houveAlteracao = false;
  bool get houveAlteracao => _houveAlteracao;

  // Loaded students
  List<AlunoVm> _alunos = const <AlunoVm>[];
  List<AlunoVm> get alunos => _alunos;

  // Original state
  NotaTipo? _tipoOriginal;
  double? _valorTotalOriginal;
  String? _tituloOriginal;
  final Map<int, double?> _notasPorAlunoOriginal = <int, double?>{};

  // Edited state
  NotaTipo _tipoEditado = NotaTipo.avaliacao;
  double? _valorTotalEditado;
  String? _tituloEditado;
  final Map<int, double?> _notasPorAlunoEditado = <int, double?>{};

  // Domain rule: persist NotaAula (tipo + valorTotal) silently when the user
  // starts typing student grades. This flag is per-controller-session.
  bool _notaAulaSilentlyPersisted = false;

  // Debug guard: `replaceForAula` is destructive (delete+insert).
  // It must only be executed from `save()`.
  bool _debugAllowReplaceForAula = false;

  NotaTipo get tipoEditado => _tipoEditado;
  double? get valorTotalEditado => _valorTotalEditado;
  String? get tituloEditado => _tituloEditado;

  double? notaAlunoEditada(int alunoId) => _notasPorAlunoEditado[alunoId];
  double? notaAlunoOriginal(int alunoId) => _notasPorAlunoOriginal[alunoId];

  NotaTipo? get tipoOriginal => _tipoOriginal;
  double? get valorTotalOriginal => _valorTotalOriginal;
  String? get tituloOriginal => _tituloOriginal;

  /// Loads initial state from repositories.
  ///
  /// If no persisted data exists, keeps defaults and marks as not dirty.
  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      final alunosDomain =
          await alunoRepository.getAllForTurma(turmaId, onlyActive: true);
      _alunos = alunosDomain
          .where((a) => a.id != null)
          .map((a) => AlunoVm(id: a.id!, nome: a.nome))
          .toList(growable: false);

      final notaAula = await notaRepository.getNotaAula(aulaId);
      final notasAluno = await notaRepository.getNotasAluno(aulaId);

      _tipoOriginal = NotaTipoX.fromStored(notaAula?.tipo);
      _valorTotalOriginal = notaAula?.valorTotal;
      _tituloOriginal = notaAula?.titulo;
      _notasPorAlunoOriginal
        ..clear()
        ..addEntries(notasAluno.map((n) => MapEntry(n.alunoId, n.valor)));

      // draft starts as original
      _tipoEditado = _tipoOriginal ?? NotaTipo.avaliacao;
      _valorTotalEditado = _valorTotalOriginal;
      _tituloEditado = _tituloOriginal;
      _notasPorAlunoEditado
        ..clear()
        ..addAll(_notasPorAlunoOriginal);

      _houveAlteracao = false;
      _notaAulaSilentlyPersisted = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setTipo(NotaTipo tipo) {
    _tipoEditado = tipo;
    _markDirty();
    // Ensure UI updates even after the first change.
    notifyListeners();
  }

  void setValorTotal(double? valor) {
    _valorTotalEditado = _sanitizeValorTotal(valor);
    _markDirty();
  }

  void setTitulo(String? titulo) {
    final t = (titulo ?? '').trim();
    _tituloEditado = t.isEmpty ? null : t;
    _markDirty();
    // Ensure UI reflects the current title immediately.
    notifyListeners();
  }

  /// Sets a student's grade to [valor]. Use null to clear.
  ///
  /// Domain rules (MVP):
  /// - When `valorTotal` is defined, clamps the student's grade to it.
  /// - Always normalizes numbers to a single decimal when possible
  ///   (e.g. 2 -> 2.0, 2.34 -> 2.3).
  /// - Applies only to the value being edited (no retroactive changes).
  /// - On the FIRST student grade edit, if `tipo` and `valorTotal` are defined,
  ///   silently persists NotaAula (tipo + valorTotal) WITHOUT persisting grades.
  Future<void> setNotaAluno(int alunoId, double? valor) async {
    final sanitized = _sanitizeNotaAluno(valor);
    _notasPorAlunoEditado[alunoId] = sanitized;
    _markDirty();

    await _maybePersistNotaAulaSilently();
  }

  double? _sanitizeNotaAluno(double? raw) {
    if (raw == null) return null;

    final normalized = _roundToOneDecimal(raw);

    // Activate rule only when config is ready.
    final max = _valorTotalEditado;
    if (max == null) return normalized;

    if (normalized > max) return _roundToOneDecimal(max);
    return normalized;
  }

  double? _sanitizeValorTotal(double? raw) {
    if (raw == null) return null;
    final normalized = _roundToOneDecimal(raw);
    if (normalized > 10.0) return 10.0;
    if (normalized < 0) return 0.0;
    return normalized;
  }

  bool get _isConfigReadyForSanitization {
    // `tipo` is always set in current UI (defaults), but keep explicit gating.
    return _valorTotalEditado != null;
  }

  Future<void> _maybePersistNotaAulaSilently() async {
    if (_loading) return;
    if (_notaAulaSilentlyPersisted) return;
    if (!_isConfigReadyForSanitization) return;

    // Persist only aula config (tipo + valorTotal) silently.
    // Title is persisted ONLY on explicit Save.
    await notaRepository.upsertNotaAulaOnly(
      aulaId: aulaId,
      tipo: _tipoEditado.toStored(),
      valorTotal: _valorTotalEditado,
      titulo: null,
    );

    _notaAulaSilentlyPersisted = true;
  }

  /// Parsing helper for MVP: accepts comma or dot.
  static double? parseDoubleLoose(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final normalized = t.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Formats double for pt-BR visual (comma).
  static String formatPtBr(double value) =>
      value.toString().replaceAll('.', ',');

  static double _roundToOneDecimal(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  /// Saves only if there were changes.
  ///
  /// After successful save:
  /// - updates original snapshot
  /// - sets [houveAlteracao] to false
  Future<void> save() async {
    if (!_houveAlteracao) return;

    // Final sanitization on explicit save (no UX impact while typing).
    _valorTotalEditado = _sanitizeValorTotal(_valorTotalEditado);

    // Persist NotaAula (including title) explicitly on Save.
    // This must happen before saving student grades.
    await notaRepository.upsertNotaAulaOnly(
      aulaId: aulaId,
      tipo: _tipoEditado.toStored(),
      valorTotal: _valorTotalEditado,
      titulo: _tituloEditado,
    );

    final max = _valorTotalEditado;
    if (max != null) {
      for (final e in _notasPorAlunoEditado.entries.toList(growable: false)) {
        final v = e.value;
        if (v == null) continue;

        var out = _roundToOneDecimal(v);
        if (out < 0) out = 0.0;
        if (out > max) out = _roundToOneDecimal(max);
        _notasPorAlunoEditado[e.key] = out;
      }
    } else {
      // Even without a max, ensure negatives are clamped and numbers normalized.
      for (final e in _notasPorAlunoEditado.entries.toList(growable: false)) {
        final v = e.value;
        if (v == null) continue;

        var out = _roundToOneDecimal(v);
        if (out < 0) out = 0.0;
        _notasPorAlunoEditado[e.key] = out;
      }
    }

    assert(() {
      _debugAllowReplaceForAula = true;
      return true;
    }());

    try {
      await _replaceForAulaFromSave();
    } finally {
      assert(() {
        _debugAllowReplaceForAula = false;
        return true;
      }());
    }

    // Reset per-session silent flag after an explicit save.
    _notaAulaSilentlyPersisted = false;

    _tipoOriginal = _tipoEditado;
    _valorTotalOriginal = _valorTotalEditado;
    _tituloOriginal = _tituloEditado;
    _notasPorAlunoOriginal
      ..clear()
      ..addAll(_notasPorAlunoEditado);

    _houveAlteracao = false;
    notifyListeners();
  }

  Future<void> _replaceForAulaFromSave() async {
    assert(
      _debugAllowReplaceForAula,
      'replaceForAula() must only be executed from NotasController.save()',
    );

    await notaRepository.replaceForAula(
      aulaId: aulaId,
      tipo: _tipoEditado.toStored(),
      valorTotal: _valorTotalEditado,
      notasPorAluno: _notasPorAlunoEditado,
    );
  }

  /// Pure decision helper: should show discard confirmation?
  bool shouldConfirmDiscard() => _houveAlteracao;

  void _markDirty() {
    if (_loading) return;
    if (_houveAlteracao) return;
    _houveAlteracao = true;
    notifyListeners();
  }
}

class AlunoVm {
  final int id;
  final String nome;

  const AlunoVm({required this.id, required this.nome});
}

enum NotaTipo {
  avaliacao,
  prova,
  trabalho,
}

extension NotaTipoX on NotaTipo {
  String toStored() {
    switch (this) {
      case NotaTipo.avaliacao:
        return 'avaliacao';
      case NotaTipo.prova:
        return 'prova';
      case NotaTipo.trabalho:
        return 'trabalho';
    }
  }

  static NotaTipo? fromStored(String? tipo) {
    switch ((tipo ?? '').trim()) {
      case 'avaliacao':
        return NotaTipo.avaliacao;
      case 'prova':
        return NotaTipo.prova;
      case 'trabalho':
        return NotaTipo.trabalho;
    }
    return null;
  }
}
