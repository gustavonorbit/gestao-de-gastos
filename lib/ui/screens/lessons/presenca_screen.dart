import 'package:educa_plus/providers/alunos_provider.dart';
import 'package:educa_plus/app/providers.dart' show presencaRepositoryProvider;
import 'package:educa_plus/domain/repositories/presenca_repository.dart'
    show PresencaRecord, PresencaUpsert;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';
import 'package:educa_plus/ui/widgets/aula_date_badge.dart';
import 'package:educa_plus/providers/aula_provider.dart';
import 'package:educa_plus/ui/widgets/tap_to_unfocus.dart';
import 'package:educa_plus/app/providers.dart' show aulaRepositoryProvider;
import 'package:educa_plus/domain/entities/aula.dart' as domain;
import 'package:educa_plus/ui/feedback/app_feedback.dart';

class PresencaAluno {
  final int alunoId;
  bool presente;
  String? justificativa;

  PresencaAluno({
    required this.alunoId,
    required this.presente,
    this.justificativa,
  });
}

class PresencaScreen extends ConsumerStatefulWidget {
  final int turmaId;
  final int aulaId;
  final String turmaName;

  /// 1 = aula individual (uma aba), 2 = aula dupla (duas abas).
  final int tipoPresenca;

  const PresencaScreen({
    super.key,
    required this.turmaId,
    required this.aulaId,
    required this.turmaName,
    this.tipoPresenca = 1,
  });

  @override
  ConsumerState<PresencaScreen> createState() => _PresencaScreenState();
}

