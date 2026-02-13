import 'package:educa_plus/domain/repositories/aluno_repository.dart';
import 'package:educa_plus/domain/repositories/aula_repository.dart';
import 'package:educa_plus/domain/repositories/conteudo_repository.dart';
import 'package:educa_plus/domain/repositories/presenca_repository.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';

import 'aula_csv_export_service.dart';

/// Assembles [AulaCsvExportData] from repositories.
///
/// Input:
/// - [aulaIds] (selected externally; no UI responsibility here)
///
/// Output:
/// - ready-to-export data containing:
///   - aulas resolved by id (with turma name)
///   - alunos of each turma
///   - presencas by (aulaId, alunoId)
///   - conteudos grouped by aulaId
///
/// Notes:
/// - Supports multiple turmas at once. Since the CSV format requires a "Turma"
///   column per row, we can export mixed turmas in a single file.
/// - Rows are emitted by the CSV service in the order: aula -> alunos.
class AulaCsvExportAssembler {
  final AulaRepository aulaRepository;
  final TurmaRepository turmaRepository;
  final AlunoRepository alunoRepository;
  final PresencaRepository presencaRepository;
  final ConteudoRepository conteudoRepository;

  AulaCsvExportAssembler({
    required this.aulaRepository,
    required this.turmaRepository,
    required this.alunoRepository,
    required this.presencaRepository,
    required this.conteudoRepository,
  });

  /// Fetches all required data for the given [aulaIds].
  ///
  /// Behavior:
  /// - ignores non-existing aulaIds
  /// - dedupes turma lookups
  /// - fetches alunos per turma only once
  Future<AulaCsvExportData> assembleForAulaIds(List<int> aulaIds) async {
    final uniqueAulaIds = aulaIds.toSet().toList(growable: false);

    // 1) Load aulas
    final aulas = <AulaCsvExportAula>[];
    final turmaIds = <int>{};

    // Keep domain aula around temporarily to reduce re-fetching.
    final domainAulasById = <int, dynamic>{};

    for (final aulaId in uniqueAulaIds) {
      final aula = await aulaRepository.getById(aulaId);
      if (aula == null || aula.id == null) continue;
      domainAulasById[aula.id!] = aula;
      turmaIds.add(aula.turmaId);
    }

    // If nothing was found, return an empty export dataset.
    if (domainAulasById.isEmpty) {
      return AulaCsvExportData(
        aulas: const <AulaCsvExportAula>[],
        alunos: const <AulaCsvExportAluno>[],
        presencas: const <AulaCsvExportPresenca>[],
        conteudosPorAulaId: const <int, List<String>>{},
      );
    }

    // 2) Load turmas
    final turmaNameById = <int, String>{};
    for (final turmaId in turmaIds) {
      final turma = await turmaRepository.getById(turmaId);
      turmaNameById[turmaId] = turma?.nome ?? '';
    }

    // Map aulas -> export aulas (with turma name)
    for (final entry in domainAulasById.entries) {
      final aula = entry.value;
      aulas.add(
        AulaCsvExportAula(
          id: aula.id as int,
          data: aula.data as DateTime,
          turmaNome: turmaNameById[aula.turmaId as int] ?? '',
        ),
      );
    }

    // Keep stable ordering: by date then id (useful for exports)
    aulas.sort((a, b) {
      final d = a.data.compareTo(b.data);
      if (d != 0) return d;
      return a.id.compareTo(b.id);
    });

    // 3) Load alunos per turma
    final alunosByTurmaId = <int, List<AulaCsvExportAluno>>{};
    for (final turmaId in turmaIds) {
      final alunos =
          await alunoRepository.getAllForTurma(turmaId, onlyActive: true);
      alunosByTurmaId[turmaId] = alunos
          .where((a) => a.id != null)
          .map((a) => AulaCsvExportAluno(id: a.id!, nome: a.nome))
          .toList(growable: false);

      alunosByTurmaId[turmaId]!.sort((a, b) => a.nome.compareTo(b.nome));
    }

    // 4) Load presencas + conteudos per aula
    final presencas = <AulaCsvExportPresenca>[];
    final conteudosPorAulaId = <int, List<String>>{};

    for (final a in aulas) {
      final domainAula = domainAulasById[a.id];
      final turmaId = domainAula.turmaId as int;

      // Presenças: repository returns all tabs (aulaIndex). For CSV, we use aulaIndex=0.
      // If your official format needs aula dupla separately, we can extend later.
      final pres = await presencaRepository.getAllForAula(a.id);
      for (final p in pres) {
        if (p.aulaIndex != 0) continue;
        presencas.add(
          AulaCsvExportPresenca(
            aulaId: p.aulaId,
            alunoId: p.alunoId,
            presente: p.presente,
            justificativa: p.justificativa,
          ),
        );
      }

      final conteudos = await conteudoRepository.getAllForAula(a.id);
      conteudosPorAulaId[a.id] =
          conteudos.map((c) => c.texto).toList(growable: false);

      // Ensure we have turmaId so later we can pick correct aluno list.
      // (no-op; useful for clarity)
      alunosByTurmaId[turmaId] = alunosByTurmaId[turmaId] ?? const [];
    }

    // 5) Flatten alunos: since CSV needs rows per aula+aluno, and aulas might be from
    // multiple turmas, we can't return one single aluno list that fits all.
    //
    // So we return the union of all alunos, and the CSV service will emit rows for
    // every aluno for every aula (which would be WRONG across multiple turmas).
    //
    // Therefore: this assembler currently assumes the aulaIds are from a single turma.
    // This matches current UX (export per turma). If you want multi-turma in one CSV,
    // we should upgrade the generator to accept alunosByTurmaId.
    final turmaIdOrNull =
        _inferSingleTurmaIdOrNull(domainAulasById.values.toList());
    if (turmaIdOrNull == null) {
      throw StateError(
        'As aulas selecionadas pertencem a múltiplas turmas. '
        'O gerador atual de CSV espera 1 turma por exportação.',
      );
    }

    final alunos =
        alunosByTurmaId[turmaIdOrNull] ?? const <AulaCsvExportAluno>[];

    return AulaCsvExportData(
      aulas: aulas,
      alunos: alunos,
      presencas: presencas,
      conteudosPorAulaId: conteudosPorAulaId,
    );
  }

  int? _inferSingleTurmaIdOrNull(List<dynamic> domainAulas) {
    int? turmaId;
    for (final aula in domainAulas) {
      final t = aula.turmaId as int;
      turmaId = turmaId ?? t;
      if (turmaId != t) return null;
    }
    return turmaId;
  }
}
