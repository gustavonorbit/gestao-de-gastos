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

  String _readNotasCell(Excel excel, String sheetName, String alunoNome, int colIndex) {
    final table = excel.tables[sheetName];
    expect(table, isNotNull);
    final rows = table!.rows;

    // find header row1 (first row where first cell is 'Aluno')
    var headerRowIndex = -1;
    for (var i = 0; i < rows.length; i++) {
      final first = rows[i].isNotEmpty ? (rows[i][0]?.value ?? '') : '';
      if (first.toString().trim() == 'Aluno') {
        headerRowIndex = i;
        break;
      }
    }
    expect(headerRowIndex, greaterThanOrEqualTo(0));

    // find aluno row
    var alunoRowIndex = -1;
    for (var i = headerRowIndex + 3; i < rows.length; i++) {
      final first = rows[i].isNotEmpty ? (rows[i][0]?.value ?? '') : '';
      if (first.toString().trim() == alunoNome) {
        alunoRowIndex = i;
        break;
      }
    }
    expect(alunoRowIndex, greaterThanOrEqualTo(0));

    final val = rows[alunoRowIndex].length > colIndex ? (rows[alunoRowIndex][colIndex]?.value ?? '') : '';
    return val.toString();
  }

  test('Notas: single activity -> value and total', () async {
    final aluno = ExportAluno(id: 1, nome: 'Aluno 1');
    final aula = ExportAula(id: 10, data: DateTime(2026, 3, 2));
    final nota = ExportNota(aulaId: 10, alunoId: 1, tipo: 'Prova', valor: 7.5);

    final turma = TurmaExportData(
      turmaName: 'Notas A',
      alunos: [aluno],
      aulas: [aula],
      presencas: [],
      notas: [nota],
    );

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_notas_single.xlsx');
    final excel = _openExcel(path);
    final sheet = 'Notas';

    // Col layout: 0=Aluno,1=Total,2=activity
    final cellVal = _readNotasCell(excel, sheet, aluno.nome, 2);
    final total = _readNotasCell(excel, sheet, aluno.nome, 1);

    expect(cellVal, '7.5');
    expect(total, '7.5');

    File(path).deleteSync();
  });

  test('Notas: multiple activities same day and student without note', () async {
    final alunoA = ExportAluno(id: 1, nome: 'Aluno A');
    final alunoB = ExportAluno(id: 2, nome: 'Aluno B');

    final aula1 = ExportAula(id: 11, data: DateTime(2026, 4, 5));
    final aula2 = ExportAula(id: 12, data: DateTime(2026, 4, 5)); // same day

    final notaA1 = ExportNota(aulaId: 11, alunoId: 1, tipo: 'T1', valor: 8.0);
    final notaB2 = ExportNota(aulaId: 12, alunoId: 2, tipo: 'T2', valor: 6.0);

    final turma = TurmaExportData(
      turmaName: 'Notas B',
      alunos: [alunoA, alunoB],
      aulas: [aula1, aula2],
      presencas: [],
      notas: [notaA1, notaB2],
    );

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_notas_multi_same_day.xlsx');
    final excel = _openExcel(path);
    final sheet = 'Notas';

    // columns should be: Aluno, Total, activity(11), activity(12)
    final aA_col2 = _readNotasCell(excel, sheet, alunoA.nome, 2);
    final aA_col3 = _readNotasCell(excel, sheet, alunoA.nome, 3);
    final aA_total = _readNotasCell(excel, sheet, alunoA.nome, 1);

    final bB_col2 = _readNotasCell(excel, sheet, alunoB.nome, 2);
    final bB_col3 = _readNotasCell(excel, sheet, alunoB.nome, 3);
    final bB_total = _readNotasCell(excel, sheet, alunoB.nome, 1);

    expect(aA_col2, '8.0');
    expect(aA_col3, '-');
    expect(aA_total, '8.0');

    expect(bB_col2, '-');
    expect(bB_col3, '6.0');
    expect(bB_total, '6.0');

    File(path).deleteSync();
  });

  test('Notas: inactive aluno with note appears, active without note present as -', () async {
    final active = ExportAluno(id: 1, nome: 'Aluno ativo');
    // inactive not present in alunos list on purpose
    final aula = ExportAula(id: 21, data: DateTime(2026, 5, 1));
    final notaInactive = ExportNota(aulaId: 21, alunoId: 99, tipo: 'Trab', valor: 5.0);

    final turma = TurmaExportData(
      turmaName: 'Notas C',
      alunos: [active],
      aulas: [aula],
      presencas: [],
      notas: [notaInactive],
    );

    final path = await svc.exportTurmasToXlsx([turma], filename: 'test_notas_inactive.xlsx');
    final excel = _openExcel(path);
    final sheet = 'Notas';

    // inactive student should appear with placeholder name
    final inactiveName = 'Aluno 99';
    final inactiveVal = _readNotasCell(excel, sheet, inactiveName, 2);
    final activeVal = _readNotasCell(excel, sheet, active.nome, 2);

    expect(inactiveVal, '5.0');
    expect(activeVal, '-');

    File(path).deleteSync();
  });

  test('Notas: export multiple turmas isolated', () async {
    final a1 = ExportAluno(id: 1, nome: 'A1');
    final aulaA = ExportAula(id: 31, data: DateTime(2026, 6, 1));
    final notaA = ExportNota(aulaId: 31, alunoId: 1, tipo: 'P1', valor: 9.0);
    final turmaA = TurmaExportData(turmaName: 'T-A', alunos: [a1], aulas: [aulaA], presencas: [], notas: [notaA]);

    final b1 = ExportAluno(id: 2, nome: 'B1');
    final aulaB = ExportAula(id: 41, data: DateTime(2026, 6, 2));
    final notaB = ExportNota(aulaId: 41, alunoId: 2, tipo: 'P2', valor: 4.0);
    final turmaB = TurmaExportData(turmaName: 'T-B', alunos: [b1], aulas: [aulaB], presencas: [], notas: [notaB]);

    final path = await svc.exportTurmasToXlsx([turmaA, turmaB], filename: 'test_notas_multi_turmas.xlsx');
    final excel = _openExcel(path);

  // With the new export layout there is a single 'Notas' sheet containing
  // data for both turmas. Verify both students appear with their values.
  final sheet = 'Notas';
  final valA = _readNotasCell(excel, sheet, a1.nome, 2);
  final valB = _readNotasCell(excel, sheet, b1.nome, 2);

  expect(valA, '9.0');
  expect(valB, '4.0');

    File(path).deleteSync();
  });
}
