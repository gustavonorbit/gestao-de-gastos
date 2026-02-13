/// Utilities for generating Excel/Sheets-compatible CSV.
///
/// Goals:
/// - stable CSV with proper quoting
/// - sanitize text fields to avoid line breaks/column issues
/// - keep implementation UI-free & DB-free (pure functions)
class CsvExportUtils {
  CsvExportUtils._();

  /// Sanitizes a free-text value for exporting.
  ///
  /// Rules (as requested):
  /// - trim
  /// - remove line breaks (\n, \r)
  /// - collapse multiple whitespace to a single space
  ///
  /// Note: this doesn't apply CSV quoting; see [escapeCsvField].
  static String sanitizeText(String? input) {
    if (input == null) return '';

    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    // Replace any line breaks with spaces.
    final noLines = trimmed.replaceAll(RegExp(r'[\r\n]+'), ' ');

    // Collapse consecutive whitespace to a single space.
    final collapsed = noLines.replaceAll(RegExp(r'\s+'), ' ');

    return collapsed.trim();
  }

  /// Escapes a field according to RFC4180-ish CSV rules.
  ///
  /// - Always wraps in double-quotes.
  /// - Doubles inner quotes.
  ///
  /// Always-quote makes the output more stable for Excel/Sheets and avoids
  /// separator issues (commas, semicolons, etc).
  static String escapeCsvField(String value) {
    final v = value.replaceAll('"', '""');
    return '"$v"';
  }

  /// Formats a CSV row from raw values.
  ///
  /// Each value is sanitized via [sanitizeText] and then escaped.
  static String row(List<String?> values, {String separator = ','}) {
    return values.map((v) => escapeCsvField(sanitizeText(v))).join(separator);
  }
}
