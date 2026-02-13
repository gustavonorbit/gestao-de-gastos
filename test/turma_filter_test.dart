import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/ui/screens/classes/turma_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyTurmaFilter', () {
    test('filters by query (institution substring)', () {
      final turmas = [
        const Turma(
            id: 1,
            nome: 'Escola Alfa 7º ano A',
            disciplina: null,
            anoLetivo: 7,
            ativa: true),
        const Turma(
            id: 2,
            nome: 'Escola Beta 7º ano A',
            disciplina: null,
            anoLetivo: 7,
            ativa: true),
      ];

      final filtered =
          applyTurmaFilter(turmas, const TurmaFilter(query: 'alfa'));
      expect(filtered.length, 1);
      expect(filtered.first.id, 1);
    });

    test('filters by serieNumero and letra', () {
      final turmas = [
        const Turma(
            id: 1,
            nome: 'Escola Alfa 7º ano A',
            disciplina: null,
            anoLetivo: 7,
            ativa: true),
        const Turma(
            id: 2,
            nome: 'Escola Alfa 8º ano A',
            disciplina: null,
            anoLetivo: 8,
            ativa: true),
        const Turma(
            id: 3,
            nome: 'Escola Alfa 7º ano B',
            disciplina: null,
            anoLetivo: 7,
            ativa: true),
      ];

      final filtered = applyTurmaFilter(
          turmas, const TurmaFilter(serieNumero: 7, letra: 'B'));
      expect(filtered.map((t) => t.id).toList(), [3]);
    });
  });
}
