import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educa_plus/providers/turma_notifier.dart';
import 'package:educa_plus/providers/trash_turma_notifier.dart' show trashTurmaListProvider;
import 'package:educa_plus/ui/screens/classes/turma_filter.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';
import 'package:educa_plus/ui/screens/classes/turma_filter_controller.dart';
import 'package:educa_plus/ui/widgets/filter_actions.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';
import 'package:educa_plus/ui/screens/institutional/contact_support_screen.dart';
// cross_file is re-exported by share_plus so no direct import is needed.

class ListClassesScreen extends ConsumerWidget {
  const ListClassesScreen({super.key});

  /// Builds the card title keeping institution + compact turma label.
  ///
  /// Example:
  /// - Stored `nome`: "Escola Antiga 1º ano G"
  /// - Output: "Escola Antiga • 1º G"
  String _turmaCardTitle(String nomeCompleto, int anoLetivo) {
    final tokens = nomeCompleto.trim().split(RegExp(r'\s+'));

    // Extract trailing letter (A..Z) if present.
    String? letra;
    if (tokens.isNotEmpty) {
      final last = tokens.last.toUpperCase();
      if (last.length == 1 && RegExp(r'^[A-Z]$').hasMatch(last)) {
        letra = last;
        tokens.removeLast();
      }
    }

    // Strip trailing serie token. We support both legacy "<n>º ano" and new "<n>º".
    if (tokens.isNotEmpty) {
      final last = tokens.last.toLowerCase();
      if (last == '$anoLetivoº') {
        tokens.removeLast();
      } else if (last == 'ano' && tokens.length >= 2) {
        final prev = tokens[tokens.length - 2].toLowerCase();
        if (prev == '$anoLetivoº') {
          tokens.removeRange(tokens.length - 2, tokens.length);
        }
      }
    }

    final instituicao = tokens.join(' ').trim();
    final turmaLabel = '$anoLetivoº${letra == null ? '' : ' $letra'}';
    if (instituicao.isEmpty) return turmaLabel;
    return '$instituicao • $turmaLabel';
  }

  static const List<String> _series = <String>[
    '1º',
    '2º',
    '3º',
    '4º',
    '5º',
    '6º',
    '7º',
    '8º',
    '9º',
    '10º',
  ];

  static final List<String> _letras = List<String>.generate(
      26, (i) => String.fromCharCode('A'.codeUnitAt(0) + i));


  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(turmaFilterProvider);

    final queryController = TextEditingController(text: filter.query);
    final disciplinaController =
        TextEditingController(text: filter.disciplinaQuery ?? '');

