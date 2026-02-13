import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/providers/trash_turma_notifier.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';

class LixeiraScreen extends ConsumerWidget {
  const LixeiraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trashTurmaListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lixeira')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: async.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('Nenhuma turma na lixeira'));
            }
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = list[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          child: Icon(Icons.class_, size: 28, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.nome, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                              if (t.disciplina != null && t.disciplina!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  t.disciplina!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.restore_outlined),
                              label: const Text('Restaurar'),
                              onPressed: () async {
                                await ref.read(trashTurmaListProvider.notifier).restore(t.id!);
                                if (!context.mounted) return;
                                AppFeedback.show(context, message: 'Turma restaurada como inativa. Você pode reativá-la manualmente.', type: FeedbackType.success);
                              },
                            ),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text('Excluir'),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Excluir permanentemente?'),
                                    content: const Text('Esta ação é irreversível. Deseja excluir permanentemente esta turma?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await ref.read(trashTurmaListProvider.notifier).deletePermanently(t.id!);
                                  AppFeedback.show(context, message: 'Turma excluída permanentemente', type: FeedbackType.success);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }
}
