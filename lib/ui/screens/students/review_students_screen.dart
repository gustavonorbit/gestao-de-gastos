import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';

import '../../../app/providers.dart';

class ReviewStudentsScreen extends ConsumerStatefulWidget {
  final int turmaId;
  final String turmaNome;
  final List<String> initialNames;
  final File? sourceImageFile;

  const ReviewStudentsScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
    required this.initialNames,
    this.sourceImageFile,
  });

  @override
  ConsumerState<ReviewStudentsScreen> createState() =>
      _ReviewStudentsScreenState();
}

class _ReviewStudentsScreenState extends ConsumerState<ReviewStudentsScreen> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers =
        widget.initialNames.map((n) => TextEditingController(text: n)).toList();

    // If OCR returned nothing, start with a single empty row.
    if (_controllers.isEmpty) {
      _controllers.add(TextEditingController(text: ''));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _controllers.add(TextEditingController(text: '')));
  }

  void _removeRow(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  List<String> _buildFinalNames() {
    final seen = <String>{};
    final out = <String>[];

    for (final c in _controllers) {
      final name = c.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (seen.add(key)) out.add(name);
    }

    return out;
  }

  Future<void> _save() async {
    final names = _buildFinalNames();

    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum nome válido para salvar.')),
      );
      return;
    }

    final repo = ref.read(alunoRepositoryProvider);
    final inserted = await repo.upsertManyByName(widget.turmaId, names);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Salvo! $inserted novos alunos adicionados.')),
    );

    Navigator.of(context).pop(names);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar alunos'),
        actions: [
          IconButton(
            tooltip: 'Adicionar linha',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _addRow,
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.sourceImageFile != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(widget.sourceImageFile!,
                    height: 140, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Turma: ${widget.turmaNome}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _controllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: 'Aluno ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remover',
                      icon: const Icon(Icons.close),
                      onPressed: _controllers.length <= 1
                          ? null
                          : () => _removeRow(index),
                    )
                  ],
                );
              },
            ),
          ),
          BottomActionArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Salvar alunos'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
