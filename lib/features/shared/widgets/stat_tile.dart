import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'count_up_text.dart';

/// A single labeled stat, used in pairs on the dashboard (Total Bazar /
/// Total Meals).
class StatTile extends StatelessWidget {
  final String label;
  final String? value;
  final num? count;
  final String Function(double value)? format;

  const StatTile({super.key, required this.label, required String this.value})
    : count = null,
      format = null;

  /// A tile whose number counts up to [count], shown through [format].
  const StatTile.animated({
    super.key,
    required this.label,
    required num this.count,
    required String Function(double value) this.format,
  }) : value = null;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontWeight: FontWeight.bold);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (count case final count?)
              CountUpText(value: count, format: format!, style: valueStyle)
            else
              Text(value!, style: valueStyle),
          ],
        ),
      ),
    );
  }
}
