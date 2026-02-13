import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'student_name_parser.dart';
import '../../../providers/turma_notifier.dart';
import '../../../domain/entities/turma.dart';

class OcrPhotoImportScreen extends ConsumerStatefulWidget {
  final int turmaId;
  final String turmaNome;
  final ImageSource source;

  const OcrPhotoImportScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
    this.source = ImageSource.camera,
  });

  @override
  ConsumerState<OcrPhotoImportScreen> createState() =>
      _OcrPhotoImportScreenState();
}

class _OcrPhotoImportScreenState extends ConsumerState<OcrPhotoImportScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _pickAndProcess() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: widget.source,
        imageQuality: 90,
      );
      if (xfile == null) {
        setState(() => _busy = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(xfile.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final recognized = await recognizer.processImage(inputImage);
        // We still parse names for future use/telemetry, but we no longer show a
        // review screen nor a "students added" screen per new UX.
        parseStudentNamesFromOcrText(recognized.text);

        if (!mounted) return;

        // Ensure the turma exists, then redirect to turma edit.
        final turmaAsync = ref.read(turmaListProvider);
        final turmas = turmaAsync.asData?.value ?? const <Turma>[];
        Turma? turma;
        for (final t in turmas) {
          if (t.id == widget.turmaId) {
            turma = t;
            break;
          }
        }

        if (turma == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Não foi possível abrir a edição: turma não encontrada.')),
          );
          return;
        }

        // Fluxo novo: o OCR foi movido para dentro da tela de edição/criação
        // da turma. Esta tela é mantida apenas para compatibilidade.
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Importação por foto agora acontece dentro da edição da turma.')),
        );
      } finally {
        await recognizer.close();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar alunos por foto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Turma: ${widget.turmaNome}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_busy) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Reconhecendo texto offline…'),
            ] else ...[
              const Text(
                  'Tire uma foto da lista de alunos para extrair os nomes.'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickAndProcess,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Tirar foto'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text('Erro: $_error',
                  style: const TextStyle(color: Colors.redAccent)),
            ]
          ],
        ),
      ),
    );
  }
}
