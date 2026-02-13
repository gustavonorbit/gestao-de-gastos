import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;

/// Loads the date for a given aulaId from the repository.
///
/// Keeping this as a provider avoids duplicating load logic across screens.
final aulaDateProvider =
    FutureProvider.family<DateTime, int>((ref, aulaId) async {
  final repo = ref.read(aulaRepositoryProvider);
  final aula = await repo.getById(aulaId);
  if (aula == null) {
    throw StateError('Aula not found for id=$aulaId');
  }
  return aula.data;
});
