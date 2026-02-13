import 'package:intl/intl.dart';

import 'csv_export_utils.dart';
import 'conteudo_export_helper.dart';

/// Minimal DTOs for generating the official CSV.
///
/// These are intentionally decoupled from Drift/domain entities.
class AulaCsvExportAula {
  final int id;
  final DateTime data;

  /// Human-readable turma name (required by output spec).
  final String turmaNome;

  AulaCsvExportAula({
    required this.id,
    required this.data,
    required this.turmaNome,
  });
}

class AulaCsvExportAluno {
  final int id;
  final String nome;

  AulaCsvExportAluno({
    required this.id,
    required this.nome,
  });
}

class AulaCsvExportPresenca {
  final int aulaId;
  final int alunoId;
  final bool presente;
  final String? justificativa;

  AulaCsvExportPresenca({
    required this.aulaId,
    required this.alunoId,
    required this.presente,
    this.justificativa,
  });
}

/// Input bag: one turma worth of data.
///
/// The generator itself is pure; fetch from repositories outside.
class AulaCsvExportData {
  final List<AulaCsvExportAula> aulas;
  final List<AulaCsvExportAluno> alunos;

  /// Presence entries for (aula, aluno). If missing, defaults to "F".
  final List<AulaCsvExportPresenca> presencas;

  /// Contents per aulaId; each aulaId can have multiple content strings.
  final Map<int, List<String>> conteudosPorAulaId;

  AulaCsvExportData({
    required this.aulas,
    required this.alunos,
    required this.presencas,
    required this.conteudosPorAulaId,
  });
}

/// Generates the official CSV format:
///
/// Columns (order required):
/// 1. Data da Aula (DD/MM/AAAA)
/// 2. Turma
/// 3. Nome do Aluno
/// 4. Presença (P/F)
/// 5. Justificativa
/// 6. Conteúdo da Aula (single cell; items joined by '; ')
class AulaCsvExportService {
  final DateFormat _dateBr = DateFormat('dd/MM/yyyy');

  /// Generates CSV content as a [String].
  ///
  /// - [separator] defaults to ',' (CSV base for Excel).
  /// - Always quotes fields (see [CsvExportUtils]).
  String buildCsv(
    AulaCsvExportData data, {
    String separator = ',',
    String lineEnding = '\n',
  }) {
    final buffer = StringBuffer();

    // Header (exact order requested)
    buffer.writeln(CsvExportUtils.row(
      const [
        'Data da Aula',
        'Turma',
        'Nome do Aluno',
        'Presença',
        'Justificativa',
        'Conteúdo da Aula',
      ],
      separator: separator,
    ));

    final presencaMap = <String, AulaCsvExportPresenca>{};
    for (final p in data.presencas) {
      presencaMap['${p.aulaId}|${p.alunoId}'] = p;
    }

    for (final aula in data.aulas) {
      final conteudos = data.conteudosPorAulaId[aula.id] ?? const <String>[];
      final conteudoFinal = buildConteudoTextoFinal(conteudos);

      for (final aluno in data.alunos) {
        final pres = presencaMap['${aula.id}|${aluno.id}'];

        // Required mapping:
        // - P for present
        // - F for absent
        // If no record exists, we treat as absent (F) per earlier screen fallback.
        final presente = pres?.presente ?? false;
        final presencaTexto = presente ? 'P' : 'F';

        // Justificativa only if F; empty if P.
        final justificativa = presente ? '' : (pres?.justificativa ?? '');

        final row = CsvExportUtils.row(
          [
            _dateBr.format(aula.data),
            aula.turmaNome,
            aluno.nome,
            presencaTexto,
            justificativa,
            conteudoFinal,
          ],
          separator: separator,
        );

        buffer.write(row);
        buffer.write(lineEnding);
      }
    }

    return buffer.toString();
  }
}
