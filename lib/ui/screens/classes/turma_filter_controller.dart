import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart' show Notifier, NotifierProvider;

import 'turma_filter.dart';

class TurmaFilterController extends Notifier<TurmaFilter> {
  @override
  TurmaFilter build() => TurmaFilter.empty();

  /// Sets the free-text query. Passing an empty string will clear the query.
  void setQuery(String value) {
    if (value.trim().isEmpty) {
      // normalize to empty string
      state = state.copyWith(query: '');
    } else {
      state = state.copyWith(query: value);
    }
  }

  /// Clears the free-text query.
  void clearQuery() => state = state.copyWith(query: '');

  /// Sets the serie/ano. Passing null clears the serie filter explicitly.
  void setSerieNumero(int? value) {
    if (value == null) {
      state = state.copyWith(clearSerie: true);
    } else {
      state = state.copyWith(serieNumero: value);
    }
  }

  /// Clears the serie filter.
  void clearSerie() => state = state.copyWith(clearSerie: true);

  /// Sets the letra. Passing null or empty clears the letra filter explicitly.
  void setLetra(String? value) {
    if (value == null || value.trim().isEmpty) {
      state = state.copyWith(clearLetra: true);
    } else {
      state = state.copyWith(letra: value);
    }
  }

  /// Clears the letra filter.
  void clearLetra() => state = state.copyWith(clearLetra: true);

  /// Sets the disciplina query. Empty string clears the field.
  void setDisciplinaQuery(String value) {
    if (value.trim().isEmpty) {
      state = state.copyWith(clearDisciplina: true);
    } else {
      state = state.copyWith(disciplinaQuery: value);
    }
  }

  /// Clears the disciplina filter.
  void clearDisciplina() => state = state.copyWith(clearDisciplina: true);

  /// Sets the ativa flag. Passing null clears only the ativa filter.
  void setAtiva(bool? value) {
    if (value == null) {
      state = state.copyWith(clearAtiva: true);
    } else {
      state = state.copyWith(ativa: value);
    }
  }

  void clear() => state = TurmaFilter.empty();
}

final turmaFilterProvider =
    NotifierProvider<TurmaFilterController, TurmaFilter>(
  TurmaFilterController.new,
);
