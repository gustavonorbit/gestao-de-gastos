import 'package:flutter/material.dart';
import 'package:educa_plus/ui/widgets/tap_to_unfocus.dart';
import 'package:educa_plus/domain/entities/aula.dart' as domain;
import 'package:educa_plus/core/utils/picker_helper.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';

typedef AulaSaveCallback = Future<void> Function(domain.Aula aula);

/// Shows the Aula form dialog. Reuses the same visual layout used by the
/// creation flow. Caller supplies [isEdit], optional [initial] aula and an
/// [onSave] callback which performs persistence (create or update).
Future<void> showAulaFormDialog(
  BuildContext context, {
  required bool isEdit,
  domain.Aula? initial,
  required int turmaId,
  required AulaSaveCallback onSave,
}) {
  final titleController = TextEditingController(text: initial?.titulo ?? '');
  DateTime selected = initial?.data ?? DateTime.now();
  domain.AulaTipo tipo = initial?.tipo ?? domain.AulaTipo.individual;
  String? titleError;

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (c) {
      return StatefulBuilder(builder: (context, setState) {
    // formattedDate not used directly here; keeping the date formatted
    // inline where needed.
        bool isSaving = false;

        Future<bool> _onWillPop() async {
          final dirty = titleController.text.trim() != (initial?.titulo ?? '') ||
              selected != (initial?.data ?? DateTime.now()) ||
              tipo != (initial?.tipo ?? domain.AulaTipo.individual);
          if (!dirty) return true;
          final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Existem alterações não salvas'),
                  content: const Text('Deseja sair sem salvar as alterações?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(_).pop(false), child: const Text('Não')),
                    TextButton(onPressed: () => Navigator.of(_).pop(true), child: const Text('Sim')),
                  ],
                ),
              ) ??
              false;
          if (confirmed && context.mounted) {
            AppFeedback.show(
              context,
              message: 'Você saiu sem salvar',
              type: FeedbackType.error,
            );
            Future.microtask(() => AppFeedback.clear(context));
          }
          return confirmed;
        }

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: SizedBox(
                width: double.infinity,
                child: TapToUnfocus(
                  child: AlertDialog(
                    contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                    actionsPadding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    title: Text(isEdit ? 'Editar Aula' : 'Nova Aula'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Título',
                                errorText: titleError,
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          Text(
                            'Data',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Text(
                                    '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  final dt = await pickDateSafe(
                                    context,
                                    initialDate: selected,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (dt != null) setState(() => selected = dt);
                                },
                                child: const Text('Escolher data'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tipo da aula',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RadioListTile<domain.AulaTipo>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              'Aula individual',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            value: domain.AulaTipo.individual,
                            groupValue: tipo,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => tipo = v);
                            },
                          ),
                          RadioListTile<domain.AulaTipo>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              'Aula dupla',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            value: domain.AulaTipo.dupla,
                            groupValue: tipo,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => tipo = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    // Cancel closes the dialog directly; outside taps still trigger _onWillPop
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar')),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                if (title.isEmpty) {
                                  setState(() {
                                    titleError = 'Informe um título para a aula.';
                                  });
                                  return;
                                }

                                final aula = domain.Aula(
                                  id: initial?.id,
                                  turmaId: turmaId,
                                  titulo: title,
                                  data: selected,
                                  tipo: tipo,
                                  duracaoMinutos: tipo == domain.AulaTipo.dupla ? 2 : 1,
                                );

                                setState(() => isSaving = true);
                                try {
                                  // Show loading feedback and replace it with success/error later.
                                  if (context.mounted) {
                                    AppFeedback.show(context, message: isEdit ? 'Salvando aula...' : 'Criando aula...', type: FeedbackType.loading);
                                  }
                                  await onSave(aula);
                                  Navigator.of(context).pop(); // close form
                                  if (context.mounted) {
                                    AppFeedback.show(context, message: isEdit ? 'Aula atualizada com sucesso' : 'Aula criada com sucesso', type: FeedbackType.success);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppFeedback.show(context, message: 'Erro: $e', type: FeedbackType.error);
                                  }
                                } finally {
                                  if (context.mounted) setState(() => isSaving = false);
                                }
                              },
                        child: isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(isEdit ? 'Salvar alterações' : 'Salvar aula'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    },
  );
}
