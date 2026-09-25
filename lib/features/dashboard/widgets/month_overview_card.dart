import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/month_calculation_result.dart';
import '../../shared/widgets/count_up_text.dart';

/// The Dashboard's headline numbers — meal rate, total bazar, total meals —
/// unified into one card instead of a separate rate card plus a stat row,
/// so the three most important figures on the screen read as one glanceable
/// group rather than two unevenly-weighted blocks. The meal rate carries an
/// optional trend badge sourced from [InsightEngine]'s own rate-change
/// calculation, so the "smart" comparison to last month shows up right on
/// the number it's about instead of only in the Insights list below.
class MonthOverviewCard extends StatelessWidget {
  final MonthCalculationResult calculation;
  final String currencySymbol;

  /// Positive = more expensive than last month. Null hides the badge —
  /// there's nothing to compare against yet, or the change isn't
  /// significant enough for [InsightEngine] to have surfaced it.
  final int? rateChangePercent;

  const MonthOverviewCard({
    super.key,
    required this.calculation,
    required this.currencySymbol,
    this.rateChangePercent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricIcon(
                  icon: Icons.payments_outlined,
                  background: colorScheme.primaryContainer,
                  foreground: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentMealRate,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (calculation.hasNoMeals)
                            Text(
                              l10n.noMealsRecordedYet,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            Flexible(
                              child: CountUpText(
                                value: calculation.mealRate.major,
                                format: (v) =>
                                    '$currencySymbol${v.toStringAsFixed(2)}',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (rateChangePercent != null &&
                              rateChangePercent != 0) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _TrendBadge(percent: rateChangePercent!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.shopping_basket_outlined,
                    label: l10n.totalBazar,
                    count: calculation.totalExpense.minorUnits,
                    format: (v) =>
                        v == calculation.totalExpense.minorUnits
                        ? calculation.totalExpense.format()
                        : Money((v / 100).round() * 100).format(),
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: VerticalDivider(
                    width: AppSpacing.md * 2,
                    color: colorScheme.outlineVariant,
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.restaurant_outlined,
                    label: l10n.totalMeals,
                    count: calculation.totalMeals,
                    format: (v) => '${v.round()}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _MetricIcon({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Icon(icon, color: foreground),
    );
  }
}

/// A muted "▲ 6%" / "▼ 6%" pill next to the meal rate. Deliberately neutral
/// (not green-good/red-bad) — a rising rate isn't necessarily a bad thing
/// (better groceries cost more too), just something worth noticing.
class _TrendBadge extends StatelessWidget {
  final int percent;

  const _TrendBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final up = percent > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              up ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: colorScheme.onTertiaryContainer,
            ),
            Text(
              '${percent.abs()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final num count;
  final String Function(double value) format;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.count,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              CountUpText(
                value: count,
                format: format,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
