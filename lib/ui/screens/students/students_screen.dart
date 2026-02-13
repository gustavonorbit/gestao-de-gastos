import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/widgets/tap_to_unfocus.dart';

import '../../../app/providers.dart';
import 'import_students_info_dialog.dart';
import 'ocr_photo_import_screen.dart';
import '../../../providers/alunos_provider.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  final int turmaId;
  final String? turmaNome;

  const StudentsScreen({super.key, required this.turmaId, this.turmaNome});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  List<String> _lastImported = const [];

  void _refresh() {
    ref.invalidate(alunosByTurmaProvider(widget.turmaId));
  }

  Future<void> _editAluno(
      {required int id,
      required String currentName,
      int? currentNumero}) async {
    final nameController = TextEditingController(text: currentName);
    final numeroController =
        TextEditingController(text: currentNumero?.toString() ?? '');

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Editar aluno'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numeroController,
                  decoration: const InputDecoration(
                    labelText: 'Número de chamada (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );

      if (result != true) return;

      final nome = nameController.text.trim();
      final numeroText = numeroController.text.trim();
      final numero = numeroText.isEmpty ? null : int.tryParse(numeroText);

      if (nome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nome não pode ficar vazio.')),
        );
        return;
      }
      if (numeroText.isNotEmpty && numero == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número de chamada inválido.')),
        );
        return;
      }

      final repo = ref.read(alunoRepositoryProvider);
      await repo.updateAluno(id: id, nome: nome, numeroChamada: numero);

      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aluno atualizado.')),
      );
    } finally {
      nameController.dispose();
      numeroController.dispose();
    }
  }

  Future<void> _removeAluno({required int id, required String nome}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover aluno'),
        content: Text('Remover "$nome"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover')),
        ],
      ),
    );

    if (ok != true) return;
    final repo = ref.read(alunoRepositoryProvider);
    await repo.delete(id);

    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aluno removido.')),
    );
  }

  Future<void> _addStudents() async {
    final title = (widget.turmaNome == null || widget.turmaNome!.trim().isEmpty)
        ? 'Turma'
        : widget.turmaNome!.trim();

    final go = await showImportStudentsInfoDialog(context);
    if (go != true) return;

    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => OcrPhotoImportScreen(
          turmaId: widget.turmaId,
          turmaNome: title,
        ),
      ),
    );

    if (!mounted) return;
    if (result == null) return;

    setState(() => _lastImported = result);
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Prévia: ${result.length} nomes importados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.turmaNome == null || widget.turmaNome!.trim().isEmpty)
        ? 'Turma'
        : widget.turmaNome!.trim();
    return Scaffold(
      appBar: AppBar(
        title: Text('Alunos — $title'),
        actions: [
          IconButton(
            tooltip: 'Adicionar alunos',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _addStudents,
          ),
        ],
      ),
      body: TapToUnfocus(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_lastImported.isNotEmpty) ...[
                const Text('Última importação (prévia):',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    itemCount: _lastImported.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text(_lastImported[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Alunos cadastrados:',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: ref.watch(alunosByTurmaProvider(widget.turmaId)).when(
                      data: (alunos) {
                        if (alunos.isEmpty) {
                          return const Center(
                              child: Text('Nenhum aluno cadastrado ainda.'));
                        }
                        return ListView.separated(
                          itemCount: alunos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final aluno = alunos[i];
                            final subtitle = aluno.numeroChamada == null
                                ? null
                                : 'Nº ${aluno.numeroChamada}';

                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(aluno.nome),
                              subtitle: subtitle == null ? null : Text(subtitle),
                              onTap: aluno.id == null
                                  ? null
                                  : () => _editAluno(
                                        id: aluno.id!,
                                        currentName: aluno.nome,
                                        currentNumero: aluno.numeroChamada,
                                      ),
                              trailing: aluno.id == null
                                  ? null
                                  : IconButton(
                                      tooltip: 'Remover',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _removeAluno(
                                          id: aluno.id!, nome: aluno.nome),
                                    ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text('Erro ao carregar alunos: $e'),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


