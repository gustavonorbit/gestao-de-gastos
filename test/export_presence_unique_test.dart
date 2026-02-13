import 'dart:io';

import 'package:educa_plus/services/export_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  test('Presença sheet: each aluno appears exactly once even with duplicates and multiple months', () async {
    // Initialize Flutter test bindings and intl locale data used by ExportService
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
    final service = ExportService();

    // Alunos (note: include a duplicate id to simulate bad input)
    final a1 = ExportAluno(id: 1, nome: 'Aluno Um');
    final a2 = ExportAluno(id: 2, nome: 'Aluno Dois');
    // duplicate entry (same id as a1) should not result in duplicated rows
    final alunos = [a1, a2, ExportAluno(id: 1, nome: 'Aluno Um (dup)')];

    // Aulas: two months
    final aulas = <ExportAula>[
      ExportAula(id: 10, data: DateTime(2026, 1, 10)),
      ExportAula(id: 11, data: DateTime(2026, 1, 20)),
      ExportAula(id: 12, data: DateTime(2026, 2, 5)),
      ExportAula(id: 13, data: DateTime(2026, 2, 25)),
    ];

    // Presencas: some combinations
    final presencas = <ExportPresenca>[
      ExportPresenca(aulaId: 10, alunoId: 1, presente: true),
      ExportPresenca(aulaId: 11, alunoId: 1, presente: false, justificativa: 'Doença'),
      ExportPresenca(aulaId: 12, alunoId: 2, presente: true),
      // no entry for aula 13 -> treated as '-'
    ];

    final turma = TurmaExportData(
      turmaName: 'Turma Teste',
      alunos: alunos,
      aulas: aulas,
      presencas: presencas,
      notas: [],
    );

    final filePath = await service.exportTurmasToXlsx([turma], filename: 'export_presence_test.xlsx', saveToDownloads: false);
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // For single turma the sheet is named 'Presença'
    final sheet = excel['Presença'];
    expect(sheet, isNotNull);

    // Validate per-month blocks: students may repeat across months but must be unique within a month
    final maxRows = sheet.maxRows;
  final monthTitleReg = RegExp(r'.+\s/\s\d{4}$');

    var r = 0;
    var totalStudentRows = 0;
    final seenNames = <String>{};
    while (r < maxRows) {
      final titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r));
      final titleVal = titleCell.value?.toString().trim() ?? '';
      if (!monthTitleReg.hasMatch(titleVal)) {
        r += 1;
        continue;
      }

  // Found month title at row r; header expected at r+1, students start at r+2
  final studentStart = r + 2;

      // Collect student names for this month until an empty row or next month title
      final namesThisMonth = <String>[];
      var rr = studentStart;
      while (rr < maxRows) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rr));
        final v = cell.value;
        if (v == null) break;
        final s = v.toString().trim();
        if (s.isEmpty) break;
        // If this looks like another month title, stop
        if (monthTitleReg.hasMatch(s)) break;
        namesThisMonth.add(s);
        rr += 1;
      }

      // Ensure no duplicates within this month
      final uniqueThisMonth = namesThisMonth.toSet();
      expect(namesThisMonth.length, equals(uniqueThisMonth.length), reason: 'Duplicate student in same month block: $titleVal');

      totalStudentRows += namesThisMonth.length;
      seenNames.addAll(uniqueThisMonth);

      // Move cursor to after the block we just processed
      r = rr + 1;
    }

    // Expect two students per month -> two months => total 4 rows
    expect(totalStudentRows, equals(4));
    // Unique names across the file should include both students
    expect(seenNames.contains('Aluno Um') || seenNames.contains('Aluno Um (dup)'), isTrue);
    expect(seenNames.contains('Aluno Dois'), isTrue);
  });
}
