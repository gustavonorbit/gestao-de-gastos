import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:educa_plus/app/providers.dart'
  show turmaRepositoryProvider, aulaRepositoryProvider, alunoRepositoryProvider, presencaRepositoryProvider, notaRepositoryProvider, conteudoRepositoryProvider, observacoesRepositoryProvider;
import 'package:educa_plus/services/export_service.dart' show ExportService, TurmaExportData, ExportAluno, ExportAula, ExportPresenca, ExportNota;
import 'package:educa_plus/services/aula_csv_export_service.dart' show AulaCsvExportService, AulaCsvExportData, AulaCsvExportAula, AulaCsvExportAluno, AulaCsvExportPresenca;
import 'package:educa_plus/services/web_download.dart' show webDownloadCsv;
import 'package:educa_plus/ui/feedback/app_feedback.dart';
import 'package:educa_plus/services/conteudo_export_helper.dart' show buildConteudoTextoFinal;
import 'package:educa_plus/domain/entities/turma.dart' show Turma;

class FechamentoScreen extends ConsumerStatefulWidget {
  const FechamentoScreen({super.key});

  @override
  ConsumerState<FechamentoScreen> createState() => _FechamentoScreenState();
}

class _FechamentoScreenState extends ConsumerState<FechamentoScreen> {
  int? _selectedTurmaId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeInactive = false;
  bool _loading = false;
  
  List<Turma> _turmas = [];

  Turma? get _selectedTurma {
    if (_selectedTurmaId == null) return null;
    try {
      return _turmas.firstWhere((t) => t.id == _selectedTurmaId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTurmas);
  }

  Future<void> _loadTurmas() async {
    final repo = ref.read(turmaRepositoryProvider);
    final t = await repo.getAll(onlyActive: null);
    if (!mounted) return;
    setState(() => _turmas = t);
  }

  bool get _periodValid {
    if (_startDate == null || _endDate == null) return false;
    return !_endDate!.isBefore(_startDate!);
  }

  Future<void> _onTurmaChanged(int? id) async {
    setState(() {
      _selectedTurmaId = id;
    });

    if (id == null) return;

    // Default dates: first aula of turma -> today
    final aulaRepo = ref.read(aulaRepositoryProvider);
    final aulas = await aulaRepo.getAllForTurma(id);
    DateTime? first;
    for (final a in aulas) {
      if (a.data != null) {
        first = a.data as DateTime;
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      _startDate = first ?? DateTime.now();
      _endDate = DateTime.now();
    });
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initial = _startDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _endDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _endDate = picked);
  }

