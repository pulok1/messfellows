import 'package:flutter/material.dart';

/// A "label ... value" row spaced to the edges, used for stat/summary lists
/// (member detail, report totals, close-month review) so they all share one
/// look instead of each screen hand-rolling its own Row.
class LabeledValueRow extends StatelessWidget {
  final String label;
  final String value;

  /// Whether the label is shown in the secondary (onSurfaceVariant) color.
  /// Dialog content (e.g. the close-month review) reads fine with the
  /// default text color instead, so this can be turned off there.
  final bool mutedLabel;

  const LabeledValueRow({
    super.key,
    required this.label,
    required this.value,
    this.mutedLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: mutedLabel
                ? TextStyle(color: colorScheme.onSurfaceVariant)
                : null,
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
