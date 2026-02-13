import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/app/providers.dart' show appTextScaleProvider;
import 'package:educa_plus/ui/feedback/app_feedback.dart';

class AcessibilidadeScreen extends ConsumerWidget {
  const AcessibilidadeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final scale = ref.watch(appTextScaleProvider);
  final notifier = ref.read(appTextScaleProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Acessibilidade')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Texto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<double>(
                  title: const Text('Normal'),
                  value: 1.0,
                  groupValue: scale,
                  onChanged: (v) async {
                    if (v == null) return;
                    await notifier.setScale(v);
                    AppFeedback.show(context, message: 'Tamanho do texto atualizado');
                  },
                ),
                RadioListTile<double>(
                  title: const Text('Médio'),
                  value: 1.1,
                  groupValue: scale,
                  onChanged: (v) async {
                    if (v == null) return;
                    await notifier.setScale(v);
                    AppFeedback.show(context, message: 'Tamanho do texto atualizado');
                  },
                ),
                RadioListTile<double>(
                  title: const Text('Grande'),
                  value: 1.2,
                  groupValue: scale,
                  onChanged: (v) async {
                    if (v == null) return;
                    await notifier.setScale(v);
                    AppFeedback.show(context, message: 'Tamanho do texto atualizado');
                  },
                ),
              ],
            ),
          ),

          // nothing else — only text scale is available here
        ],
      ),
    );
  }
}