    int? serieNumero = filter.serieNumero;
    String? letra = filter.letra;
    bool? ativa = filter.ativa;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setLocalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtrar turmas',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: queryController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar (instituição/turma)',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int?>(
                          initialValue: serieNumero,
                          decoration:
                              const InputDecoration(labelText: 'Ano/Série'),
                          items: [
                            const DropdownMenuItem<int?>(
                                value: null, child: Text('Todos')),
                            ...List.generate(
                              _series.length,
                              (i) => DropdownMenuItem<int?>(
                                  value: i + 1, child: Text(_series[i])),
                            ),
                          ],
                          onChanged: (v) =>
                              setLocalState(() => serieNumero = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: letra,
                          decoration: const InputDecoration(labelText: 'Sigla'),
                          items: [
                            const DropdownMenuItem<String?>(
                                value: null, child: Text('Todas')),
                            ..._letras.map((l) => DropdownMenuItem<String?>(
                                value: l, child: Text(l))),
                          ],
                          onChanged: (v) => setLocalState(() => letra = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: disciplinaController,
                    decoration: const InputDecoration(
                      labelText: 'Disciplina (opcional)',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool?>(
                    initialValue: ativa,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem<bool?>(
                          value: null, child: Text('Todas')),
                      DropdownMenuItem<bool?>(
                          value: true, child: Text('Ativas')),
                      DropdownMenuItem<bool?>(
                          value: false, child: Text('Inativas')),
                    ],
                    onChanged: (v) => setLocalState(() => ativa = v),
                  ),
                  const SizedBox(height: 16),
                  // Standardized filter actions: clear (secondary) + apply (primary)
                  // Uses a reusable widget so other filter sheets can adopt the
                  // same visual and behavioral contract.
                  FilterActionRow(
                    onClear: () {
                      // Reset the global filter state so the listing updates
                      // immediately.
                      ref.read(turmaFilterProvider.notifier).clear();

                      // Also reset local editors so the sheet reflects the
                      // cleared state if it remains open briefly.
                      queryController.text = '';
                      disciplinaController.text = '';
                      setLocalState(() {
                        serieNumero = null;
                        letra = null;
                        ativa = null;
                      });

                      // Provide immediate visual feedback to the user.
                      AppFeedback.show(ctx,
                          message: 'Filtros limpos', type: FeedbackType.info);

                      Navigator.of(ctx).pop();
                    },
                    onApply: () {
                      ref.read(turmaFilterProvider.notifier)
                        ..setQuery(queryController.text)
                        ..setSerieNumero(serieNumero)
                        ..setLetra(letra)
                        ..setDisciplinaQuery(disciplinaController.text)
                        ..setAtiva(ativa);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(turmaListProvider);
    final filter = ref.watch(turmaFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turmas'),
        actions: [
          // Support / contact button added next to the filter button.
          Tooltip(
            message: 'Contato e suporte',
            child: IconButton(
              tooltip: 'Contato e suporte',
              icon: const Icon(Icons.support_agent_outlined),
              onPressed: () {
                // Use Navigator.push to avoid touching global routes.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Filtrar',
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _openFilterSheet(context, ref),
          ),
          IconButton(
            tooltip: 'Exportar',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () async {
              try {
                // Close keyboard if open
                FocusScope.of(context).unfocus();
                // Navigate to fechamento screen
                context.push('/fechamento');
              } catch (e) {
                if (!context.mounted) return;
                AppFeedback.show(context, message: 'Não foi possível abrir o fechamento', type: FeedbackType.error);
              }
            },
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/configuracoes'),
          ),
        ],
      ),
      body: state.when(
        data: (list) {
          final filtered = applyTurmaFilter(list, filter);
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: filtered.isEmpty
                ? Text(
                    list.isEmpty
                        ? 'Nenhuma turma cadastrada'
                        : 'Nenhuma turma encontrada com os filtros atuais',
                    textAlign: TextAlign.center,
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final turma = filtered[index];
                      // Visual helpers for inactive turmas
                      final primaryTextColor = turma.ativa
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.62);
                      final secondaryTextColor = turma.ativa
                          ? Colors.black.withOpacity(0.6)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.62);

                      return GestureDetector(
                        onTap: () {
                            final id = turma.id;
                            if (id == null) {
                              AppFeedback.show(context, message: 'Turma inválida (sem id).', type: FeedbackType.error);
                              return;
                            }
                          final nome = Uri.encodeComponent(turma.nome);
                          context.push('/turmas/$id/aulas?nome=$nome');
                        },
                        child: Opacity(
                          opacity: turma.ativa ? 1.0 : 0.62,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
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
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Icon(Icons.class_,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _turmaCardTitle(
                                            turma.nome, turma.anoLetivo),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (turma.disciplina == null ||
                                                turma.disciplina!
                                                    .trim()
                                                    .isEmpty)
                                            ? 'Sem disciplina'
                                            : turma.disciplina!.trim(),
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 14.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  onPressed: () async {
                                    final id = turma.id;
                                    if (id == null) {
                                      AppFeedback.show(context, message: 'Turma inválida (sem id).', type: FeedbackType.error);
                                      return;
                                    }
                                    context.go('/turmas/$id/editar');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final id = turma.id;
                                    if (id == null) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Turma inválida (sem id).')),
                                      );
                                      return;
                                    }

                                    // If turma is active -> only deactivate
                                    if (turma.ativa) {
                                      await ref.read(turmaListProvider.notifier).deactivate(id);
                                      if (!context.mounted) return;
                                      AppFeedback.show(context, message: 'Turma inativada. Você pode movê-la para a lixeira se desejar.', type: FeedbackType.success);
                                      return;
                                    }

                                    // If already inactive -> confirm move to trash
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Mover turma para a lixeira?'),
                                        content: const Text(
                                            'Ao mover para a lixeira, esta turma sairá da lista principal.\nVocê poderá restaurá-la ou excluí-la permanentemente na Lixeira.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(ctx).pop(true),
                                            child: const Text('Mover para lixeira'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed != true) return;

                                    // Move to trash via the trash notifier so it can
                                    // refresh the trash list and invalidate the
                                    // main list provider.
                                    try {
                                      await ref.read(trashTurmaListProvider.notifier).moveToTrash(id);
                                      if (!context.mounted) return;
                                      AppFeedback.show(context, message: 'Turma movida para a lixeira', type: FeedbackType.success);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      AppFeedback.show(context, message: 'Erro: $e', type: FeedbackType.error);
                                    }
                                  },
                                ),
                                // Inactive indicator removed to keep UI minimal.
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
      // Replaced floating action button with a fixed full-width button in the
      // bottom area for visual consistency with other screens.
      bottomNavigationBar: BottomActionArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar turma'),
            onPressed: () {
              // Use the exact same navigation as the previous FAB.
              context.go('/turmas/nova');
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
