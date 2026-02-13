import 'dart:io';

import 'package:educa_plus/services/export_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final svc = ExportService();

  setUpAll(() async {
    // Ensure Flutter bindings and intl locale data for month names are initialized
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
  });

  Excel _openExcel(String path) {
    final bytes = File(path).readAsBytesSync();
    return Excel.decodeBytes(bytes);
  }

  String _readPresenceCell(Excel excel, String sheetName, String alunoNome) {
    final table = excel.tables[sheetName];
    expect(table, isNotNull, reason: 'Sheet $sheetName should exist');
  // find header row (a row that contains the literal 'Aluno' in any cell)
  final rows = table!.rows;
  // Debug rows trimmed (kept for potential future debugging; not printed by default)
    var headerRowIndex = -1;
    for (var i = 0; i < rows.length; i++) {
      final any = rows[i].any((c) => (c?.value ?? '').toString().trim() == 'Aluno');
      if (any) {
        headerRowIndex = i;
        break;
      }
    }
    if (headerRowIndex < 0) {
      // Provide helpful debug info: list first several rows
      final debugRows = rows.take(12).map((r) => r.map((c) => c?.value).toList()).toList();
      fail('Header row not found. Sheet rows (first 12): $debugRows');
    }

    // find aluno row
    var alunoRowIndex = -1;
    for (var i = headerRowIndex + 1; i < rows.length; i++) {
      final first = rows[i].isNotEmpty ? (rows[i][0]?.value ?? '') : '';
      if (first.toString().trim() == alunoNome) {
        alunoRowIndex = i;
        break;
      }
    }
    expect(alunoRowIndex, greaterThanOrEqualTo(0));

    // first date column is index 1
    final val = rows[alunoRowIndex].length > 1 ? (rows[alunoRowIndex][1]?.value ?? '') : '';
    return val.toString();
  }

  test('Export turma A with aula dupla -> P/P', () async {
    final aluno = ExportAluno(id: 1, nome: 'Aluno 1');
    // Represent a dupla aula as a single ExportAula with presencaAbas = 2
    final aula = ExportAula(id: 101, data: DateTime(2026, 1, 2, 8, 0), presencaAbas: 2);
    final pres1 = ExportPresenca(aulaId: 101, alunoId: 1, aulaIndex: 0, presente: true);
    final pres2 = ExportPresenca(aulaId: 101, alunoId: 1, aulaIndex: 1, presente: true);

    final turma = TurmaExportData(
      turmaName: 'Turma A',
      alunos: [aluno],
      aulas: [aula],
      presencas: [pres1, pres2],
      notas: [],
    );

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_turma_a.xlsx');
    final excel = _openExcel(path);
    final sheetName = 'Presença';
    final cell = _readPresenceCell(excel, sheetName, aluno.nome);
    expect(cell, 'P/P');

    // cleanup
    File(path).deleteSync();
  });

  test('Export turma B after A -> independent P/P', () async {
    // Turma B with different ids but also aula dupla
    final aluno = ExportAluno(id: 10, nome: 'Aluno X');
    final aula = ExportAula(id: 201, data: DateTime(2026, 1, 3, 9, 0), presencaAbas: 2);
    final pres1 = ExportPresenca(aulaId: 201, alunoId: 10, aulaIndex: 0, presente: true);
    final pres2 = ExportPresenca(aulaId: 201, alunoId: 10, aulaIndex: 1, presente: true);

    final turma = TurmaExportData(
      turmaName: 'Turma B',
      alunos: [aluno],
      aulas: [aula],
      presencas: [pres1, pres2],
      notas: [],
    );

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_turma_b.xlsx');
    final excel = _openExcel(path);
    final sheetName = 'Presença';
    final cell = _readPresenceCell(excel, sheetName, aluno.nome);
    expect(cell, 'P/P');

    File(path).deleteSync();
  });

  test('Export turma A then export again -> consistent', () async {
    final aluno = ExportAluno(id: 1, nome: 'Aluno 1');
    final aula = ExportAula(id: 101, data: DateTime(2026, 1, 2, 8, 0), presencaAbas: 2);
    final pres1 = ExportPresenca(aulaId: 101, alunoId: 1, aulaIndex: 0, presente: true);
    final pres2 = ExportPresenca(aulaId: 101, alunoId: 1, aulaIndex: 1, presente: true);

    final turma = TurmaExportData(
      turmaName: 'Turma A',
      alunos: [aluno],
      aulas: [aula],
      presencas: [pres1, pres2],
      notas: [],
    );

    // First export
    final path1 = await svc.exportTurmasToXlsx([turma], filename: 'test_turma_a1.xlsx');
    final excel1 = _openExcel(path1);
    final cell1 = _readPresenceCell(excel1, 'Presença', aluno.nome);

    // Second export (same turma)
    final path2 = await svc.exportTurmasToXlsx([turma], filename: 'test_turma_a2.xlsx');
    final excel2 = _openExcel(path2);
    final cell2 = _readPresenceCell(excel2, 'Presença', aluno.nome);

    expect(cell1, 'P/P');
    expect(cell2, 'P/P');

    File(path1).deleteSync();
    File(path2).deleteSync();
  });

  test('Turma with simple aula only -> single P', () async {
    final aluno = ExportAluno(id: 5, nome: 'Aluno Simples');
    final aula = ExportAula(id: 301, data: DateTime(2026, 1, 4, 9, 0), presencaAbas: 1);
  final pres = ExportPresenca(aulaId: 301, alunoId: 5, aulaIndex: 0, presente: true);

    final turma = TurmaExportData(
      turmaName: 'Turma Simples',
      alunos: [aluno],
      aulas: [aula],
      presencas: [pres],
      notas: [],
    );

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_turma_simples.xlsx');
    final excel = _openExcel(path);
    final cell = _readPresenceCell(excel, 'Presença', aluno.nome);
    expect(cell, 'P');

    File(path).deleteSync();
  });

  test('Export multiple turmas in single call -> both sheets correct', () async {
    final alunoA = ExportAluno(id: 1, nome: 'Aluno 1');
    final aulaA = ExportAula(id: 101, data: DateTime(2026, 1, 2, 8, 0), presencaAbas: 2);
  final presA1 = ExportPresenca(aulaId: 101, alunoId: 1, aulaIndex: 0, presente: true);
  final presA2 = ExportPresenca(aulaId: 101, alunoId: 1, aulaIndex: 1, presente: true);
    final turmaA = TurmaExportData(
      turmaName: 'Turma A',
      alunos: [alunoA],
      aulas: [aulaA],
      presencas: [presA1, presA2],
      notas: [],
    );

    final alunoB = ExportAluno(id: 10, nome: 'Aluno X');
    final aulaB = ExportAula(id: 201, data: DateTime(2026, 1, 3, 9, 0), presencaAbas: 2);
  final presB1 = ExportPresenca(aulaId: 201, alunoId: 10, aulaIndex: 0, presente: true);
  final presB2 = ExportPresenca(aulaId: 201, alunoId: 10, aulaIndex: 1, presente: true);
    final turmaB = TurmaExportData(
      turmaName: 'Turma B',
      alunos: [alunoB],
      aulas: [aulaB],
      presencas: [presB1, presB2],
      notas: [],
    );

    final path = await svc.exportTurmasToXlsx([turmaA, turmaB], filename: 'test_multi.xlsx');
    final excel = _openExcel(path);

  // With the new export layout there is a single 'Presença' sheet containing
  // data for both turmas. Verify both students appear with their values.
  final sheet = 'Presença';
  final cellA = _readPresenceCell(excel, sheet, alunoA.nome);
  final cellB = _readPresenceCell(excel, sheet, alunoB.nome);

  expect(cellA, 'P/P');
  expect(cellB, 'P/P');

    File(path).deleteSync();
  });
}
