import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;
import 'package:educa_plus/domain/entities/aula.dart' as domain;

/// Global provider that loads a single Aula by id from repository.
///
/// Use this as the single source of truth for UI that needs the full Aula.
final aulaProvider =
    FutureProvider.family<domain.Aula?, int>((ref, aulaId) async {
  final repo = ref.read(aulaRepositoryProvider);
  return repo.getById(aulaId);
});
