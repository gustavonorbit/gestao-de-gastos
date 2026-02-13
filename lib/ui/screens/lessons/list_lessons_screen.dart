import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educa_plus/providers/aula_notifier.dart';
import 'package:intl/intl.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';
import 'package:educa_plus/ui/widgets/aula_form_dialog.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';

class ListLessonsScreen extends ConsumerStatefulWidget {
  final int turmaId;
  final String turmaName;

  const ListLessonsScreen(
      {super.key, required this.turmaId, required this.turmaName});

  @override
  ConsumerState<ListLessonsScreen> createState() => _ListLessonsScreenState();
}

// enum AulaTipo not needed here; form dialog handles domain types

class _ListLessonsScreenState extends ConsumerState<ListLessonsScreen> {
  final DateFormat _cardDateFormat = DateFormat('dd-MM-yyyy');

  // Date formatting helper previously used by inline form; the shared dialog
  // now handles its own formatting. Keep card format below.

  String _cleanTurmaDisplayName(String turmaName) {
    final name = turmaName.trim();
    if (name.isEmpty) return '';

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
    Future.microtask(
        () => ref.read(aulaListProvider.notifier).loadForTurma(widget.turmaId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aulaListProvider);

    final turmaDisplayName = _cleanTurmaDisplayName(widget.turmaName);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Aulas'),
            Transform.scale(
              scale: 0.8694,
              alignment: Alignment.center,
              child: Text(
                turmaDisplayName.isNotEmpty ? turmaDisplayName : ' ',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: state.when(
        data: (list) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: list.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final aula = list[index];
                    final aulaId = aula.id;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ],
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.10)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: aulaId == null
                              ? null
                              : () {
                                  final title = Uri.encodeComponent(aula.titulo);
                                  context.push(
                                    '/turmas/${widget.turmaId}/aulas/$aulaId?titulo=$title&turmaNome=${Uri.encodeComponent(widget.turmaName)}',
                                  );
                                },
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Icon(Icons.book,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  aula.titulo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _cardDateFormat.format(aula.data),
                                style:
                                    TextStyle(color: Colors.black.withOpacity(0.6)),
                              ),
                              // Edit button (opens modal reuse)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: aulaId == null
                                    ? null
                                    : () async {
                                        await showAulaFormDialog(
                                          context,
                                          isEdit: true,
                                          turmaId: widget.turmaId,
                                          initial: aula,
                                          onSave: (updated) async {
                                            await ref
                                                .read(aulaListProvider.notifier)
                                                .update(updated);
                                          },
                                        );
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: aulaId == null
                                    ? null
                                    : () async {
                                        // Confirmation dialog for destructive action
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) {
                                            return WillPopScope(
                                              onWillPop: () async => false,
                                              child: AlertDialog(
                                                title: const Text('Apagar aula?'),
                                                content: const Text(
                                                    'Essa ação removerá a aula e todas as informações associadas a ela.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(ctx).pop(false),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                    ),
                                                    onPressed: () => Navigator.of(ctx).pop(true),
                                                    child: const Text('Apagar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );

                                        if (confirm != true) return;

                                        try {
                                          await ref
                                              .read(aulaListProvider.notifier)
                                              .remove(aulaId, widget.turmaId);

                                          // Check provider for error state
                                          final state = ref.read(aulaListProvider);
                                          if (state.hasError) {
                                            AppFeedback.show(context,
                                                message: 'Não foi possível apagar a aula. Tente novamente.',
                                                type: FeedbackType.error);
                                          } else {
                                            AppFeedback.show(context,
                                                message: 'Aula apagada com sucesso.',
                                                type: FeedbackType.success);
                                          }
                                        } catch (e) {
                                          AppFeedback.show(context,
                                              message: 'Não foi possível apagar a aula. Tente novamente.',
                                              type: FeedbackType.error);
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
      bottomNavigationBar: BottomActionArea(
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar aula'),
            onPressed: () async {
              await showAulaFormDialog(
                context,
                isEdit: false,
                turmaId: widget.turmaId,
                onSave: (aula) async {
                  await ref.read(aulaListProvider.notifier).add(aula);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
