import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:educa_plus/utils/academic_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform, Directory, File;

/// DTOs used by the export service. Kept simple and decoupled from the
/// domain layer so the service can be used independently of the DB.
class ExportAluno {
  final int id;
  final String nome;

  ExportAluno({required this.id, required this.nome});
}

class ExportAula {
  final int id;
  final DateTime data;
  final String? conteudo;
  final List<String> observacoes;
  final int presencaAbas;

  ExportAula({required this.id, required this.data, this.conteudo, this.presencaAbas = 1, this.observacoes = const <String>[]});
}

class ExportPresenca {
  final int aulaId;
  final int alunoId;
  final int aulaIndex;
  final bool presente;
  final String? justificativa;

  ExportPresenca({
    required this.aulaId,
    required this.alunoId,
    int? aulaIndex,
    required this.presente,
    this.justificativa,
  }) : aulaIndex = aulaIndex ?? 0;
}

class ExportNota {
  final int aulaId;
  final int alunoId;
  final String? tipo;
  final double? valor;
  final String? titulo;

  ExportNota(
    {required this.aulaId, required this.alunoId, this.tipo, this.valor, this.titulo});
}

class TurmaExportData {
  final String turmaName;
  final List<ExportAluno> alunos;
  final List<ExportAula> aulas;
  final List<ExportPresenca> presencas;
  final List<ExportNota> notas;

  TurmaExportData(
      {required this.turmaName,
      required this.alunos,
      required this.aulas,
      required this.presencas,
      required this.notas});
}

/// Service that exports one or more turmas into a single .xlsx file.
class ExportService {
  // Export service for building XLSX files

  /// Export multiple turmas. Returns the generated file path.
  /// If [saveToDownloads] is true the service will try to save the file on
  /// the platform 'Downloads' directory (Android). If not available or not
  /// permitted, it falls back to the application documents directory.
  Future<String> exportTurmasToXlsx(List<TurmaExportData> turmas,
      {String? filename, bool saveToDownloads = false}) async {
    final excel = Excel.createExcel();

    // CRITICAL: Immediately remove any default sheet named 'Sheet1' that the
    // library may have created. This must happen before creating or writing
    // any other sheets to avoid readers (e.g. Google Sheets) keeping a
    // previously-existing blank sheet.
    try {
      final defaultSheet = excel.getDefaultSheet();
      if (defaultSheet != null) {
        // delete by returned identifier (some versions return name or Sheet)
        excel.delete(defaultSheet);
      }
    } catch (_) {
      // ignore deletion errors and continue to explicit key check below
    }

    // Also defensively delete any sheet registered under the literal name
    // 'Sheet1' if present.
    try {
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }
    } catch (_) {
      // ignore
    }

    // Define the four required sheet names (no suffixes). Create them in the
    // exact order required so the resulting file opens on the first sheet.
    final geralSheetName = _sanitizeSheetName('Visão Geral');
    final presencaSheetName = _sanitizeSheetName('Presença');
    final notasSheetName = _sanitizeSheetName('Notas');
    final combinedName = _sanitizeSheetName('Conteúdos e Observações');

  // Access/create sheets in the required order to ensure workbook order.
  // Sheets will be created on first access. We intentionally create only
  // these four sheets and avoid any extra/legacy sheets.
  excel[geralSheetName];
  excel[presencaSheetName];
  excel[notasSheetName];
  excel[combinedName];

    // Helper to ensure consistent top header (3 rows) on every sheet. This
    // is idempotent: it only writes the header when the sheet is empty.
    void ensureSheetHeader(Sheet sheet, String title, String turmaName) {
      if (sheet.maxRows == 0) {
        // Line 1: Title (bold, larger)
        sheet.appendRow([TextCellValue(title)]);
        final r1 = sheet.maxRows - 1;
        final c1 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r1));
        c1.cellStyle = CellStyle(bold: true);

