import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:educa_plus/app/providers.dart'
    show alunoRepositoryProvider, notaRepositoryProvider;
import 'package:educa_plus/ui/widgets/aula_date_badge.dart';
import 'package:educa_plus/providers/aula_provider.dart';
import 'package:educa_plus/ui/widgets/tap_to_unfocus.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';
import 'package:educa_plus/utils/nota_formatter.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';

import 'notas_controller.dart';
import 'package:educa_plus/providers/aula_notifier.dart' show aulaListProvider;
// Note: dias-letivos computing utilities are intentionally NOT consumed here.
// Keep calculation logic in place for reports/exports; do not import the
// academic utils to avoid rendering the indicator on this screen.

/// Layout-only screen for recording grades for a single aula.
///
/// IMPORTANT:
/// - No persistence
/// - No calculations
/// - No navigation
/// - No validation
class NotasScreen extends ConsumerStatefulWidget {
  final int aulaId;
  final int turmaId;

  /// Optional subtitle (aula name/date or turma name) shown under the title.
  final String? subtitle;

  const NotasScreen({
    super.key,
    required this.aulaId,
    required this.turmaId,
    this.subtitle,
  });

  @override
  ConsumerState<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends ConsumerState<NotasScreen> {
  bool _dirtyDialogOpen = false;
  late final NotasController _controller;

  // Prevent TextEditingController listeners from treating programmatic `.text`
  // assignments (initial load / refresh) as user edits.
  bool _isSyncingControllers = false;

  final TextEditingController _valorTotalController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final Map<int, TextEditingController> _notaAlunoControllers =
      <int, TextEditingController>{};
  final Map<int, FocusNode> _notaAlunoFocusNodes = <int, FocusNode>{};
  late final FocusNode _valorTotalFocusNode;

  @override
  void initState() {
    super.initState();

    _controller = NotasController(
      aulaId: widget.aulaId,
      turmaId: widget.turmaId,
      alunoRepository: ref.read(alunoRepositoryProvider),
      notaRepository: ref.read(notaRepositoryProvider),
    )..addListener(_onControllerChanged);

    _valorTotalController.addListener(() {
      if (_isSyncingControllers) return;
      _controller.setValorTotal(
        NotasController.parseDoubleLoose(_valorTotalController.text),
      );
    });

    _valorTotalFocusNode = FocusNode()
      ..addListener(() {
        if (!_valorTotalFocusNode.hasFocus) {
          final res = NotaFormatter.apply(context, _valorTotalController.text, max: _controller.valorTotalEditado ?? 10.0);
          final val = res['value'] as double?;
          final text = res['text'] as String;
          final feedback = res['feedback'] as String?;

          if (text.isNotEmpty && _valorTotalController.text != text) {
            _valorTotalController.text = text;
          }

          if (feedback != null) {
            AppFeedback.show(context, message: feedback, type: FeedbackType.info);
          }
        }
      });

    _tituloController.addListener(() {
      if (_isSyncingControllers) return;
      _controller.setTitulo(_tituloController.text);
    });

    Future.microtask(_loadInitial);
    // load aula list for turma so we can compute dias letivos
    Future.microtask(() => ref.read(aulaListProvider.notifier).loadForTurma(widget.turmaId));
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _valorTotalController.dispose();
    _tituloController.dispose();
    for (final c in _notaAlunoControllers.values) {
      c.dispose();
    }
    for (final f in _notaAlunoFocusNodes.values) {
      f.dispose();
    }
    _valorTotalFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    await _controller.loadInitial();
    if (!mounted) return;
    _syncControllersFromController();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {
      // just rebuild
    });
  }

