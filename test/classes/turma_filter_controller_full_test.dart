import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/ui/screens/classes/turma_filter_controller.dart';

void main() {
  test('serie set/clear works independently', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ctrl = c.read(turmaFilterProvider.notifier);
    ctrl.setSerieNumero(3);
    expect(c.read(turmaFilterProvider).serieNumero, equals(3));

    ctrl.setSerieNumero(null);
    expect(c.read(turmaFilterProvider).serieNumero, isNull);
  });

  test('letra set/clear works independently', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ctrl = c.read(turmaFilterProvider.notifier);
    ctrl.setLetra('B');
    expect(c.read(turmaFilterProvider).letra, equals('B'));

    ctrl.setLetra(null);
    expect(c.read(turmaFilterProvider).letra, isNull);
  });

  test('disciplina set/clear via empty string', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ctrl = c.read(turmaFilterProvider.notifier);
    ctrl.setDisciplinaQuery('Matemática');
    expect(c.read(turmaFilterProvider).disciplinaQuery, equals('Matemática'));

    ctrl.setDisciplinaQuery('');
    expect(c.read(turmaFilterProvider).disciplinaQuery, isNull);
  });

  test('query set/clear via empty string', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ctrl = c.read(turmaFilterProvider.notifier);
    ctrl.setQuery('Escola');
    expect(c.read(turmaFilterProvider).query, equals('Escola'));

    ctrl.setQuery('');
    expect(c.read(turmaFilterProvider).query, equals(''));
  });

  test('combined flows: Ativas -> Todas -> Ano X -> Todas', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ctrl = c.read(turmaFilterProvider.notifier);

    // Ativas
    ctrl.setAtiva(true);
    expect(c.read(turmaFilterProvider).ativa, isTrue);

    // Todas (clear ativa only)
    ctrl.setAtiva(null);
    expect(c.read(turmaFilterProvider).ativa, isNull);

    // Ano X
    ctrl.setSerieNumero(4);
    expect(c.read(turmaFilterProvider).serieNumero, equals(4));

    // Todas for serie
    ctrl.setSerieNumero(null);
    expect(c.read(turmaFilterProvider).serieNumero, isNull);
  });

  test('changing one field does not affect others', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ctrl = c.read(turmaFilterProvider.notifier);
    ctrl.setAtiva(true);
    ctrl.setSerieNumero(2);
    ctrl.setLetra('C');
    ctrl.setDisciplinaQuery('História');
    ctrl.setQuery('Fundamental');

    expect(c.read(turmaFilterProvider).ativa, isTrue);
    expect(c.read(turmaFilterProvider).serieNumero, equals(2));
    expect(c.read(turmaFilterProvider).letra, equals('C'));
    expect(c.read(turmaFilterProvider).disciplinaQuery, equals('História'));
    expect(c.read(turmaFilterProvider).query, equals('Fundamental'));

    // Clear letra only
    ctrl.clearLetra();
    expect(c.read(turmaFilterProvider).letra, isNull);
    expect(c.read(turmaFilterProvider).ativa, isTrue);
    expect(c.read(turmaFilterProvider).serieNumero, equals(2));
  });
}
