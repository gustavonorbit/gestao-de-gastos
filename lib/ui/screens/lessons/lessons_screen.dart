import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  final int turmaId;

  const LessonsScreen({super.key, required this.turmaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aulas')),
      body: Center(
        child: Text('Aulas da turma $turmaId'),
      ),
    );
  }
}
