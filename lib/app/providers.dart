import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/data/database.dart';
import 'package:educa_plus/data/repositories/turma_repository_impl.dart';
import 'package:educa_plus/domain/repositories/turma_repository.dart';
import 'package:educa_plus/data/repositories/aula_repository_impl.dart';
import 'package:educa_plus/domain/repositories/aula_repository.dart';
import 'package:educa_plus/data/repositories/nome_padrao_repository_impl.dart';
import 'package:educa_plus/domain/repositories/nome_padrao_repository.dart';
import 'package:educa_plus/data/repositories/aluno_repository_impl.dart';
import 'package:educa_plus/domain/repositories/aluno_repository.dart';
import 'package:educa_plus/data/repositories/presenca_repository_impl.dart';
import 'package:educa_plus/domain/repositories/presenca_repository.dart';
import 'package:educa_plus/data/repositories/conteudo_repository_impl.dart';
import 'package:educa_plus/domain/repositories/conteudo_repository.dart';
import 'package:educa_plus/data/repositories/observacoes_repository_impl.dart';
import 'package:educa_plus/domain/repositories/observacoes_repository.dart';
import 'package:educa_plus/data/repositories/nota_repository_impl.dart';
import 'package:educa_plus/domain/repositories/nota_repository.dart';
export 'package:educa_plus/app/accessibility.dart';
export 'package:educa_plus/app/text_scale.dart';

/// Providers bootstrap for Educa+.
///
/// The `dbProvider` returns a singleton instance of [AppDatabase]. When the
/// provider is disposed (app exit / provider scope disposed) the DB is closed.

final exampleProvider = Provider<String>((ref) => 'Educa+');

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// TODO: add repository providers that depend on dbProvider, e.g.
final turmaRepositoryProvider = Provider<TurmaRepository>(
    (ref) => TurmaRepositoryImpl(ref.read(dbProvider)));

final aulaRepositoryProvider =
    Provider<AulaRepository>((ref) => AulaRepositoryImpl(ref.read(dbProvider)));

final nomePadraoRepositoryProvider = Provider<NomePadraoRepository>(
    (ref) => NomePadraoRepositoryImpl(ref.read(dbProvider)));

final alunoRepositoryProvider = Provider<AlunoRepository>(
    (ref) => AlunoRepositoryImpl(ref.read(dbProvider)));

final presencaRepositoryProvider = Provider<PresencaRepository>(
    (ref) => PresencaRepositoryImpl(ref.read(dbProvider)));

final conteudoRepositoryProvider = Provider<ConteudoRepository>(
    (ref) => ConteudoRepositoryImpl(ref.read(dbProvider)));

final observacoesRepositoryProvider = Provider<ObservacoesRepository>(
    (ref) => ObservacoesRepositoryImpl(ref.read(dbProvider)));

final notaRepositoryProvider =
    Provider<NotaRepository>((ref) => NotaRepositoryImpl(ref.read(dbProvider)));
