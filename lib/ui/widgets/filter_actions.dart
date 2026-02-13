import 'package:flutter/material.dart';

/// Reusable action row for filter sheets.
///
/// Provides a secondary-but-visible "Limpar filtros" action (icon + label)
/// and a primary "Aplicar" action. The widget is intentionally simple so
/// it can be used by multiple filter sheets.
class FilterActionRow extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onApply;
  final String clearLabel;
  final String applyLabel;

  const FilterActionRow({
    Key? key,
    required this.onClear,
    required this.onApply,
    this.clearLabel = 'Limpar filtros',
    this.applyLabel = 'Aplicar',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use an outlined button for the clear action so it's visible but
    // clearly secondary to the primary "Aplicar" ElevatedButton.
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.clear),
          label: Text(clearLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.08),
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onApply,
          icon: const Icon(Icons.check),
          label: Text(applyLabel),
        ),
      ],
    );
  }
}
