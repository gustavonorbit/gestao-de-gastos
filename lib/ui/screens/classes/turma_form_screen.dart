import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educa_plus/domain/entities/turma.dart';
import 'package:educa_plus/providers/turma_notifier.dart';
import 'package:educa_plus/app/providers.dart'
  show alunoRepositoryProvider, turmaRepositoryProvider, dbProvider;
import 'package:educa_plus/ui/feedback/app_feedback.dart';
import '../students/student_name_parser.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';

enum _ImportSource { camera, gallery }

enum _StudentAddMethod { camera, gallery, manual }

class TurmaFormScreen extends ConsumerStatefulWidget {
  final int? turmaId;
  final bool autoPromptImportStudents;
  final void Function(void Function(List<String> names) setPendingNames)?
      debugBindPendingStudentsSetter;
  final String? debugInitialInstituicao;
  final String? debugInitialSerie;
  final String? debugInitialLetra;

  const TurmaFormScreen({
    super.key,
    this.turmaId,
    this.autoPromptImportStudents = false,
    this.debugBindPendingStudentsSetter,
    this.debugInitialInstituicao,
    this.debugInitialSerie,
    this.debugInitialLetra,
  });

  @override
  ConsumerState<TurmaFormScreen> createState() => _TurmaFormScreenState();
}

