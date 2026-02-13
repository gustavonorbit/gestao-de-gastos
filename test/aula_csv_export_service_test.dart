import 'package:flutter_test/flutter_test.dart';

import 'package:educa_plus/services/aula_csv_export_service.dart';

void main() {
  group('AulaCsvExportService.buildCsv', () {
    test('gera cabeçalho e uma linha por aluno por aula', () {
      final svc = AulaCsvExportService();

      final csv = svc.buildCsv(
        AulaCsvExportData(
          aulas: [
            AulaCsvExportAula(
                id: 10, data: DateTime(2026, 1, 24), turmaNome: 'Turma A'),
          ],
          alunos: [
            AulaCsvExportAluno(id: 1, nome: 'Ana Maria'),
            AulaCsvExportAluno(id: 2, nome: 'Bruno Silva'),
          ],
          presencas: [
            AulaCsvExportPresenca(aulaId: 10, alunoId: 1, presente: true),
            AulaCsvExportPresenca(
                aulaId: 10,
                alunoId: 2,
                presente: false,
                justificativa: 'Consulta médica'),
          ],
          conteudosPorAulaId: {
            10: [
              'PORTUGUÊS: estudo silábico, pág. 90–95',
              'CIÊNCIAS: água, pág. 100'
            ],
          },
        ),
      );

      final lines = csv.trim().split('\n');
      expect(lines.length, 1 /* header */ + 2 /* alunos */);

      expect(lines.first,
          '"Data da Aula","Turma","Nome do Aluno","Presença","Justificativa","Conteúdo da Aula"');

      // Ana (P; justificativa vazia)
      expect(
        lines[1],
        '"24/01/2026","Turma A","Ana Maria","P","","PORTUGUÊS: estudo silábico, pág. 90–95; CIÊNCIAS: água, pág. 100"',
      );

      // Bruno (F; justificativa preenchida)
      expect(
        lines[2],
        '"24/01/2026","Turma A","Bruno Silva","F","Consulta médica","PORTUGUÊS: estudo silábico, pág. 90–95; CIÊNCIAS: água, pág. 100"',
      );
    });

    test('sanitiza quebras de linha e múltiplos espaços para não quebrar CSV',
        () {
      final svc = AulaCsvExportService();

      final csv = svc.buildCsv(
        AulaCsvExportData(
          aulas: [
            AulaCsvExportAula(
                id: 10, data: DateTime(2026, 1, 24), turmaNome: 'Turma\nA'),
          ],
          alunos: [
            AulaCsvExportAluno(id: 1, nome: '  Ana\n\nMaria  '),
          ],
          presencas: [
            AulaCsvExportPresenca(
                aulaId: 10,
                alunoId: 1,
                presente: false,
                justificativa: '  Texto\ncom\nlinhas  '),
          ],
          conteudosPorAulaId: {
            10: ['  Linha 1\nLinha 2  ', ''],
          },
        ),
      );

      final lines = csv.trim().split('\n');
      expect(lines.length, 2);

      // Everything must be single-line and collapsed spaces.
      expect(
        lines[1],
        '"24/01/2026","Turma A","Ana Maria","F","Texto com linhas","Linha 1 Linha 2"',
      );
    });

    test('quando não há presença registrada, assume F e justificativa vazia',
        () {
      final svc = AulaCsvExportService();

      final csv = svc.buildCsv(
        AulaCsvExportData(
          aulas: [
            AulaCsvExportAula(
                id: 10, data: DateTime(2026, 1, 24), turmaNome: 'Turma A'),
          ],
          alunos: [
            AulaCsvExportAluno(id: 1, nome: 'Ana'),
          ],
          presencas: const [],
          conteudosPorAulaId: const {},
        ),
      );

      final lines = csv.trim().split('\n');
      expect(lines[1], '"24/01/2026","Turma A","Ana","F","",""');
    });
  });
}