        // Line 2: Turma name (subtitle)
        sheet.appendRow([TextCellValue('Turma: $turmaName')]);
        final r2 = sheet.maxRows - 1;
        final c2 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r2));
        c2.cellStyle = CellStyle(bold: true);

        // Line 3: empty spacer
        sheet.appendRow([TextCellValue('')]);
      }
    }

    for (final turma in turmas) {

      // Build lookup maps for quick access. We MUST index presenças by
      // aulaId -> aulaIndex -> alunoId -> ExportPresenca so we don't lose
      // distinct presenças for different aulaIndex values or different alunos.
      // This ensures each aulaIndex is treated independently per student.
      final presencaByAula = <int, Map<int, Map<int, ExportPresenca>>>{};
      for (final p in turma.presencas) {
        presencaByAula
            .putIfAbsent(p.aulaId, () => <int, Map<int, ExportPresenca>>{})
            .putIfAbsent(p.aulaIndex, () => <int, ExportPresenca>{})[p.alunoId] = p;
      }

      final notaMap = <String, ExportNota>{};
      for (final n in turma.notas) {
        notaMap['${n.aulaId}|${n.alunoId}'] = n;
      }

      // === PRESENÇA sheet (monthly vertical blocks, per-month student maps) ===
  final presSheet = excel[presencaSheetName];
  ensureSheetHeader(presSheet, 'Presença', turma.turmaName);

      // Group aulas by month (year-month) and sort
      final aulasByMonth = <String, List<ExportAula>>{};
      for (final aula in turma.aulas) {
        final key = '${aula.data.year}-${aula.data.month}';
        aulasByMonth.putIfAbsent(key, () => <ExportAula>[]).add(aula);
      }
      final monthKeys = aulasByMonth.keys.toList()
        ..sort((a, b) {
          final pa = a.split('-');
          final pb = b.split('-');
          final ya = int.parse(pa[0]);
          final ma = int.parse(pa[1]);
          final yb = int.parse(pb[0]);
          final mb = int.parse(pb[1]);
          return DateTime(ya, ma).compareTo(DateTime(yb, mb));
        });

      // For each month, create a full block: month title, header, student rows, fill cells
      for (final monthKey in monthKeys) {
        final parts = monthKey.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final aulas = (aulasByMonth[monthKey] ?? <ExportAula>[])..sort((a, b) => a.data.compareTo(b.data));

        if (aulas.isEmpty) continue; // nothing to export for this month

        // Group aulas by calendar date (yyyy-MM-dd) so multiple aulas on the same
        // day (aula dupla) become a single column. Preserve chronological order.
        final aulasByDate = <String, List<ExportAula>>{}; // key: yyyy-MM-dd
        for (final a in aulas) {
          final k = '${a.data.year.toString().padLeft(4, '0')}-${a.data.month.toString().padLeft(2, '0')}-${a.data.day.toString().padLeft(2, '0')}';
          aulasByDate.putIfAbsent(k, () => <ExportAula>[]).add(a);
        }
        final dateKeys = aulasByDate.keys.toList()
          ..sort((a, b) {
            final da = a.split('-');
            final db = b.split('-');
            final ya = int.parse(da[0]);
            final ma = int.parse(da[1]);
            final daDay = int.parse(da[2]);
            final yb = int.parse(db[0]);
            final mb = int.parse(db[1]);
            final dbDay = int.parse(db[2]);
            return DateTime(ya, ma, daDay).compareTo(DateTime(yb, mb, dbDay));
          });

        // 1) Month title row
        final monthName = DateFormat.MMMM('pt_BR').format(DateTime(year, month));
        presSheet.appendRow([TextCellValue('$monthName / $year')]);
        final titleRowIndex = presSheet.maxRows - 1;
        final titleCell = presSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: titleRowIndex));
        titleCell.cellStyle = CellStyle(bold: true);

        // 2) Header row: Aluno | date columns (DD/MM) | Justificativa
        final headerCells = <CellValue?>[];
        headerCells.add(TextCellValue('Aluno'));
        final orderedDates = <DateTime>[];
        for (final dk in dateKeys) {
          final parts = dk.split('-');
          final y = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final d = int.parse(parts[2]);
          final dt = DateTime(y, m, d);
          orderedDates.add(dt);
          headerCells.add(TextCellValue(DateFormat('dd/MM').format(dt)));
        }
        headerCells.add(TextCellValue('Justificativa'));
        presSheet.appendRow(headerCells);
        final headerRowIndex = presSheet.maxRows - 1;
        for (var c = 0; c < headerCells.length; c++) {
          final cell = presSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: headerRowIndex));
          cell.cellStyle = CellStyle(bold: true);
        }

        // 3) Build month-specific student map
        final alunoMapMonth = <int, ExportAluno>{};
        for (final a in turma.alunos) {
          alunoMapMonth[a.id] = a;
        }
        final aulasIds = aulas.map((e) => e.id).toSet();
        for (final p in turma.presencas) {
          if (aulasIds.contains(p.aulaId) && !alunoMapMonth.containsKey(p.alunoId)) {
            alunoMapMonth[p.alunoId] = ExportAluno(id: p.alunoId, nome: 'Aluno ${p.alunoId}');
          }
        }

        final alunosMonth = alunoMapMonth.values.toList(growable: false);

        // 4) Create rows for students for this month only (one row per student)
        final alunoRowIndexMap = <int, int>{};
        var rowCursor = presSheet.maxRows; // next row index to append
        for (final aluno in alunosMonth) {
          if (alunoRowIndexMap.containsKey(aluno.id)) {
            assert(false, 'Aluno duplicado no mesmo mês na exportação: ${aluno.nome}');
            continue;
          }
          alunoRowIndexMap[aluno.id] = rowCursor;

          final row = <CellValue?>[];
          row.add(TextCellValue(aluno.nome));
          for (var i = 0; i < orderedDates.length; i++) {
            row.add(TextCellValue('-'));
          }
          row.add(TextCellValue(''));
          presSheet.appendRow(row);
          rowCursor += 1;
        }

        // 5) Fill presence cells: for each date column, concatenate per-aula statuses with '/'
        for (var dateColOffset = 0; dateColOffset < orderedDates.length; dateColOffset++) {
          final date = orderedDates[dateColOffset];
          final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final aulasThisDate = (aulasByDate[key] ?? <ExportAula>[])..sort((a, b) => a.data.compareTo(b.data));

          for (final aluno in alunosMonth) {
            final r = alunoRowIndexMap[aluno.id];
            if (r == null) continue;
            final c = 1 + dateColOffset; // column 0 is aluno name
            final cellIndex = CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r);
            final cell = presSheet.cell(cellIndex);

            final statuses = <String>[];
            for (final aula in aulasThisDate) {
              // For each aula, iterate its presence indices (0 .. presencaAbas-1)
              final maxIndex = (aula.presencaAbas <= 0) ? 1 : aula.presencaAbas;
              for (var idx = 0; idx < maxIndex; idx++) {
                // Lookup presence for this specific aluno and aulaIndex.
                final pres = presencaByAula[aula.id]?[idx]?[aluno.id];
                String s;
                if (pres == null) {
                  s = '-';
                } else if (pres.justificativa != null && pres.justificativa!.trim().isNotEmpty && !pres.presente) {
                  s = 'J';
                } else if (pres.presente) {
                  s = 'P';
                } else {
                  s = '-';
                }
                statuses.add(s);
              }
            }

            final joined = statuses.join('/');
            cell.value = TextCellValue(joined);

            // Apply styles only if all statuses are identical
            final uniq = statuses.toSet();
            if (uniq.length == 1) {
              final v = uniq.first;
              if (v == 'P') {
                cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString('#DFF0D8'), fontColorHex: ExcelColor.fromHexString('#000000'));
              } else if (v == 'J') {
                cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString('#F0F0F0'), fontColorHex: ExcelColor.fromHexString('#000000'));
              } else if (v == '-') {
                cell.cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString('#FBEAEA'), fontColorHex: ExcelColor.fromHexString('#000000'));
              }
            } else {
              // mixed statuses: keep default style
              cell.cellStyle = CellStyle();
            }
          }
        }

        // 6) Fill justificativa column per student (one line per justificativa).
        final justificativaCol = 1 + orderedDates.length;
        for (final aluno in alunosMonth) {
          final r = alunoRowIndexMap[aluno.id];
          if (r == null) continue;
          final justLines = <String>[];

          for (var di = 0; di < orderedDates.length; di++) {
            final date = orderedDates[di];
            final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final aulasThisDate = (aulasByDate[key] ?? <ExportAula>[])..sort((a, b) => a.data.compareTo(b.data));

            // collect justificativas for this aluno on this date (in chronological aula order)
            final dateJusts = <String>[];
            for (final aula in aulasThisDate) {
              final maxIndex = (aula.presencaAbas <= 0) ? 1 : aula.presencaAbas;
              for (var idx = 0; idx < maxIndex; idx++) {
                final pres = presencaByAula[aula.id]?[idx]?[aluno.id];
                if (pres?.justificativa != null && pres!.justificativa!.trim().isNotEmpty) {
                  dateJusts.add(pres.justificativa!.trim());
                }
              }
            }

            if (dateJusts.isEmpty) continue;

            final fecha = DateFormat('dd/MM').format(date);
            if (dateJusts.length == 1) {
              justLines.add('$fecha - ${dateJusts.first}');
            } else {
              // multiple justs on same date: include ordinal for each
              for (var i = 0; i < dateJusts.length; i++) {
                final ord = '${i + 1}ª aula';
                justLines.add('$fecha - ${dateJusts[i]} ($ord)');
              }
            }
          }

          final cell = presSheet.cell(CellIndex.indexByColumnRow(columnIndex: justificativaCol, rowIndex: r));
          cell.value = TextCellValue(justLines.join('\n'));
          cell.cellStyle = CellStyle();
        }

        // 7) After last aluno, skip 1 empty row before next month
        presSheet.appendRow([TextCellValue('')]);
        presSheet.appendRow([TextCellValue('')]);
      }

      // === Placeholder sheets ===
    // === NOTAS sheet ===
    // Build activities (one column per activity). We consider an activity
    // to be defined by an aulaId. Order: by aula date (using turma.aulas)
    // and by first occurrence. We avoid duplicate columns.
    final notasSheet = excel[notasSheetName];
    ensureSheetHeader(notasSheet, 'Notas', turma.turmaName);

      // Map aulaId -> ExportAula for date lookup
      final aulaById = <int, ExportAula>{};
      for (final a in turma.aulas) {
        aulaById[a.id] = a;
      }

      // Collect unique activity aulaIds in order of first appearance in turma.notas
      final notaAulaOrder = <int>[];
      final notaAulaSeen = <int>{};
      for (final n in turma.notas) {
        if (!notaAulaSeen.contains(n.aulaId)) {
          notaAulaSeen.add(n.aulaId);
          notaAulaOrder.add(n.aulaId);
        }
      }

      // If there are no activities with notas, still create an empty Notas sheet
      if (notaAulaOrder.isEmpty) {
        notasSheet.appendRow([TextCellValue('Notas')]);// placeholder
      } else {
        // Order activities primarily by date (if available in aulas), otherwise by firstSeen order
        notaAulaOrder.sort((a, b) {
          final aa = aulaById[a];
          final bb = aulaById[b];
          if (aa != null && bb != null) {
            final cmp = aa.data.compareTo(bb.data);
            if (cmp != 0) return cmp;
          } else if (aa != null && bb == null) {
            return -1;
          } else if (aa == null && bb != null) {
            return 1;
          }
          return 0; // keep firstSeen order for ties
        });

        // Build header rows (3 rows): name, date (DD/MM), Valor: X
        final headerRow1 = <CellValue?>[]; // Name of evaluation
        final headerRow2 = <CellValue?>[]; // Date DD/MM
        final headerRow3 = <CellValue?>[]; // Valor: X

        headerRow1.add(TextCellValue('Aluno'));
        headerRow1.add(TextCellValue('Total'));
        headerRow2.add(TextCellValue(''));
        headerRow2.add(TextCellValue(''));
        headerRow3.add(TextCellValue(''));
        headerRow3.add(TextCellValue(''));

        // For each activity (aulaId) determine header values
        for (final aulaId in notaAulaOrder) {
          // Name: prefer the professor-provided nota.titulo when present,
          // otherwise fall back to nota.tipo and finally a generic label.
          String name = 'Avaliação';
          // find first nota for this aula to extract title or tipo
          final firstNota = turma.notas.firstWhere((n) => n.aulaId == aulaId, orElse: () => turma.notas.first);
          if (firstNota.titulo != null && firstNota.titulo!.trim().isNotEmpty) {
            name = firstNota.titulo!.trim();
          } else if (firstNota.tipo != null && firstNota.tipo!.trim().isNotEmpty) {
            name = firstNota.tipo!.trim();
          }
          headerRow1.add(TextCellValue(name));

          final aula = aulaById[aulaId];
          if (aula != null) {
            headerRow2.add(TextCellValue(DateFormat('dd/MM').format(aula.data)));
          } else {
            headerRow2.add(TextCellValue('-'));
          }

          // Determine max value for this activity using available notas (best-effort)
          double? maxVal;
          for (final n in turma.notas) {
            if (n.aulaId == aulaId && n.valor != null) {
              if (maxVal == null || n.valor! > maxVal) maxVal = n.valor!;
            }
          }
          headerRow3.add(TextCellValue('Valor: ${maxVal != null ? maxVal.toString() : '-'}'));
        }

        notasSheet.appendRow(headerRow1);
        notasSheet.appendRow(headerRow2);
        notasSheet.appendRow(headerRow3);

        // Build student list: include all active alunos (from turma.alunos) and any alunoIds
        // present in notas (to include inactive students with notes). Avoid duplicates.
        final alunoMap = <int, ExportAluno>{};
        for (final a in turma.alunos) {
          alunoMap[a.id] = a;
        }
        for (final n in turma.notas) {
          if (!alunoMap.containsKey(n.alunoId)) {
            alunoMap[n.alunoId] = ExportAluno(id: n.alunoId, nome: 'Aluno ${n.alunoId}');
          }
        }

        // Rows per student
        final alunos = alunoMap.values.toList(growable: false);
        // Keep deterministic order: sort by name
        alunos.sort((a, b) => a.nome.compareTo(b.nome));

        for (final aluno in alunos) {
          final row = <CellValue?>[];
          row.add(TextCellValue(aluno.nome));

          // collect values per activity and compute total
          double total = 0.0;
          final valuesForRow = <String>[];
          for (final aulaId in notaAulaOrder) {
            // find nota for this aluno and this aulaId (there should be at most one)
            ExportNota? notaFound;
            for (final n in turma.notas) {
              if (n.aulaId == aulaId && n.alunoId == aluno.id) {
                notaFound = n;
                break;
              }
            }
            if (notaFound == null || notaFound.valor == null) {
              valuesForRow.add('-');
            } else {
              valuesForRow.add(notaFound.valor.toString());
              total += notaFound.valor!;
            }
          }

          row.add(TextCellValue(total == 0.0 ? '0' : total.toString()));
          for (final v in valuesForRow) {
            row.add(TextCellValue(v));
          }

          notasSheet.appendRow(row);
        }
      }

      // === Conteúdos e Observações combined sheet ===
      final combined = excel[combinedName];
      // Ensure the 3-line header (title, turma, blank) is present
      ensureSheetHeader(combined, 'Conteúdos e Observações', turma.turmaName);
      // Insert a single table header row (Data | Conteúdo da Aula | Observações)
      if (combined.maxRows == 3) {
        combined.appendRow([TextCellValue(''), TextCellValue('Conteúdo da Aula'), TextCellValue('Observações')]);
        final headerRowIndex = combined.maxRows - 1;
        for (var ci = 0; ci < 3; ci++) {
          final hcell = combined.cell(CellIndex.indexByColumnRow(columnIndex: ci, rowIndex: headerRowIndex));
          hcell.cellStyle = CellStyle(bold: true);
        }
      }
      for (final monthKey in monthKeys) {
        final parts = monthKey.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final aulas = (aulasByMonth[monthKey] ?? <ExportAula>[])..sort((a, b) => a.data.compareTo(b.data));

        if (aulas.isEmpty) continue;

        // Group aulas by calendar date (yyyy-MM-dd)
        final aulasByDate = <String, List<ExportAula>>{};
        for (final a in aulas) {
          final k = '${a.data.year.toString().padLeft(4, '0')}-${a.data.month.toString().padLeft(2, '0')}-${a.data.day.toString().padLeft(2, '0')}';
          aulasByDate.putIfAbsent(k, () => <ExportAula>[]).add(a);
        }
        final dateKeys = aulasByDate.keys.toList()
          ..sort((a, b) {
            final da = a.split('-');
            final db = b.split('-');
            final ya = int.parse(da[0]);
            final ma = int.parse(da[1]);
            final daDay = int.parse(da[2]);
            final yb = int.parse(db[0]);
            final mb = int.parse(db[1]);
            final dbDay = int.parse(db[2]);
            return DateTime(ya, ma, daDay).compareTo(DateTime(yb, mb, dbDay));
          });

          // Month title (UPPERCASE)
    final monthName = DateFormat.MMMM('pt_BR').format(DateTime(year, month)).toUpperCase();
    combined.appendRow([TextCellValue('$monthName / $year')]);
    // Apply bold style to the month row (first cell)
    final monthRowIdx = combined.maxRows - 1;
    final mr = combined.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: monthRowIdx));
    mr.cellStyle = CellStyle(bold: true);

          for (final dk in dateKeys) {
          final parts = dk.split('-');
          final y = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final d = int.parse(parts[2]);
          final date = DateTime(y, m, d);
          final aulasThisDate = (aulasByDate[dk] ?? <ExportAula>[])..sort((a, b) => a.data.compareTo(b.data));

          // Collect contents (concatenate with newline if multiple)
          final contentParts = <String>[];
          for (final a in aulasThisDate) {
            if (a.conteudo != null && a.conteudo!.trim().isNotEmpty) {
              contentParts.add(a.conteudo!.trim());
            }
          }
          final contentCell = contentParts.isEmpty ? '-' : contentParts.join('\n');

          // Collect observations (concatenate with newline if multiple)
          final obsParts = <String>[];
          for (final a in aulasThisDate) {
            for (final o in a.observacoes) {
              if (o.trim().isNotEmpty) obsParts.add(o.trim());
            }
          }
          final obsCell = obsParts.isEmpty ? '-' : obsParts.join('\n');

          combined.appendRow([TextCellValue(DateFormat('dd/MM').format(date)), TextCellValue(contentCell), TextCellValue(obsCell)]);
          // keep default style for data rows; prefer no bold and allow future wrapping
          final dataRowIdx = combined.maxRows - 1;
          for (var ci = 0; ci < 3; ci++) {
            final cell = combined.cell(CellIndex.indexByColumnRow(columnIndex: ci, rowIndex: dataRowIdx));
            cell.cellStyle = CellStyle();
          }
        }

        // optional empty row between months
        combined.appendRow([TextCellValue('')]);
      }

      // Ensure 'Visão Geral' sheet header exists (no extra content added per requirements)
      final geralSheet = excel[geralSheetName];
      ensureSheetHeader(geralSheet, 'Visão Geral da Turma', turma.turmaName);

      // --- Build indicators block for this turma ---
      // 1) Days letivos registrados: use presencaAbas per aula (aula dupla = 2)
      final diasLetivos = countDiasLetivosFromExportAulas(turma.aulas);

      // Append indicator rows (left column bold) — only dias letivos per requirement
      void appendIndicator(String label, String value) {
        geralSheet.appendRow([TextCellValue(label), TextCellValue(value)]);
        final r = geralSheet.maxRows - 1;
        final cell = geralSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r));
        cell.cellStyle = CellStyle(bold: true);
      }

      appendIndicator('Dias letivos cadastrados', diasLetivos.toString());
      // explanatory note
  geralSheet.appendRow([TextCellValue('Dias letivos cadastrados consideram automaticamente aulas simples e aulas duplas.')]);

      // spacer
      geralSheet.appendRow([TextCellValue('')]);

      // --- Main table header ---
      geralSheet.appendRow([TextCellValue('Aluno'), TextCellValue('Total de Faltas'), TextCellValue('Total de Pontos')]);
      final headerIdx = geralSheet.maxRows - 1;
      for (var ci = 0; ci < 3; ci++) {
        final hc = geralSheet.cell(CellIndex.indexByColumnRow(columnIndex: ci, rowIndex: headerIdx));
        hc.cellStyle = CellStyle(bold: true);
      }

      // Build full aluno list: include active alunos and any alunoIds appearing in presencas or notas
      final alunoMapG = <int, ExportAluno>{};
      for (final a in turma.alunos) alunoMapG[a.id] = a;
      for (final p in turma.presencas) {
        if (!alunoMapG.containsKey(p.alunoId)) alunoMapG[p.alunoId] = ExportAluno(id: p.alunoId, nome: 'Aluno ${p.alunoId}');
      }
      for (final n in turma.notas) {
        if (!alunoMapG.containsKey(n.alunoId)) alunoMapG[n.alunoId] = ExportAluno(id: n.alunoId, nome: 'Aluno ${n.alunoId}');
      }

      final alunosG = alunoMapG.values.toList(growable: false);
      alunosG.sort((a, b) => a.nome.compareTo(b.nome));

      // Use presencaByAula lookup (aulaId -> aulaIndex -> alunoId -> ExportPresenca)
      for (final aluno in alunosG) {
        var faltas = 0;
        for (final aula in turma.aulas) {
          final maxIndex = (aula.presencaAbas <= 0) ? 1 : aula.presencaAbas;
          for (var idx = 0; idx < maxIndex; idx++) {
            final pres = presencaByAula[aula.id]?[idx]?[aluno.id];
            if (pres == null) continue; // no record -> do not count as falta
            if (!pres.presente) {
              if (pres.justificativa != null && pres.justificativa!.trim().isNotEmpty) {
                // justified absence -> do not count
              } else {
                faltas += 1;
              }
            }
          }
        }

        // compute total de pontos (sum of nota.valor for this aluno)
        final notasAluno = turma.notas.where((n) => n.alunoId == aluno.id && n.valor != null).map((n) => n.valor!).toList();
        String totalStr;
        if (notasAluno.isEmpty) {
          totalStr = '-';
        } else {
          final sum = notasAluno.reduce((a, b) => a + b);
          totalStr = sum.toStringAsFixed(1);
        }

        geralSheet.appendRow([TextCellValue(aluno.nome), TextCellValue(faltas.toString()), TextCellValue(totalStr)]);
      }

      // spacer after turma block
      geralSheet.appendRow([TextCellValue('')]);
    }

    // To be extra-safe (some readers preserve previously-existing blank
    // sheets), reconstruct a final workbook containing ONLY the four
    // required sheets, in the correct order, by copying content and styles
    // from the working 'excel' object. This guarantees that 'Sheet1' was
    // never present in the final bytes.
    final finalExcel = Excel.createExcel();
    // remove its default sheet
    try {
      final def = finalExcel.getDefaultSheet();
      if (def != null) finalExcel.delete(def);
    } catch (_) {}

    final required = [geralSheetName, presencaSheetName, notasSheetName, combinedName];
    // create target sheets in order
    for (final name in required) {
      finalExcel[name];
    }

    // copy rows and styles from original excel to finalExcel for each required sheet
    for (final name in required) {
      final oldTable = excel.tables[name];
      if (oldTable == null) continue;
      final newSheet = finalExcel[name];
      for (var r = 0; r < oldTable.rows.length; r++) {
        final oldRow = oldTable.rows[r];
        // build a list of cell values (as TextCellValue or null)
        final rowValues = <CellValue?>[];
        for (var c = 0; c < oldRow.length; c++) {
          final oldCell = oldRow[c];
          if (oldCell == null) {
            rowValues.add(null);
            continue;
          }
          // try to extract the raw value
          dynamic v;
          try {
            v = (oldCell as dynamic).value;
          } catch (_) {
            v = oldCell.toString();
          }
          if (v == null) {
            rowValues.add(null);
          } else {
            rowValues.add(TextCellValue(v.toString()));
          }
        }
        newSheet.appendRow(rowValues);
        // Copy cell styles where possible
        final newRowIdx = newSheet.maxRows - 1;
        for (var c = 0; c < oldRow.length; c++) {
          final oldCell = oldRow[c];
          if (oldCell == null) continue;
          try {
            final oldStyle = (oldCell as dynamic).cellStyle;
            if (oldStyle != null) {
              final newCell = newSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: newRowIdx));
              newCell.cellStyle = oldStyle;
            }
          } catch (_) {
            // ignore style copying issues
          }
        }
      }
    }

    // FINAL VALIDATION on finalExcel
    // As a last defensive attempt, remove any lingering 'Sheet1' key from
    // the internal tables map before validating/encoding.
    try {
      finalExcel.tables.remove('Sheet1');
    } catch (_) {}
    try {
      finalExcel.delete('Sheet1');
    } catch (_) {}

    final sheetNames = finalExcel.tables.keys.toList();
    if (sheetNames.contains('Sheet1')) {
      throw Exception('Export aborted: final workbook contains forbidden sheet "Sheet1"');
    }
    if (sheetNames.length != 4) {
      throw Exception('Export aborted: expected exactly 4 sheets but final workbook has ${sheetNames.length}: $sheetNames');
    }
    if (sheetNames.first != geralSheetName) {
      throw Exception('Export aborted: first sheet must be "$geralSheetName" but final workbook has "${sheetNames.first}"');
    }

    final bytes = finalExcel.encode();
    if (bytes == null) throw Exception('Failed to encode excel file');

    final dir = await _getSaveDirectory(saveToDownloads);
    final name = filename ??
        'educa_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final filePath = p.join(dir.path, name);
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  Future<Directory> _getSaveDirectory(bool saveToDownloads) async {
    if (saveToDownloads) {
      try {
        // On Android, attempt to use external storage 'Download' folder.
        if (Platform.isAndroid) {
          final ext = await getExternalStorageDirectory();
          if (ext != null) {
            // Usually the Download folder is one level up in path or under /storage/emulated/0/Download
            final downloadDir = Directory(p.join(ext.parent.path, 'Download'));
            if (await downloadDir.exists()) return downloadDir;
            // Try common location
            final alt = Directory('/storage/emulated/0/Download');
            if (await alt.exists()) return alt;
            // Fallback to external storage dir
            return ext;
          }
        }
      } catch (_) {
        // ignore and fall through to documents directory
      }
    }

    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      // In test environments (or when path_provider is not available) fall
      // back to a safe temp directory to avoid throwing Platform exceptions.
      return Directory.systemTemp;
    }
  }

  String _sanitizeSheetName(String name) {
    // Excel sheet name limit is 31 chars and cannot contain : \\ / ? * [ ]
    final invalid = RegExp(r'[:\\/\?\*\[\]]');
    var s = name.replaceAll(invalid, '_');
    if (s.length > 31) s = s.substring(0, 31);
    return s;
  }
}
