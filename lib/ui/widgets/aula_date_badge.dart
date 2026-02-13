import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Small, reusable widget to show the lesson date on the right side of an AppBar.
///
/// Displays two lines:
/// - dd/MM/yyyy
/// - day of week (pt-BR)
class AulaDateBadge extends StatelessWidget {
  final DateTime date;

  const AulaDateBadge({
    super.key,
    required this.date,
  });

  /// Height of the default Material toolbar.
  ///
  /// Keeping the badge within this height avoids actions accidentally
  /// expanding their hit-test region over leading/title.
  static const double kToolbarHeight = 56.0;

  static String _formatWithLocale(
      String pattern, DateTime date, String locale) {
    return DateFormat(pattern, locale).format(date);
  }

  static String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Use the device locale from the Flutter localization tree.
    // Locale.toString() yields tags like "pt_BR", which Intl understands.
    final locale = Localizations.localeOf(context).toString();
    final color = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;

    final dateText = _formatWithLocale('dd/MM/yyyy', date, locale);
    final weekdayText =
        _capitalizeFirst(_formatWithLocale('EEEE', date, locale).trim());

    return SizedBox(
      height: kToolbarHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 84),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: color),
                ),
                Text(
                  weekdayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: color.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
