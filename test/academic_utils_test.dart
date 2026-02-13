import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/utils/academic_utils.dart';
import 'package:educa_plus/services/export_service.dart' show ExportAula;

void main() {
  test('Aula simples gera +1 dia letivo', () {
    final aulas = [ExportAula(id: 1, data: DateTime(2026,1,1), presencaAbas: 1)];
    final dias = countDiasLetivosFromExportAulas(aulas);
    expect(dias, 1);
  });

  test('Aula dupla gera +2 dias letivos', () {
    final aulas = [ExportAula(id: 2, data: DateTime(2026,1,2), presencaAbas: 2)];
    final dias = countDiasLetivosFromExportAulas(aulas);
    expect(dias, 2);
  });

  test('Turma com aulas simples e duplas misturadas', () {
    final aulas = [
      ExportAula(id: 1, data: DateTime(2026,1,1), presencaAbas: 1),
      ExportAula(id: 2, data: DateTime(2026,1,2), presencaAbas: 2),
      ExportAula(id: 3, data: DateTime(2026,1,3), presencaAbas: 1),
    ];
    final dias = countDiasLetivosFromExportAulas(aulas);
    expect(dias, 4);
  });
}