class _PresencaScreenState extends ConsumerState<PresencaScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Tipo efetivo vindo do banco. Se não carregar, assume individual.
  domain.AulaTipo _tipoFromDb = domain.AulaTipo.individual;

  bool _saving = false;
  bool _loadingFromDb = false;
  bool _houveAlteracao = false;
  bool _initialLoadDone = false;

  // Estado original (carregado do banco): tabIndex -> alunoId -> PresencaAluno
  final Map<int, Map<int, PresencaAluno>> _originalByTab = {
    0: <int, PresencaAluno>{},
    1: <int, PresencaAluno>{},
  };

  // Estado editado (rascunho): tabIndex -> alunoId -> PresencaAluno
  // Só existe para alunos que o usuário mudou (toggle/justificativa).
  final Map<int, Map<int, PresencaAluno>> _draftByTab = {
    0: <int, PresencaAluno>{},
    1: <int, PresencaAluno>{},
  };

  bool get _isDupla => _tipoFromDb == domain.AulaTipo.dupla;

  String _cleanTurmaDisplayName(String turmaName) {
    final name = turmaName.trim();
    if (name.isEmpty) return '';

    // Keep the same behavior as AulaHubScreen / ListLessonsScreen.
    const seps = [' - ', ' — ', ' | ', ' • ', ' / '];
    for (final sep in seps) {
      final idx = name.indexOf(sep);
      if (idx > 0 && idx + sep.length < name.length) {
        return name.substring(idx + sep.length).trim();
      }
    }
    return name;
  }

  @override
  void initState() {
    super.initState();

    // Inicializa tipo + presença do banco (sem depender de rota/query params).
    Future.microtask(() async {
      await _loadAulaTipoFromDb();

      if (!mounted) return;
      _syncTabControllerWithTipo();

      // Carrega do banco uma única vez. Não dependemos de providers reemitirem
      // (o que poderia limpar rascunhos durante edição).
      await _loadFromDb();
    });
  }

  void _syncTabControllerWithTipo() {
    if (_isDupla) {
      // Se já existe com length correto, mantém.
      if (_tabController != null && _tabController!.length == 2) return;
      _tabController?.dispose();
      _tabController = TabController(length: 2, vsync: this);
      // Prevent switching tabs when there are unsaved changes.
      // Keep track of the current index and revert if a change is attempted
      // while _houveAlteracao is true.
      // Allow switching internal tabs without prompting the user. The global
      // route/PopScope confirmation remains active when leaving the screen.
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) return;
        // Simply accept the tab change. Do not show a "sair sem salvar"
        // dialog when switching between Aula 1 and Aula 2. No further action
        // needed here; route-exit confirmation remains handled by PopScope.
      });
    } else {
      _tabController?.dispose();
      _tabController = null;
    }
  }

  Future<void> _onCopyPresencaPressed() async {
    try {
      final repo = ref.read(presencaRepositoryProvider);

      // Load all presence records for this aula and filter by aulaIndex=0
      final rows = await repo.getAllForAula(widget.aulaId);
      final origem = rows.where((r) => r.aulaIndex == 0).toList(growable: false);

      if (origem.isEmpty) {
        if (!mounted) return;
        AppFeedback.show(context, message: 'Nenhuma presença lançada na Aula 1.', type: FeedbackType.error);
        return;
      }

      // Build upsert entries for aulaIndex = 1 (Aula 2), overwriting existing
      final entries = origem
          .map((r) => PresencaUpsert(
                aulaId: widget.aulaId,
                alunoId: r.alunoId,
                aulaIndex: 1,
                presente: r.presente,
                justificativa: r.justificativa,
              ))
          .toList(growable: false);

      await repo.upsertMany(entries);

      // Update local UI state for tab 2 immediately.
      if (mounted) {
        setState(() {
          _originalByTab[1]!.clear();
          _draftByTab[1]!.clear();
          for (final e in entries) {
            _originalByTab[1]![e.alunoId] = PresencaAluno(
              alunoId: e.alunoId,
              presente: e.presente,
              justificativa: e.presente ? null : e.justificativa,
            );
          }

          // After overwriting, no unsaved changes should remain.
          _houveAlteracao = false;
        });
      }

      if (!mounted) return;
      AppFeedback.show(context, message: 'Presenças da Aula 1 copiadas para a Aula 2.', type: FeedbackType.success);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(context, message: 'Erro ao copiar presenças: $e', type: FeedbackType.error);
    }
  }

  Future<void> _loadAulaTipoFromDb() async {
    try {
      final repo = ref.read(aulaRepositoryProvider);
      final aula = await repo.getById(widget.aulaId);
      if (!mounted) return;
      setState(() {
        _tipoFromDb = aula?.tipo ?? domain.AulaTipo.individual;
        _syncTabControllerWithTipo();
      });
    } catch (_) {
      // Fallback silencioso: mantém individual.
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  PresencaAluno _getEffective(int tabIndex, int alunoId) {
    final draft = _draftByTab[tabIndex]?[alunoId];
    if (draft != null) return draft;

    final original = _originalByTab[tabIndex]?[alunoId];
    // Importante: NÃO criar default=true aqui para não sobrescrever visualmente
    // o que está no banco. Se não existe registro no banco para essa aula,
    // a lista inicial deve começar como AUSENTE (presente=false), sem auto-salvar.
    return original ?? PresencaAluno(alunoId: alunoId, presente: false);
  }

  bool _getPresente(int tabIndex, int alunoId) {
    return _getEffective(tabIndex, alunoId).presente;
  }

  String _getJustificativa(int tabIndex, int alunoId) {
    return _getEffective(tabIndex, alunoId).justificativa ?? '';
  }

  void _setPresente(int tabIndex, int alunoId, bool presente) {
    // Persist immediately on toggle (auto-save for Presença screen only).
    () async {
      final repo = ref.read(presencaRepositoryProvider);

      final prev = _getEffective(tabIndex, alunoId);
      final prevPresente = prev.presente;
      final prevJust = prev.justificativa;

      // Optimistic UI update
      setState(() {
        _originalByTab[tabIndex]![alunoId] = PresencaAluno(
          alunoId: alunoId,
          presente: presente,
          justificativa: presente ? null : prevJust,
        );
        // Clear any draft for this aluno since we persist immediately.
        _draftByTab[tabIndex]!.remove(alunoId);
        _houveAlteracao = false;
      });

      try {
        await repo.upsert(
          aulaId: widget.aulaId,
          alunoId: alunoId,
          aulaIndex: tabIndex,
          presente: presente,
          justificativa: presente ? null : prevJust,
        );
      } catch (e) {
        // Revert UI on error and show feedback.
        if (!mounted) return;
        setState(() {
          _originalByTab[tabIndex]![alunoId] = PresencaAluno(
            alunoId: alunoId,
            presente: prevPresente,
            justificativa: prevJust,
          );
        });
        AppFeedback.show(context, message: 'Erro ao atualizar presença: $e', type: FeedbackType.error);
      }
    }();
  }

  Future<void> _loadFromDb() async {
    if (_loadingFromDb) return;
    if (_initialLoadDone) return;
    try {
      setState(() => _loadingFromDb = true);

      final repo = ref.read(presencaRepositoryProvider);
      final rows = await repo.getAllForAula(widget.aulaId);
      if (!mounted) return;

      final maxTabIndex = _isDupla ? 1 : 0;
      final byTab = <int, Map<int, PresencaAluno>>{
        0: <int, PresencaAluno>{},
        1: <int, PresencaAluno>{},
      };

      for (final PresencaRecord r in rows) {
        if (r.aulaIndex < 0 || r.aulaIndex > maxTabIndex) continue;

        byTab[r.aulaIndex]![r.alunoId] = PresencaAluno(
          alunoId: r.alunoId,
          presente: r.presente,
          justificativa: r.presente ? null : r.justificativa,
        );
      }

      setState(() {
        _originalByTab[0]!
          ..clear()
          ..addAll(byTab[0]!);
        _originalByTab[1]!
          ..clear()
          ..addAll(byTab[1]!);

        // Importante: não limpamos rascunhos aqui. Este load é inicial.
        // Qualquer reset de draft/houveAlteracao deve acontecer apenas em ações
        // explícitas (ex: após salvar com sucesso) - nunca por reload externo.
        _initialLoadDone = true;
      });
    } finally {
      if (mounted) setState(() => _loadingFromDb = false);
    }
  }

  Future<bool> _saveAttendance() async {
    if (_saving) return false;

    try {
      setState(() => _saving = true);

      final repo = ref.read(presencaRepositoryProvider);
      final alunos = await ref.read(
        alunosByTurmaProvider(widget.turmaId).future,
      );
      final entries = <PresencaUpsert>[];

      final maxTabIndex = _isDupla ? 1 : 0;

      for (var tabIndex = 0; tabIndex <= maxTabIndex; tabIndex++) {
        for (final aluno in alunos) {
          final int alunoId = aluno.id as int;
          final p = _getEffective(tabIndex, alunoId);

          // Regras obrigatórias: justificativa só existe quando presente == false.
          final presente = p.presente;
          final justificativa = presente ? null : (p.justificativa?.trim());

          entries.add(
            PresencaUpsert(
              aulaId: widget.aulaId,
              alunoId: alunoId,
              aulaIndex: tabIndex,
              presente: presente,
              justificativa:
                  justificativa?.isEmpty == true ? null : justificativa,
            ),
          );
        }
      }

      await repo.upsertMany(entries);

      if (!mounted) return false;
      AppFeedback.show(
        context,
        message: 'Presença salva.',
        type: FeedbackType.success,
      );

      setState(() {
        _draftByTab[0]!.clear();
        _draftByTab[1]!.clear();
        _houveAlteracao = false;
      });

      // Regra: após salvar com sucesso, voltar para o Hub da Aula.
      Navigator.of(context).pop(true);
      return true;
    } catch (e) {
      if (!mounted) return false;
      AppFeedback.show(
        context,
        message: 'Erro ao salvar presença: $e',
        type: FeedbackType.error,
      );

      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openJustificativaDialog({
    required BuildContext context,
    required int tabIndex,
    required int alunoId,
    required String alunoNome,
  }) async {
    final controller =
        TextEditingController(text: _getJustificativa(tabIndex, alunoId));

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Justificativa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alunoNome,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Descreva o motivo da falta…',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (result == null) return;

    // Persist justification immediately (auto-save).
    final repo = ref.read(presencaRepositoryProvider);
    final prev = _getEffective(tabIndex, alunoId);
    final prevPresente = prev.presente;

    // Optimistic UI update
    setState(() {
      _originalByTab[tabIndex]![alunoId] = PresencaAluno(
        alunoId: alunoId,
        presente: false,
        justificativa: result.isEmpty ? null : result,
      );
      _draftByTab[tabIndex]!.remove(alunoId);
      _houveAlteracao = false;
    });

    try {
      await repo.upsert(
        aulaId: widget.aulaId,
        alunoId: alunoId,
        aulaIndex: tabIndex,
        presente: false,
        justificativa: result.isEmpty ? null : result,
      );
    } catch (e) {
      if (!mounted) return;
      // revert
      setState(() {
        _originalByTab[tabIndex]![alunoId] = PresencaAluno(
          alunoId: alunoId,
          presente: prevPresente,
          justificativa: prev.justificativa,
        );
      });
      AppFeedback.show(context, message: 'Erro ao atualizar justificativa: $e', type: FeedbackType.error);
    }
  }

  Color? _rowTint(BuildContext context,
      {required bool presente, required bool hasJustificativa}) {
    final scheme = Theme.of(context).colorScheme;

    if (presente) return null;
    if (hasJustificativa) return scheme.secondaryContainer;
    return scheme.surfaceContainerHighest;
  }

  Widget _buildList(List alunos, {required int tabIndex}) {
    if (alunos.isEmpty) {
      return const Center(child: Text('Nenhum aluno encontrado.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: alunos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final aluno = alunos[index];
        final int alunoId = aluno.id as int;
        final String alunoNome = (aluno.nome ?? '') as String;

        final bool isPresente = _getPresente(tabIndex, alunoId);
        final justificativa = _getJustificativa(tabIndex, alunoId);
        final bool hasJustificativa =
            !isPresente && justificativa.trim().isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Material(
            color: _rowTint(
              context,
              presente: isPresente,
              hasJustificativa: hasJustificativa,
            ),
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(alunoNome),
              subtitle:
                  hasJustificativa ? Text('Justificado: $justificativa') : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPresente)
                    TextButton(
                      onPressed: () => _openJustificativaDialog(
                        context: context,
                        tabIndex: tabIndex,
                        alunoId: alunoId,
                        alunoNome: alunoNome,
                      ),
                      child: const Text('Justificativa'),
                    ),
                  Switch(
                    value: isPresente,
                    onChanged: (value) {
                      if (value) {
                        _setPresente(tabIndex, alunoId, true);
                      } else {
                        _setPresente(tabIndex, alunoId, false);
                        AppFeedback.show(
                          context,
                          message: 'Aluno faltou',
                          type: FeedbackType.info,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final alunosAsync = ref.watch(alunosByTurmaProvider(widget.turmaId));
  final aulaAsync = ref.watch(aulaProvider(widget.aulaId));

    final turmaDisplayName = _cleanTurmaDisplayName(widget.turmaName);

    final appBarTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Presença'),
        Transform.scale(
          scale: 0.8694,
          alignment: Alignment.center,
          child: Text(
            turmaDisplayName.isNotEmpty ? turmaDisplayName : ' ',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: _isDupla ? 2 : 1,
      child: PopScope(
        canPop: !_houveAlteracao,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (!_houveAlteracao) {
            Navigator.of(context).pop();
            return;
          }

          // Ask for confirmation to leave without saving.
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Sair sem salvar?'),
                content: const Text('Você fez alterações na presença. Deseja sair sem salvar?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                  FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sair sem salvar')),
                ],
              );
            },
          ) ?? false;

          if (shouldLeave && context.mounted) {
            AppFeedback.show(
              context,
              message: 'Alterações não foram salvas.',
              type: FeedbackType.error,
            );
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: aulaAsync.maybeWhen(
                  data: (a) => a != null ? AulaDateBadge(date: a.data) : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ],
            title: appBarTitle,
            bottom: _isDupla
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          indicatorColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface,
                          // Add horizontal padding so the centered button doesn't
                          // visually overlap the labels.
                          labelPadding: const EdgeInsets.symmetric(horizontal: 40),
                          tabs: const [
                            Tab(text: 'Aula 1'),
                            Tab(text: 'Aula 2'),
                          ],
                        ),
                        // Centered compact copy icon between the two tab labels.
                        Align(
                          alignment: Alignment.center,
                          child: Semantics(
                            label: 'Copiar presença para Aula 2',
                            button: true,
                            child: Tooltip(
                              message: 'Copiar presença para Aula 2',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(44, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  // Confirmation dialog as previously implemented.
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Copiar presença'),
                                      content: const Text(
                                          'Deseja copiar a presença da Aula 1 para a Aula 2?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('Copiar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  await _onCopyPresencaPressed();

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Presença copiada para a Aula 2.'),
                                    ),
                                  );
                                },
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.content_copy, size: 15),
                                      const SizedBox(height: 1),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16.5,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ],
                                  ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          // Use a full-width persistent save button in the footer to match
          // the app's consistent pattern (Conteúdo / Notas).
          bottomNavigationBar: BottomActionArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _saving ? null : () async => await _saveAttendance(),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ),
          ),
          body: TapToUnfocus(child: alunosAsync.when(
            data: (alunos) {
              if (!_isDupla) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Aula 1',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildList(alunos, tabIndex: 0)),
                  ],
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(alunos, tabIndex: 0),
                  _buildList(alunos, tabIndex: 1),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          ),),
        ),
      ),
    );
  }
}