class _TurmaFormScreenState extends ConsumerState<TurmaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSerie;
  String? _selectedLetra;
  late TextEditingController _instituicaoController;
  late TextEditingController _disciplinaController;
  bool _ativa = true;
  bool _saving = false;

  bool _dirty = false;
  bool _dirtyDialogOpen = false;
  _TurmaSnapshot? _initialSnapshot;

  bool _shouldAutofocusPendingLast = false;

  List<String> _pendingNames = <String>[];
  bool _loadingAlunos = false;
  List<_AlunoRow> _alunosAtivos = const [];
  final Map<int, String> _editedActiveStudentNames = <int, String>{};
  bool _importingStudents = false;

  Turma? _editingTurma;

  // Scroll controller to support programmatic scrolling to pending students
  late final ScrollController _scrollController;
  // Key to identify the pending students editor for scrolling
  final GlobalKey _pendingEditorKey = GlobalKey();

  bool get _hasManualPendingRow =>
      _pendingNames.isNotEmpty && _pendingNames.last.trim().isEmpty;

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

  @override
  void initState() {
    super.initState();

    // Start with empty controllers; edit mode will populate after loading.
    _instituicaoController = TextEditingController();
    _disciplinaController = TextEditingController();

    // Mark dirty when user edits text fields.
    _instituicaoController.addListener(_onAnyFieldChanged);
    _disciplinaController.addListener(_onAnyFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initFromMode();
    });

    _scrollController = ScrollController();

    assert(() {
      widget.debugBindPendingStudentsSetter?.call((names) {
        if (!mounted) return;
        setState(() {
          _pendingNames = List<String>.from(names);
        });
        // In debug/test scenarios, when the test harness injects pending
        // names via the debug binder, mark the form as dirty to emulate the
        // real import flow which calls `_markDirty()` after adding names.
        _markDirty();
      });
      return true;
    }());

    // Debug hooks: allow tests to prefill turma fields without interacting
    // with dropdowns. This keeps test code deterministic.
    if (widget.debugInitialInstituicao != null) {
      _instituicaoController.text = widget.debugInitialInstituicao!;
    }
    if (widget.debugInitialSerie != null) {
      _selectedSerie = widget.debugInitialSerie;
    }
    if (widget.debugInitialLetra != null) {
      _selectedLetra = widget.debugInitialLetra;
    }
  }

  Future<void> _initFromMode() async {
    final turmaId = widget.turmaId;

    if (turmaId != null) {
      // EDIT MODE: load turma from provider/notifier and prefill.
      final turma = await _loadTurmaById(turmaId);
      if (!mounted) return;
      if (turma == null) {
        AppFeedback.show(context, message: 'Turma não encontrada.', type: FeedbackType.error);
        // Return to previous screen (likely the list) to avoid dead-end.
        context.pop();
        return;
      }

      setState(() {
        _editingTurma = turma;
      });

      _prefillFromTurma(turma);
      await _loadAlunosAtivos();

      _captureInitialSnapshot();
    } else {
      // CREATE MODE: defaults.
      setState(() {
        _ativa = true;
        _editingTurma = null;
      });

      _captureInitialSnapshot();
    }

    // Import is now manual via the Students '+' button.
  }

  Future<Turma?> _loadTurmaById(int id) async {
    // Prefer notifier because it can hit DB if needed.
    final notifier = ref.read(turmaListProvider.notifier);
    try {
      await notifier.load();
    } catch (_) {
      // Ignore; we'll try to read whatever is available.
    }

    final async = ref.read(turmaListProvider);
    final turmas = async.asData?.value ?? const <Turma>[];
    for (final t in turmas) {
      if (t.id == id) return t;
    }
    // Fallback: if the turma isn't present in the in-memory list (e.g. it's
    // inactive and the current list was loaded onlyActive=true), load it
    // directly from the repository so the form can edit/reactivate it.
    final repo = ref.read(turmaRepositoryProvider);
    try {
      final fromDb = await repo.getById(id);
      if (fromDb != null) return fromDb;
    } catch (_) {
      // ignore and return null below
    }
    return null;
  }

  void _prefillFromTurma(Turma t) {
    final parsed = _parseTurmaNome(t.nome);
    _instituicaoController.text = parsed.instituicao;
    _disciplinaController.text = t.disciplina ?? '';

    final idx = t.anoLetivo - 1;
    if (idx >= 0 && idx < _series.length) {
      _selectedSerie = _series[idx];
    }

    if (parsed.letra != null && _letras.contains(parsed.letra)) {
      _selectedLetra = parsed.letra;
    }

    _ativa = t.ativa;
  }

  void _captureInitialSnapshot() {
    _initialSnapshot = _currentSnapshot();
    _dirty = false;
  }

  _TurmaSnapshot _currentSnapshot() {
    // Note: `_pendingNames` can include a manual empty row; keep it as-is so
    // navigating back after adding a manual row triggers the reminder.
    return _TurmaSnapshot(
      instituicao: _instituicaoController.text,
      disciplina: _disciplinaController.text,
      serie: _selectedSerie,
      letra: _selectedLetra,
      ativa: _ativa,
      pendingNames: List<String>.from(_pendingNames),
    );
  }

  void _onAnyFieldChanged() {
    final baseline = _initialSnapshot;
    if (baseline == null) return;

    final now = _currentSnapshot();
    final shouldBeDirty = now != baseline;
    if (shouldBeDirty == _dirty) return;

    if (!mounted) return;
    setState(() {
      _dirty = shouldBeDirty;
    });
  }

  void _markDirty() {
    if (_initialSnapshot == null) return;
    if (_dirty) return;
    if (!mounted) return;
    setState(() {
      _dirty = true;
    });
  }

  Future<bool> _confirmDiscardIfDirty() async {
    if (_saving) return false;
    if (!_dirty) return true;
    if (_dirtyDialogOpen) return false;

    _dirtyDialogOpen = true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Alterações não salvas'),
          content: const Text(
            'Você editou algo e ainda não salvou. Quer sair mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sair sem salvar'),
            ),
          ],
        );
      },
    );
    _dirtyDialogOpen = false;

    return shouldLeave == true;
  }

  Future<void> _maybePromptImportStudents() async {
    // This is now user-driven via the '+' button; allow opening even before the
    // turma is saved (we'll keep the imported names in `_pendingNames` and
    // persist them on the next Save).
    if (_importingStudents) return;

    final method = await showModalBottomSheet<_StudentAddMethod>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Adicionar alunos'),
                  subtitle: Text('Escolha como importar os nomes'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () => Navigator.of(ctx).pop(_StudentAddMethod.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Galeria'),
                  onTap: () => Navigator.of(ctx).pop(_StudentAddMethod.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.keyboard_alt_outlined),
                  title: const Text('Digitar manualmente'),
                  subtitle: const Text('Adicionar um aluno no fim da lista'),
                  onTap: () => Navigator.of(ctx).pop(_StudentAddMethod.manual),
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Agora não'),
                  onTap: () => Navigator.of(ctx).pop(null),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || method == null) return;

    if (method == _StudentAddMethod.manual) {
      _addManualStudentRow();
      return;
    }

    final source = method == _StudentAddMethod.camera
        ? _ImportSource.camera
        : _ImportSource.gallery;

    // In create mode we stay on the same screen: user will review names here and
    // then hit Save again to persist students and return to the list.

    // For camera, show a quick "how to take the best photo" dialog first.
    if (source == _ImportSource.camera) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Dicas para uma foto melhor'),
            content: const Text(
              '• Enquadre só a lista de alunos (evite bordas/mesa)\n'
              '• Boa iluminação (evite sombras)\n'
              '• Segure firme e espere o foco\n'
              '• Texto reto e próximo (sem cortar nomes)\n',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Entendi'),
              ),
            ],
          );
        },
      );
      if (!mounted || proceed != true) return;
    }

    await _importStudentsFromImage(source: source);
  }

  void _addManualStudentRow() {
    setState(() {
      _pendingNames.add('');
      _shouldAutofocusPendingLast = true;
    });

    _markDirty();
  }

  Future<void> _importStudentsFromImage({required _ImportSource source}) async {
    if (_importingStudents) return;

    setState(() {
      _importingStudents = true;
    });

    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: source == _ImportSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 90,
      );
      if (xfile == null) return;

      final inputImage = InputImage.fromFilePath(xfile.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final recognized = await recognizer.processImage(inputImage);
        final names = parseStudentNamesFromOcrText(recognized.text);
        if (!mounted) return;

        setState(() {
          // Append while keeping UX predictable (dedupe case-insensitively).
          final seen = _pendingNames.map((e) => e.toLowerCase()).toSet();
          for (final n in names) {
            final c = n.trim();
            if (c.isEmpty) continue;
            if (seen.add(c.toLowerCase())) _pendingNames.add(c);
          }
        });

        // Mark the form as dirty after importing names so the user cannot
        // accidentally leave the screen losing imported students.
        _markDirty();

        if (!mounted) return;
        if (names.isEmpty) {
          AppFeedback.show(context, message: 'Não consegui detectar nomes nessa imagem. Tente outra foto.', type: FeedbackType.warning);
        } else {
          AppFeedback.show(context, message: 'Detectei ${names.length} nome(s). Revise e toque em salvar.', type: FeedbackType.info);
        }
      } finally {
        await recognizer.close();
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(context, message: 'Erro ao importar alunos: $e', type: FeedbackType.error);
    } finally {
      if (mounted) {
        setState(() {
          _importingStudents = false;
          // Defensive: ensure the Save button is never stuck disabled after an import attempt.
          _saving = false;
        });
      }
    }
  }

  Future<void> _loadAlunosAtivos() async {
    final turmaId = _editingTurma?.id;
    if (turmaId == null) return;

    setState(() => _loadingAlunos = true);
    try {
      final repo = ref.read(alunoRepositoryProvider);
      final alunos = await repo.getAllForTurma(turmaId, onlyActive: true);
      if (!mounted) return;
      setState(() {
        _alunosAtivos = alunos
            .where((a) => a.id != null)
            .map((a) => _AlunoRow(id: a.id!, nome: a.nome))
            .toList();
      });
    } finally {
      if (mounted) setState(() => _loadingAlunos = false);
    }
  }

  void _removePendingName(int index) {
    if (index < 0 || index >= _pendingNames.length) return;

    final removedName = _pendingNames[index];

    setState(() => _pendingNames.removeAt(index));
    _markDirty();

    if (!mounted) return;

    AppFeedback.show(context, message: '"$removedName" removido.', type: FeedbackType.info);
  }

  Future<void> _deactivateAluno({required int id, required String nome}) async {
    final repo = ref.read(alunoRepositoryProvider);
    await repo.deactivate(id);
    if (!mounted) return;
    setState(() {
      _alunosAtivos = _alunosAtivos.where((a) => a.id != id).toList();
    });
    _markDirty();

    // Drop any pending edits for this student.
    _editedActiveStudentNames.remove(id);

    AppFeedback.show(context, message: '"$nome" foi para a lista de inativos.', type: FeedbackType.success);
  }

  @override
  void dispose() {
    _instituicaoController.removeListener(_onAnyFieldChanged);
    _disciplinaController.removeListener(_onAnyFieldChanged);
    _instituicaoController.dispose();
    _disciplinaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    // Special case: when we are in the create route (`widget.turmaId == null`) but
    // `_editingTurma?.id != null` it means the turma was just created in this
    // screen and we should still allow saving students even if the form is
    // invalid. Similarly, when editing an existing turma (widget.turmaId !=
    // null and `_editingTurma?.id != null`) we also want to allow the student-
    // only save path when the form is invalid. Only block entirely when the
    // form is invalid and we are not in one of those two situations.
    final hasExistingTurmaInCreateFlow =
        (widget.turmaId == null) && (_editingTurma?.id != null);
    final editingExistingTurma = _editingTurma?.id != null;
    if (!formOk && !(hasExistingTurmaInCreateFlow || editingExistingTurma))
      return;

    final anoLetivo = (_series.indexOf(_selectedSerie ?? '') + 1);

    // Data integrity: instituição must be exactly what the user typed.
    final instituicao = _instituicaoController.text.trim();

    final displayNome = [
      instituicao,
      if (_selectedSerie != null && _selectedSerie!.isNotEmpty) _selectedSerie!,
      if (_selectedLetra != null && _selectedLetra!.isNotEmpty) _selectedLetra!,
    ].join(' ');

    final newTurma = Turma(
      id: _editingTurma?.id,
      nome: displayNome,
      disciplina: _disciplinaController.text.trim().isEmpty
          ? null
          : _disciplinaController.text.trim(),
      anoLetivo: (anoLetivo >= 1 && anoLetivo <= 10) ? anoLetivo : 1,
      ativa: _ativa,
      createdAt: _editingTurma?.createdAt,
      updatedAt: DateTime.now(),
    );

    // Capture whether this turma was inactive before the save; used to
    // display a reactivation confirmation after saving.
    final wasPreviouslyInactive = _editingTurma?.ativa == false;

  setState(() => _saving = true);
    try {
      final notifier = ref.read(turmaListProvider.notifier);

      // Decide whether this turma already exists in the DB. Note that
      // `_editingTurma?.id != null` means we have an id from a prior
      // successful create (even if widget.turmaId == null for the create route).
      final turmaExistsInDb = _editingTurma?.id != null;

      // Prepare cleaned pending names once.
      final cleanedPending = _pendingNames
          .map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' '))
          .where((e) => e.isNotEmpty)
          .toList();

      // Validate the form now.
      final formOk = _formKey.currentState?.validate() ?? false;

      if (!turmaExistsInDb) {
        // FIRST-TIME CREATE: require form to be valid.
        if (!formOk) return;

        final insertedId = await notifier.addWithStudentsAndReturnId(
          newTurma,
          cleanedPending,
          _editedActiveStudentNames,
        );
        if (!mounted) return;

        _editingTurma = Turma(
          id: insertedId,
          nome: newTurma.nome,
          disciplina: newTurma.disciplina,
          anoLetivo: newTurma.anoLetivo,
          ativa: newTurma.ativa,
          createdAt: newTurma.createdAt,
          updatedAt: newTurma.updatedAt,
        );
      } else {
        // TURMA ALREADY EXISTS: two explicit paths
        if (formOk) {
          // User intends to update turma fields and students together.
          await notifier.updateWithStudents(
            newTurma,
            cleanedPending,
            _editedActiveStudentNames,
          );
        } else {
          // Form is invalid but turma exists: allow saving students only
          // (pending names and edited active names) without touching the
          // Turma row. This prevents overwriting required turma fields with
          // invalid values while still letting the teacher persist student
          // changes.
          if ((cleanedPending.isEmpty) && _editedActiveStudentNames.isEmpty) {
            // Nothing to do.
          } else {
            final db = ref.read(dbProvider);
            final alunoRepo = ref.read(alunoRepositoryProvider);
            await db.transaction(() async {
              if (cleanedPending.isNotEmpty && _editingTurma?.id != null) {
                await alunoRepo.upsertManyByName(
                    _editingTurma!.id!, cleanedPending);
              }

              if (_editedActiveStudentNames.isNotEmpty) {
                for (final entry in _editedActiveStudentNames.entries) {
                  final idAluno = entry.key;
                  final trimmed =
                      entry.value.trim().replaceAll(RegExp(r'\s+'), ' ');
                  if (trimmed.isEmpty) continue;
                  await alunoRepo.updateAluno(id: idAluno, nome: trimmed);
                }
              }
            });

            // Ensure the in-memory list is refreshed.
            await notifier.load();
          }
        }
      }

      // Clear local pending/edits now that they've been persisted.
      _pendingNames.clear();
      _editedActiveStudentNames.clear();

      // Navigation rules:
      // - Edit route: pop after saving.
      // - Create route: after saving, return to the list of turmas.
      if (!mounted) return;

      // After persisting successfully, consider the current UI state saved.
      _captureInitialSnapshot();

      // If this turma was previously inactive and the user reactivated it,
      // show a confirmation snackbar.
      // Show success feedback replacing the loading indicator.
      if (wasPreviouslyInactive && newTurma.ativa == true) {
        if (mounted) AppFeedback.show(context, message: 'Turma reativada com sucesso', type: FeedbackType.success);
      } else {
        if (mounted) AppFeedback.show(context, message: 'Turma salva com sucesso', type: FeedbackType.success);
      }

      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppFeedback.show(context, message: 'Erro ao salvar turma: $e', type: FeedbackType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  _ParsedTurmaNome _parseTurmaNome(String nome) {
    final tokens =
        nome.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) {
      return const _ParsedTurmaNome(instituicao: '', letra: null);
    }

    String? letra;
    if (tokens.isNotEmpty) {
      final last = tokens.last.toUpperCase();
      if (_letras.contains(last)) {
        letra = last;
        tokens.removeLast();
      }
    }

    // Remove trailing serie token like "1º" *or* legacy "1º ano" if present.
    // This ensures the institutions field isn't prefilled with serie info when
    // editing old/legacy turmas whose `nome` still contains "ano".
    bool removedSerie = false;
    for (final serie in _series) {
      if (tokens.isEmpty) break;

      // 1) New format tail: "1º"
      if (tokens.last.toLowerCase() == serie.toLowerCase()) {
        tokens.removeLast();
        removedSerie = true;
        break;
      }

      // 2) Legacy tail: "1º ano"
      if (tokens.length >= 2 &&
          tokens[tokens.length - 2].toLowerCase() == serie.toLowerCase() &&
          tokens.last.toLowerCase() == 'ano') {
        tokens.removeRange(tokens.length - 2, tokens.length);
        removedSerie = true;
        break;
      }
    }

    // If for some reason `_series` doesn't contain the serie anymore or the
    // stored `nome` is inconsistent, do a small generic cleanup at the tail.
    if (!removedSerie &&
        tokens.isNotEmpty &&
        tokens.last.toLowerCase() == 'ano') {
      tokens.removeLast();
    }

    final instituicao = tokens.join(' ').trim();
    return _ParsedTurmaNome(instituicao: instituicao, letra: letra);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.turmaId != null;
    final canAddStudents = _instituicaoController.text.trim().isNotEmpty &&
        (_selectedSerie?.isNotEmpty ?? false) &&
        (_selectedLetra?.isNotEmpty ?? false);
    return PopScope(
      canPop: !_dirty,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final ok = await _confirmDiscardIfDirty();
        if (!ok) return;
        if (!context.mounted) return;
        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(isEdit ? 'Editar Turma' : 'Nova Turma')),
        bottomNavigationBar: 
          // Use BottomActionArea to reserve ad space and respect system insets.
          BottomActionArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ),
          ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _instituicaoController,
                    decoration:
                        const InputDecoration(labelText: 'Nome da instituição'),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final text = (v ?? '').trim();
                      if (text.isEmpty) return 'Informe o nome da instituição';
                      return null;
                    },
                    onChanged: (_) {
                      // Rebuild to enable/disable the Students '+' button.
                      if (mounted) setState(() {});
                      _onAnyFieldChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedSerie,
                          decoration:
                              const InputDecoration(labelText: 'Ano/Série'),
                          items: _series
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedSerie = v);
                            _onAnyFieldChanged();
                          },
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Selecione a série'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedLetra,
                          decoration: const InputDecoration(labelText: 'Sigla'),
                          items: _letras
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedLetra = v);
                            _onAnyFieldChanged();
                          },
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Selecione a letra'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _disciplinaController,
                    decoration: const InputDecoration(
                        labelText: 'Disciplina (opcional)'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _ativa,
                    onChanged: (v) {
                      setState(() => _ativa = v);
                      _onAnyFieldChanged();
                    },
                    title: const Text('Turma ativa'),
                  ),
                  const SizedBox(height: 16),
                  if (!isEdit) ...[
                    // Students section (create flow).
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Alunos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: canAddStudents
                              ? 'Adicionar alunos'
                              : 'Preencha os campos da turma para adicionar alunos',
                          onPressed:
                              (!canAddStudents || _importingStudents || _saving)
                                  ? null
                                  : _maybePromptImportStudents,
                          icon: _importingStudents
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (!isEdit && !canAddStudents)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Preencha os campos da turma para começar a adicionar alunos.'),
                    )
                  else if (!isEdit &&
                      _pendingNames.isEmpty &&
                      (!isEdit || _alunosAtivos.isEmpty))
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Nenhum aluno adicionado ainda.'),
                    ),
                  if (_pendingNames.isNotEmpty) ...[
                    // Persistent chip/banner summarizing pending imports with a
                    // quick action to review (scroll into view).
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Chip(
                            label: Text('${_pendingNames.length} pendente(s)'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              final ctx = _pendingEditorKey.currentContext;
                              if (ctx != null) {
                                await Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: const Text('Revisar'),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _hasManualPendingRow
                            ? 'Nome do aluno'
                            : 'Alunos detectados (edite antes de salvar)',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      key: _pendingEditorKey,
                      child: _PendingStudentsEditor(
                        names: _pendingNames,
                        onRemove: _removePendingName,
                        onChanged: (index, value) {
                          setState(() => _pendingNames[index] = value);
                          _markDirty();
                        },
                        autofocusLastEmpty: _shouldAutofocusPendingLast,
                        onAutofocusConsumed: () {
                          if (mounted) {
                            setState(() => _shouldAutofocusPendingLast = false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (isEdit) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Alunos ativos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: 'Adicionar alunos',
                          onPressed: (_importingStudents || _saving)
                              ? null
                              : _maybePromptImportStudents,
                          icon: _importingStudents
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_loadingAlunos)
                      const LinearProgressIndicator()
                    else if (_alunosAtivos.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Nenhum aluno ativo nesta turma.'),
                      )
                    else
                      _ActiveStudentsEditor(
                        rows: _alunosAtivos,
                        onRemove: (row) =>
                            _deactivateAluno(id: row.id, nome: row.nome),
                        onChanged: (row, value) {
                          final trimmed =
                              value.trim().replaceAll(RegExp(r'\s+'), ' ');
                          if (trimmed.isEmpty || trimmed == row.nome) return;

                          // Keep changes locally; persist only on Save.
                          _editedActiveStudentNames[row.id] = trimmed;

                          setState(() {
                            _alunosAtivos = _alunosAtivos
                                .map((a) => a.id == row.id
                                    ? _AlunoRow(id: a.id, nome: trimmed)
                                    : a)
                                .toList();
                          });
                          _markDirty();
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                  // If editing and the core turma fields are invalid, but there
                  // are pending student changes, show an inline informational
                  // banner so the user understands only students will be saved.
                  Builder(builder: (ctx) {
                    final formOkLocal =
                        _instituicaoController.text.trim().isNotEmpty &&
                            (_selectedSerie?.isNotEmpty ?? false) &&
                            (_selectedLetra?.isNotEmpty ?? false);
                    final hasStudentChanges = _pendingNames.isNotEmpty ||
                        _editedActiveStudentNames.isNotEmpty;
                    if (isEdit && !formOkLocal && hasStudentChanges) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Campos da turma inválidos — apenas alterações de alunos serão salvas.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 80);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlunoRow {
  final int id;
  final String nome;

  const _AlunoRow({required this.id, required this.nome});
}

class _ActiveStudentsEditor extends StatefulWidget {
  final List<_AlunoRow> rows;
  final void Function(_AlunoRow row) onRemove;
  final void Function(_AlunoRow row, String value) onChanged;

  const _ActiveStudentsEditor({
    required this.rows,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_ActiveStudentsEditor> createState() => _ActiveStudentsEditorState();
}

class _ActiveStudentsEditorState extends State<_ActiveStudentsEditor> {
  final Map<int, TextEditingController> _controllersById = {};

  @override
  void initState() {
    super.initState();
    for (final r in widget.rows) {
      _controllersById[r.id] = TextEditingController(text: r.nome);
    }
  }

  @override
  void didUpdateWidget(covariant _ActiveStudentsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    final activeIds = widget.rows.map((e) => e.id).toSet();

    // Dispose removed.
    final removedIds =
        _controllersById.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in removedIds) {
      _controllersById[id]?.dispose();
      _controllersById.remove(id);
    }

    // Add/update.
    for (final r in widget.rows) {
      final c = _controllersById.putIfAbsent(
          r.id, () => TextEditingController(text: r.nome));
      if (c.text != r.nome) c.text = r.nome;
    }
  }

  @override
  void dispose() {
    for (final c in _controllersById.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = widget.rows[index];
        final controller = _controllersById[row.id]!;

        return Row(
          key: ValueKey<int>(row.id),
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                // Changes are only persisted when the user taps the Save button
                // on the parent screen.
                onChanged: (v) => widget.onChanged(row, v),
              ),
            ),
            IconButton(
              tooltip: 'Mover para inativos',
              icon: const Icon(Icons.close),
              onPressed: () => widget.onRemove(row),
            ),
          ],
        );
      },
    );
  }
}

class _TurmaSnapshot {
  final String instituicao;
  final String disciplina;
  final String? serie;
  final String? letra;
  final bool ativa;
  final List<String> pendingNames;

  const _TurmaSnapshot({
    required this.instituicao,
    required this.disciplina,
    required this.serie,
    required this.letra,
    required this.ativa,
    required this.pendingNames,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TurmaSnapshot &&
        other.instituicao == instituicao &&
        other.disciplina == disciplina &&
        other.serie == serie &&
        other.letra == letra &&
        other.ativa == ativa &&
        _listEquals(other.pendingNames, pendingNames);
  }

  @override
  int get hashCode => Object.hash(
        instituicao,
        disciplina,
        serie,
        letra,
        ativa,
        Object.hashAll(pendingNames),
      );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _PendingStudentsEditor extends StatefulWidget {
  final List<String> names;
  final void Function(int index) onRemove;
  final void Function(int index, String value) onChanged;
  final bool autofocusLastEmpty;
  final VoidCallback? onAutofocusConsumed;

  const _PendingStudentsEditor({
    required this.names,
    required this.onRemove,
    required this.onChanged,
    this.autofocusLastEmpty = false,
    this.onAutofocusConsumed,
  });

  @override
  State<_PendingStudentsEditor> createState() => _PendingStudentsEditorState();
}

class _PendingStudentsEditorState extends State<_PendingStudentsEditor> {
  // Controllers keyed by a stable row id to avoid index-shift bugs on remove.
  final Map<String, TextEditingController> _controllersByKey = {};
  final Map<String, FocusNode> _focusNodesByKey = {};
  final Map<String, GlobalKey> _itemKeys = {};
  late List<String> _rowKeys;

  @override
  void initState() {
    super.initState();
    _rowKeys = List<String>.generate(
        widget.names.length, (i) => _makeRowKey(widget.names[i], i));
    for (var i = 0; i < widget.names.length; i++) {
      final key = _rowKeys[i];
      _controllersByKey[key] = TextEditingController(text: widget.names[i]);
      _focusNodesByKey.putIfAbsent(key, () => FocusNode());
      _itemKeys.putIfAbsent(key, () => GlobalKey());
    }
  }

  String _makeRowKey(String name, int index) {
    // Use value + index to keep it stable across rebuilds and allow duplicates.
    return '${name.hashCode}::$index';
  }

  @override
  void didUpdateWidget(covariant _PendingStudentsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reconcile controllers/keys safely for any change (including 0 -> N).
    final remainingControllers = <String, TextEditingController>{};
    final newKeys = <String>[];

    // Prefer keeping the same row key by position when possible.
    final byPosition = _rowKeys;
    for (var i = 0; i < widget.names.length; i++) {
      final name = widget.names[i];
      final key = (i < byPosition.length) ? byPosition[i] : null;
      final existing = (key != null) ? _controllersByKey[key] : null;

      final resolvedKey = key ?? _makeRowKey(name, i);
      newKeys.add(resolvedKey);

      if (existing != null) {
        // Update text to reflect latest model.
        if (existing.text != name) existing.text = name;
        remainingControllers[resolvedKey] = existing;
      } else {
        remainingControllers[resolvedKey] = TextEditingController(text: name);
        _focusNodesByKey.putIfAbsent(resolvedKey, () => FocusNode());
        _itemKeys.putIfAbsent(resolvedKey, () => GlobalKey());
      }
    }

    // Dispose controllers that are no longer used.
    final newKeySet = newKeys.toSet();
    for (final entry in _controllersByKey.entries) {
      if (!newKeySet.contains(entry.key)) {
        entry.value.dispose();
        _focusNodesByKey[entry.key]?.dispose();
        _focusNodesByKey.remove(entry.key);
        _itemKeys.remove(entry.key);
      }
    }

    _controllersByKey
      ..clear()
      ..addAll(remainingControllers);
    _rowKeys = newKeys;
  }

  @override
  void dispose() {
    for (final c in _controllersByKey.values) {
      c.dispose();
    }
    for (final f in _focusNodesByKey.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusIndex = (widget.autofocusLastEmpty &&
            widget.names.isNotEmpty &&
            widget.names.last.trim().isEmpty)
        ? widget.names.length - 1
        : null;

    if (focusIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Ensure the item is visible by using the stored GlobalKey and
        // Scrollable.ensureVisible. Then request focus on its FocusNode.
        final targetKey = _rowKeys[focusIndex];
        final gk = _itemKeys[targetKey];
        try {
          if (gk != null && gk.currentContext != null) {
            await Scrollable.ensureVisible(
              gk.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        } catch (_) {}

        final node = _focusNodesByKey[targetKey];
        if (node != null && mounted) {
          node.requestFocus();
        }

        widget.onAutofocusConsumed?.call();
      });
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.names.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final rowKey = _rowKeys[index];
        final controller = _controllersByKey[rowKey]!;
        return Row(
          key: ValueKey(rowKey),
          // Attach a GlobalKey to the row container so we can scroll to it.
          // Wrap child in a KeyedSubtree to host the GlobalKey.
          // Note: ValueKey remains for item identity in ListView.
          children: [
            Expanded(
              key: _itemKeys[rowKey],
              child: TextField(
                controller: controller,
                autofocus: focusIndex == index,
                focusNode: _focusNodesByKey[rowKey],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => widget.onChanged(index, v),
              ),
            ),
            IconButton(
              tooltip: 'Remover',
              icon: const Icon(Icons.close),
              onPressed: () {
                // Remove the tapped row key first to keep indices consistent.
                final removeIndex = index;
                setState(() {
                  if (removeIndex >= 0 && removeIndex < _rowKeys.length) {
                    final k = _rowKeys.removeAt(removeIndex);
                    final c = _controllersByKey.remove(k);
                    c?.dispose();
                    _focusNodesByKey[k]?.dispose();
                    _focusNodesByKey.remove(k);
                    _itemKeys.remove(k);
                  }
                });
                widget.onRemove(removeIndex);
              },
            ),
          ],
        );
      },
    );
  }
}

class _ParsedTurmaNome {
  final String instituicao;
  final String? letra;

  const _ParsedTurmaNome({required this.instituicao, required this.letra});
}
