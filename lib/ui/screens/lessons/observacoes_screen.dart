import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:educa_plus/app/providers.dart'
    show observacoesRepositoryProvider;
import 'package:educa_plus/ui/widgets/aula_date_badge.dart';
import 'package:educa_plus/providers/aula_provider.dart';
import 'package:educa_plus/ui/widgets/tap_to_unfocus.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';

/// Layout-only screen for registering general lesson observations.
///
/// IMPORTANT:
/// - No persistence
/// - No calculations
/// - No navigation
/// - No validation
class ObservacoesScreen extends ConsumerStatefulWidget {
  final int aulaId;
  final int turmaId;

  /// Same subtitle pattern used across aula screens.
  /// Expected to be the turma name (already cleaned by the caller when needed).
  final String? subtitle;

  const ObservacoesScreen({
    super.key,
    required this.aulaId,
    required this.turmaId,
    this.subtitle,
  });

  @override
  ConsumerState<ObservacoesScreen> createState() => _ObservacoesScreenState();
}

class _ObservacoesScreenState extends ConsumerState<ObservacoesScreen> {
  bool _saving = false;
  bool _loading = false;
  bool _houveAlteracao = false;

  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitial);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitial() async {
    if (_loading) return;
    try {
      setState(() => _loading = true);

      final repo = ref.read(observacoesRepositoryProvider);
      final rows = await repo.getAllForAula(widget.aulaId);
      if (!mounted) return;

      for (final c in _controllers) {
        c.dispose();
      }
      _controllers.clear();

      if (rows.isEmpty) {
        _controllers.add(_newController(''));
      } else {
        for (final r in rows) {
          _controllers.add(_newController(r.texto));
        }
      }

      setState(() {
        _houveAlteracao = false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TextEditingController _newController(String text) {
    final c = TextEditingController(text: text);
    c.addListener(() {
      if (!_houveAlteracao && mounted) {
        setState(() => _houveAlteracao = true);
      }
    });
    return c;
  }

  void _addConteudo() {
    setState(() {
      _controllers.add(_newController(''));
      _houveAlteracao = true;
    });
  }

  void _removeConteudo(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      if (_controllers.isEmpty) {
        _controllers.add(_newController(''));
      }
      _houveAlteracao = true;
    });
  }

  Future<bool> _save() async {
    if (_saving) return false;
    try {
      setState(() => _saving = true);

      final repo = ref.read(observacoesRepositoryProvider);
      final texts = _controllers.map((c) => c.text).toList(growable: false);

      await repo.replaceForAula(widget.aulaId, texts);

      setState(() {
        _houveAlteracao = false;
      });

      // Show success feedback after persistence and provider updates.
      AppFeedback.success(
        context,
        'Observações salvas com sucesso.',
      );

      Navigator.of(context).pop(true);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Confirmation dialog removed: navigation is now blocked and standardized
  // AppFeedback.error is shown when there are unsaved changes.

  @override
  Widget build(BuildContext context) {
  final aulaAsync = ref.watch(aulaProvider(widget.aulaId));

    final subtitle = (widget.subtitle ?? '').trim();
    final appBarTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Observações'),
        if (subtitle.isNotEmpty)
          Transform.scale(
            scale: 0.8694,
            alignment: Alignment.center,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );

    return PopScope(
      canPop: !_houveAlteracao,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_houveAlteracao) {
          if (context.mounted) Navigator.of(context).pop();
          return;
        }

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Sair sem salvar?'),
              content: const Text('Você fez alterações. Deseja sair sem salvar?'),
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
        ),
        body: TapToUnfocus(
          child: SafeArea(
            child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < _controllers.length; i++) ...[
                              _ObservacaoCard(
                                index: i,
                                title: i >= 1 ? 'Observação ${i + 1}' : null,
                                controller: _controllers[i],
                                showRemove: i != 0,
                                onRemove:
                                    i != 0 ? () => _removeConteudo(i) : null,
                              ),
                              if (i != _controllers.length - 1)
                                const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _addConteudo,
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar observação'),
                            ),
                          ],
                        ),
                      ),
              ),
              BottomActionArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
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

class _ObservacaoCard extends StatelessWidget {
  final int index;
  final String? title;
  final bool showRemove;
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const _ObservacaoCard({
    required this.index,
    required this.title,
    required this.showRemove,
    required this.controller,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: (title ?? '').trim().isNotEmpty
                      ? Text(
                          title!.trim(),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (showRemove)
                  IconButton(
                    key: ValueKey('observacao_remove_$index'),
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.delete_outline,
                      color:
                          Theme.of(context).iconTheme.color?.withOpacity(0.6),
                    ),
                    tooltip: 'Remover',
                  ),
              ],
            ),
            if ((title ?? '').trim().isNotEmpty) const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: null,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Digite uma observação sobre a aula…',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 