  void _syncControllersFromController() {
    _isSyncingControllers = true;
    _valorTotalController.text = _controller.valorTotalEditado == null
        ? ''
        : NotasController.formatPtBr(_controller.valorTotalEditado!);

    _tituloController.text = _controller.tituloEditado ?? '';

    for (final c in _notaAlunoControllers.values) {
      c.dispose();
    }
    _notaAlunoControllers.clear();

    for (final aluno in _controller.alunos) {
      final ctrl = TextEditingController(
        text: _controller.notaAlunoEditada(aluno.id) == null
            ? ''
            : NotasController.formatPtBr(
                _controller.notaAlunoEditada(aluno.id)!),
      );
      final focus = FocusNode();
      focus.addListener(() {
        if (!focus.hasFocus) {
          final res = NotaFormatter.apply(context, ctrl.text, max: _controller.valorTotalEditado ?? 10.0);
          final val = res['value'] as double?;
          final text = res['text'] as String;
          final feedback = res['feedback'] as String?;

          if (text.isNotEmpty && ctrl.text != text) {
            ctrl.text = text;
          }

          if (val == null) {
            _controller.setNotaAluno(aluno.id, null);
          } else {
            _controller.setNotaAluno(aluno.id, val);
          }

          if (feedback != null) {
            AppFeedback.show(context, message: feedback, type: FeedbackType.info);
          }
        }
      });

      ctrl.addListener(() {
        if (_isSyncingControllers) return;
        () async {
          await _controller.setNotaAluno(
            aluno.id,
            NotasController.parseDoubleLoose(ctrl.text),
          );
        }();
      });

      _notaAlunoControllers[aluno.id] = ctrl;
      _notaAlunoFocusNodes[aluno.id] = focus;
    }

    _isSyncingControllers = false;
  }

  // Confirmation dialog removed: navigation is now blocked and standardized
  // AppFeedback.error is shown when there are unsaved changes.

  Future<void> _save() async {
    if (!_controller.houveAlteracao) return;
    try {
      await _controller.save();
      if (!mounted) return;
      AppFeedback.show(
        context,
        message: 'Notas salvas.',
        type: FeedbackType.success,
      );

      // After successful save, reset is already done by the controller.
      // Navigate back to the Aula Hub following the established pattern
      // used in other screens (pop with `true` to indicate success).
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // On error: do not navigate away and preserve current edits. The
      // controller retains the dirty state so the confirmation modal will
      // still appear if the user attempts to leave.
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
  final aulaAsync = ref.watch(aulaProvider(widget.aulaId));

      // AppBar title: prefer the persisted nota title (if available) as the
      // primary title. Fallback to the generic 'Notas' label. Keep the optional
      // subtitle (aula/turma info) under the main title.
      final mainTitle = _controller.tituloEditado != null && _controller.tituloEditado!.trim().isNotEmpty
          ? _controller.tituloEditado!.trim()
          : 'Notas';

      final appBarTitle = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mainTitle),
          if ((widget.subtitle ?? '').trim().isNotEmpty)
            Transform.scale(
              scale: 0.8694,
              alignment: Alignment.center,
              child: Text(
                widget.subtitle!.trim(),
                textAlign: TextAlign.center,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      );

    return PopScope(
      canPop: !_controller.houveAlteracao,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_controller.houveAlteracao) {
          if (context.mounted) Navigator.of(context).pop();
          return;
        }

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Sair sem salvar?'),
              content: const Text('Você fez alterações nas notas. As alterações feitas não serão salvas.'),
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
          title: appBarTitle,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: aulaAsync.maybeWhen(
                data: (a) => a != null ? AulaDateBadge(date: a.data) : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        body: TapToUnfocus(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _controller.loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4),
                              TextField(
                                controller: _tituloController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  labelText: 'Título da avaliação',
                                  hintText:
                                      'Ex: Lista 1 · Avaliação diagnóstica',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _valorTotalController,
                                focusNode: _valorTotalFocusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: false,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Valor total da nota',
                                  hintText:
                                      'Ex: 1,0 · 2,0 · 3,0 · 5,0 (máx 10,0)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Lista de Alunos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              for (var i = 0;
                                  i < _controller.alunos.length;
                                  i++) ...[
                                _AlunoNotaRow(
                                  nome: _controller.alunos[i].nome,
                                  controller: _notaAlunoControllers[
                                      _controller.alunos[i].id],
                                  focusNode: _notaAlunoFocusNodes[_controller.alunos[i].id],
                                ),
                                if (i != _controller.alunos.length - 1)
                                  const SizedBox(height: 10),
                              ],
                              if (_controller.alunos.isEmpty)
                                Text(
                                  'Nenhum aluno encontrado.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context).hintColor),
                                ),
                            ],
                          ),
                        ),
                ),
                BottomActionArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _controller.houveAlteracao ? _save : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}


class _AlunoNotaRow extends StatelessWidget {
  final String nome;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const _AlunoNotaRow({
    required this.nome,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withOpacity(0.14)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 92,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                decoration: const InputDecoration(
                  hintText: '0,0',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Local wrapper to unfocus when tapping outside inputs on this screen.
/// Implementation duplicated from other screens to keep the change local
/// and reversible.

