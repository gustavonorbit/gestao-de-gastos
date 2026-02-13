import 'package:flutter/material.dart';

/// Abre o date picker de forma segura:
/// - desfoca o foco atual (fecha teclado)
/// - captura exceções e retorna null em falha
Future<DateTime?> pickDateSafe(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  try {
    final currentFocus = FocusScope.of(context);
    if (currentFocus.hasFocus) currentFocus.unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
    );
    return picked;
  } catch (_) {
    return null;
  }
}
