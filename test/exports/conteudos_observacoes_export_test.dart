import 'dart:io';

import 'package:educa_plus/services/export_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final svc = ExportService();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
  });

  Excel _openExcel(String path) {
    final bytes = File(path).readAsBytesSync();
    return Excel.decodeBytes(bytes);
  }

  List<List<dynamic>> _sheetRows(Excel excel, String sheetName) {
    final table = excel.tables[sheetName];
    expect(table, isNotNull, reason: 'sheet $sheetName should exist');
    return table!.rows.map((r) => r.map((c) {
      // Some cells are returned as wrappers (TextCellValue), some as TextSpan
      // depending on how they were written. Normalize to primitive String.
      if (c == null) return null;
      try {
        // direct types
        if (c is TextCellValue) return c.value;
        // sometimes c is a Cell-like with .value
        final val = (c as dynamic).value;
        if (val == null) return null;
        if (val is TextCellValue) return val.value;
        if (val is String) return val;
        final s = val.toString();
        final idx = s.indexOf(':');
        if (idx >= 0) return s.substring(idx + 1);
        return s;
      } catch (_) {
        // Fallback: try toString and strip common prefixes like 'TextSpan:'
        final s = c.toString();
        final idx = s.indexOf(':');
        if (idx >= 0) return s.substring(idx + 1);
        return s;
      }
    }).toList()).toList();
  }

  String _getCellString(Excel excel, String sheetName, int rowIndex, int colIndex) {
    final table = excel.tables[sheetName];
    if (table == null) return '';
    if (rowIndex < 0 || rowIndex >= table.rows.length) return '';
    final row = table.rows[rowIndex];
    if (colIndex < 0 || colIndex >= row.length) return '';
    final cell = row[colIndex];
    if (cell == null) return '';
    try {
      final v = (cell as dynamic).value;
      if (v == null) {
        final s = cell.toString();
        final idx = s.indexOf(':');
        if (idx >= 0) return s.substring(idx + 1).trim();
        return s.trim();
      }
      if (v is TextCellValue) return v.value.toString();
      return v.toString();
    } catch (_) {
      final s = cell.toString();
      final idx = s.indexOf(':');
      if (idx >= 0) return s.substring(idx + 1).trim();
      return s.trim();
    }
  }

  test('Conteúdos only (no observations)', () async {
    final aula = ExportAula(id: 1, data: DateTime(2026, 3, 2), conteudo: 'Introdução');
    final turma = TurmaExportData(turmaName: 'C1', alunos: [], aulas: [aula], presencas: [], notas: []);

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_conteudos_only.xlsx');
    final excel = _openExcel(path);
    final sheet = 'Conteúdos e Observações';

    final rows = _sheetRows(excel, sheet);
  // Expect header rows (title + turma + spacer), then table header and data
  expect(rows.length >= 5, true);
  // sheet title at row 0
  expect(_getCellString(excel, sheet, 0, 0).toString().contains('Conteúdos'), true);
  // table header at row 3 (after title, turma, spacer)
  expect(_getCellString(excel, sheet, 3, 1).toString().contains('Conteúdo'), true);
  expect(_getCellString(excel, sheet, 3, 2).toString().contains('Observa'), true);
  // data at row 5 (title,row + turma,row + spacer + table header + month title)
  expect(_getCellString(excel, sheet, 5, 0), '02/03');
  expect(_getCellString(excel, sheet, 5, 1), 'Introdução');
  expect(_getCellString(excel, sheet, 5, 2), '-');

    File(path).deleteSync();
  });

  test('Conteúdo + Observações same day and multiple contents', () async {
    final aula1 = ExportAula(id: 10, data: DateTime(2026, 4, 5), conteudo: 'Tema A', observacoes: ['Obs 1']);
    final aula2 = ExportAula(id: 11, data: DateTime(2026, 4, 5), conteudo: 'Prática', observacoes: ['Obs 2', 'Obs extra']);
    final turma = TurmaExportData(turmaName: 'C2', alunos: [], aulas: [aula1, aula2], presencas: [], notas: []);

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_conteudos_obs.xlsx');
    final excel = _openExcel(path);
    final sheet = 'Conteúdos e Observações';

    final rows = _sheetRows(excel, sheet);
    // sheet title at row 0 and table header at row 3
  expect(_getCellString(excel, sheet, 0, 0).toString().contains('Conteúdos'), true);
  expect(_getCellString(excel, sheet, 3, 1).toString().contains('Conteúdo'), true);
  expect(_getCellString(excel, sheet, 3, 2).toString().contains('Observa'), true);
    // data row at row 5
  expect(_getCellString(excel, sheet, 5, 0), '05/04');
  final content = _getCellString(excel, sheet, 5, 1);
  expect(content.contains('Tema A'), true);
  expect(content.contains('Prática'), true);
  final obs = _getCellString(excel, sheet, 5, 2);
  expect(obs.contains('Obs 1'), true);
  expect(obs.contains('Obs 2'), true);
  expect(obs.contains('Obs extra'), true);

    File(path).deleteSync();
  });

  test('Multiple months and unique dates', () async {
    final a1 = ExportAula(id: 21, data: DateTime(2026, 1, 2), conteudo: 'Janeiro');
    final a2 = ExportAula(id: 22, data: DateTime(2026, 2, 3), conteudo: 'Fevereiro');
    final a3 = ExportAula(id: 23, data: DateTime(2026, 2, 10), conteudo: 'Fevereiro II');
    final turma = TurmaExportData(turmaName: 'C3', alunos: [], aulas: [a1, a2, a3], presencas: [], notas: []);

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_conteudos_months.xlsx');
    final excel = _openExcel(path);
    final sheet = 'Conteúdos e Observações';

    final rows = _sheetRows(excel, sheet);
    // Expect month title rows (they appear after the 3-line sheet header)
    final firstMonthTitleIndex = rows.indexWhere((r) => r[0] != null && r[0].toString().toUpperCase().contains('JANEIRO'));
    final secondMonthTitleIndex = rows.indexWhere((r) => r[0] != null && r[0].toString().toUpperCase().contains('FEVEREIRO'));
    expect(firstMonthTitleIndex > 0, true);
    expect(secondMonthTitleIndex > firstMonthTitleIndex, true);

    // Ensure dates unique - gather data rows where first cell matches DD/MM and are after the table header (row 3)
    final dataRows = rows.where((r) {
      final idx = rows.indexOf(r);
      if (idx <= 3) return false;
      if (r.isEmpty || r[0] == null) return false;
      final s = r[0].toString().trim();
      return RegExp(r'^\d{2}/\d{2}\$').hasMatch(s);
    }).toList();
    final dates = dataRows.map((r) => r[0].toString()).toList();
    final uniqueDates = dates.toSet().toList();
    expect(dates.length, uniqueDates.length);

    File(path).deleteSync();
  });

  test('No legacy sheets generated', () async {
    final aula = ExportAula(id: 99, data: DateTime(2026, 7, 7), conteudo: 'X');
    final turma = TurmaExportData(turmaName: 'C4', alunos: [], aulas: [aula], presencas: [], notas: []);

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_conteudos_no_legacy.xlsx');
    final excel = _openExcel(path);

    // legacy sheets should not exist
    expect(excel.tables.containsKey('Conteúdos'), false);
    expect(excel.tables.containsKey('Observações'), false);
    // combined sheet must exist
    expect(excel.tables.containsKey('Conteúdos e Observações'), true);

    File(path).deleteSync();
  });
}
