import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Mantido apenas por compatibilidade com referências antigas.
// A criação agora acontece em /turmas/nova usando TurmaFormScreen.

class CreateTurmaScreen extends ConsumerStatefulWidget {
  const CreateTurmaScreen({super.key});

  @override
  ConsumerState<CreateTurmaScreen> createState() => _CreateTurmaScreenState();
}

class _CreateTurmaScreenState extends ConsumerState<CreateTurmaScreen> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/turmas/nova');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
