import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/app/providers.dart';
import 'package:educa_plus/domain/entities/aluno.dart';

final alunosByTurmaProvider =
    FutureProvider.family<List<Aluno>, int>((ref, turmaId) async {
  final repo = ref.read(alunoRepositoryProvider);
  return repo.getAllForTurma(turmaId);
});
