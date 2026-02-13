import 'package:flutter/material.dart';
import 'package:educa_plus/ui/feedback/app_feedback.dart';

/// Helper to parse and format grade inputs according to UX rules.
class NotaFormatter {
  /// Parses user input loosely applying heuristics described in the UX spec.
  /// Returns null when input is empty.
  static double? parseLoose(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;

    // Reject inputs that contain letters or multiple separators in weird places
    final normalized = t.replaceAll(',', '.');
    // Allow digits and single dot
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(normalized)) return double.nan;

    if (normalized.contains('.')) {
      return double.tryParse(normalized);
    }

    // No decimal separator: apply heuristics
    final digits = normalized;
    // If starts with '0' and length >=2 -> treat as 0.x (05 -> 0.5)
    if (digits.length >= 2 && digits.startsWith('0')) {
      final rest = digits.substring(1);
      final v = double.tryParse('0.${rest}');
      if (v != null) return v;
    }

    final intVal = int.tryParse(digits);
    if (intVal == null) return double.nan;

    // If small integer (<=10) treat as whole number (5 -> 5.0, 10 -> 10.0)
    if (intVal <= 10) return intVal.toDouble();

    // Otherwise, assume trailing digit is decimal fractional (75 -> 7.5,
    // 123 -> 12.3). Divide by 10.
    return intVal / 10.0;
  }

  /// Formats a parsed value to pt-BR one decimal place string (comma).
  static String formatForDisplay(double value) {
    final rounded = (value * 10).roundToDouble() / 10;
    // Ensure one decimal place and comma separator
    final s = rounded.toStringAsFixed(1).replaceAll('.', ',');
    return s;
  }

  /// Applies full flow: parses raw input, sanitizes against limits and returns
  /// a tuple (sanitizedDouble, formattedString, feedbackMessageOrNull).
  /// If parsing fails (invalid), returns (0.0, '0,0', infoMessage).
  static Map<String, Object?> apply(
    BuildContext context,
    String raw, {
    double? max,
  }) {
    final p = parseLoose(raw);
    if (p == null) {
      // empty -> treat as null -> show no feedback, leave empty
      return {'value': null, 'text': '' , 'feedback': null};
    }
    if (p.isNaN) {
      // invalid input
      final msg = 'Entrada inválida. Valor ajustado para 0,0.';
      return {'value': 0.0, 'text': '0,0', 'feedback': msg};
    }

    var v = p;
    // Round to 1 decimal
    v = (v * 10).roundToDouble() / 10;

    if (v < 0) v = 0.0;
    if (max != null && v > max) {
      final msg = 'Valor maior que o máximo; ajustado para o valor máximo.';
      return {'value': max, 'text': formatForDisplay(max), 'feedback': msg};
    }

    // Normal case: formatted string, no feedback
    return {'value': v, 'text': formatForDisplay(v), 'feedback': null};
  }
}
