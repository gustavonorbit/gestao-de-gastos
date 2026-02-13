import 'package:flutter/material.dart';

Future<bool?> showImportStudentsInfoDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Adicionar alunos por foto'),
        content: const Text(
          'A adição de alunos deve ser feita por foto, tirando uma foto da lista de nomes (papel ou monitor).\n\n'
          'O reconhecimento acontece offline no aparelho.\n'
          'Em seguida você poderá revisar/editar os nomes antes de salvar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      );
    },
  );
}