  Future<void> _generate() async {
    if (_selectedTurmaId == null) return;
    if (!_periodValid) {
      AppFeedback.show(context, message: 'Período inválido.', type: FeedbackType.error);
      return;
    }

    setState(() => _loading = true);
    try {
      final turmaRepo = ref.read(turmaRepositoryProvider);
      final aulaRepo = ref.read(aulaRepositoryProvider);
      final alunoRepo = ref.read(alunoRepositoryProvider);
      final presRepo = ref.read(presencaRepositoryProvider);
      final notaRepo = ref.read(notaRepositoryProvider);
      final conteudoRepo = ref.read(conteudoRepositoryProvider);
        final observRepo = ref.read(observacoesRepositoryProvider);

  final turma = _selectedTurma ?? await turmaRepo.getById(_selectedTurmaId!);
  final allAulas = await aulaRepo.getAllForTurma(_selectedTurmaId!);

      final aulasInRange = allAulas.where((a) {
        final d = a.data as DateTime;
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList(growable: false);

      if (aulasInRange.isEmpty) {
        AppFeedback.show(context, message: 'Nenhuma aula encontrada no período selecionado.', type: FeedbackType.error);
        return;
      }

      // Build alunos list according to includeInactive flag.
  final activeAlunos = await alunoRepo.getAllForTurma(_selectedTurmaId!, onlyActive: true);
      final alunos = <ExportAluno>[];
      alunos.addAll(activeAlunos.where((a) => a.id != null).map((a) => ExportAluno(id: a.id!, nome: a.nome)));

      if (_includeInactive) {
  final inactive = await alunoRepo.getAllForTurma(_selectedTurmaId!, onlyActive: false);
        // collect participating alunoIds from presencas in period
        final participated = <int>{};
        for (final aula in aulasInRange) {
          final pres = await presRepo.getAllForAula(aula.id as int);
          for (final p in pres) {
            participated.add(p.alunoId);
          }
        }
        for (final ia in inactive.where((a) => a.id != null)) {
          if (participated.contains(ia.id)) {
            alunos.add(ExportAluno(id: ia.id!, nome: ia.nome));
          }
        }
      }

      // Build aulas export data with optional content
      final exportAulas = <ExportAula>[];
      for (final a in aulasInRange) {
        final conteudos = await conteudoRepo.getAllForAula(a.id as int);
        final conteudoFinal = buildConteudoTextoFinal(conteudos.map((c) => c.texto).toList(growable: false));
        final obs = await observRepo.getAllForAula(a.id as int);
        final obsTexts = obs.map((o) => o.texto).where((t) => t.trim().isNotEmpty).toList(growable: false);
        exportAulas.add(ExportAula(
          id: a.id as int,
          data: a.data as DateTime,
          conteudo: conteudoFinal,
          presencaAbas: a.presencaAbas,
          observacoes: obsTexts,
        ));
      }

      // Build presencas and notas
      final exportPresencas = <ExportPresenca>[];
      final exportNotas = <ExportNota>[];

      for (final a in aulasInRange) {
        final pres = await presRepo.getAllForAula(a.id as int);
        for (final p in pres) {
          exportPresencas.add(ExportPresenca(
            aulaId: p.aulaId,
            alunoId: p.alunoId,
            aulaIndex: p.aulaIndex,
            presente: p.presente,
            justificativa: p.justificativa,
          ));
        }

        final notas = await notaRepo.getNotasAluno(a.id as int);
        // Try to fetch the NotaAula metadata (tipo, titulo) for this aula so
        // the export can show the professor-provided title when available.
        final notaAula = await notaRepo.getNotaAula(a.id as int);
        for (final n in notas) {
          exportNotas.add(ExportNota(
            aulaId: n.aulaId,
            alunoId: n.alunoId,
            tipo: null,
            valor: n.valor,
            titulo: notaAula?.titulo,
          ));
        }
      }

      final turmaExport = TurmaExportData(
        turmaName: turma?.nome ?? 'Turma',
        alunos: alunos,
        aulas: exportAulas,
        presencas: exportPresencas,
        notas: exportNotas,
      );

      if (kIsWeb) {
        // Build CSV using existing service and trigger web download.
        final assemblerAulas = aulasInRange.map((a) => AulaCsvExportAula(id: a.id as int, data: a.data as DateTime, turmaNome: turma?.nome ?? '')).toList(growable: false);
        // re-use alunos in CSV DTO
        final csvAlunos = alunos.map((a) => AulaCsvExportAluno(id: a.id, nome: a.nome)).toList(growable: false);
        // presencas: need converted type
        final csvPresencas = exportPresencas.map((p) => AulaCsvExportPresenca(aulaId: p.aulaId, alunoId: p.alunoId, presente: p.presente, justificativa: p.justificativa)).toList(growable: false);
        final csvData = AulaCsvExportData(aulas: assemblerAulas, alunos: csvAlunos, presencas: csvPresencas, conteudosPorAulaId: {});
        final csv = AulaCsvExportService().buildCsv(csvData);
        final filename = '${turma?.nome ?? 'turma' }.csv';
        await webDownloadCsv(filename, csv);
        AppFeedback.success(context, 'Planilha gerada com sucesso.');
      } else {
        final path = await ExportService().exportTurmasToXlsx([turmaExport], filename: '${turma?.nome ?? 'turma' }.xlsx', saveToDownloads: false);

        // Share on mobile, on desktop we still open the file using share (will trigger system chooser)
        try {
          final xfile = XFile(path);
          await Share.shareXFiles([xfile], text: 'Fechamento: ${turma?.nome ?? ''}');
        } catch (_) {
          // If sharing fails, just show success and the file path
          AppFeedback.success(context, 'Planilha gerada com sucesso.');
        }
      }

    } catch (e) {
      AppFeedback.show(context, message: 'Erro ao gerar planilha: ${e.toString()}', type: FeedbackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechamento'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Turma selector
              DropdownButtonFormField<int>(
                value: _selectedTurmaId,
                decoration: const InputDecoration(labelText: 'Turma', hintText: 'Selecione uma turma'),
                items: _turmas.map((t) {
                  final nome = t.nome;
                  final ativa = t.ativa;
                  return DropdownMenuItem<int>(
                    value: t.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!ativa) ...[
                          const SizedBox(width: 8),
                          Text('Inativa', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ],
                    ),
                  );
                }).toList(growable: false),
                onChanged: (v) => _onTurmaChanged(v),
              ),
              const SizedBox(height: 12),

              // Period selector
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Período', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _startDate == null ? null : _pickStartDate,
                          child: Text(_startDate == null ? 'Data inicial' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _endDate == null ? null : _pickEndDate,
                          child: Text(_endDate == null ? 'Data final' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                        ),
                      ),
                    ])
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              const Text('Serão exportadas apenas aulas dentro deste período.', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),

              // Include inactive toggle
              SwitchListTile(
                title: const Text('Incluir alunos inativos'),
                subtitle: const Text('Alunos inativos podem ter participado de aulas anteriores.'),
                value: _includeInactive,
                onChanged: (v) => setState(() => _includeInactive = v),
              ),

              const SizedBox(height: 12),

              // Informative block
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'A planilha será gerada automaticamente com:\n - Alunos\n - Aulas\n - Presenças\n - Notas\n - Conteúdos\n - Observações',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Dynamic summary
              if (_selectedTurmaId != null && _periodValid) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Builder(builder: (context) {
                      final turmaNome = _selectedTurma?.nome ?? '';
                      final inativosText = _includeInactive ? 'Sim' : 'Não';
                      final start = '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
                      final end = '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
                      return Text('Você está gerando o fechamento de:\n - Turma: $turmaNome\n - Período: $start até $end\n - Alunos inativos: $inativosText');
                    }),
                  ),
                ),
              ],

              const Spacer(),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedTurmaId == null || !_periodValid || _loading) ? null : _generate,
                  child: _loading ? const Text('Gerando planilha...') : const Text('Gerar planilha'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
