import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/month_calculation_result.dart';
import '../../shared/widgets/count_up_text.dart';

/// The Dashboard's headline numbers — meal rate, total bazar, total meals —
/// unified into one card instead of a separate rate card plus a stat row,
/// so the three most important figures on the screen read as one glanceable
/// group rather than two unevenly-weighted blocks. The meal rate leads in a
/// large brand-green figure and carries an optional trend badge sourced
/// from [InsightEngine]'s own rate-change calculation, so the "smart"
/// comparison to last month shows up right on the number it's about
/// instead of only in the Insights list below.
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
            Text(
              l10n.currentMealRate.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (calculation.hasNoMeals)
                  Flexible(
                    child: Text(
                      l10n.noMealsRecordedYet,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: CountUpText(
                      value: calculation.mealRate.major,
                      format: (v) => '$currencySymbol${v.toStringAsFixed(2)}',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppTheme.headlineFigureColor(colorScheme),
                      ),
                    ),
                  ),
                if (rateChangePercent != null && rateChangePercent != 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _TrendBadge(percent: rateChangePercent!),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.shopping_basket_outlined,
                    label: l10n.totalBazar,
                    count: calculation.totalExpense.minorUnits,
                    format: (v) => v == calculation.totalExpense.minorUnits
                        ? calculation.totalExpense.format()
                        : Money((v / 100).round() * 100).format(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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

/// A soft amber "▲ 6%" / "▼ 6%" pill next to the meal rate. Deliberately
/// neutral (not green-good/red-bad) — a rising rate isn't necessarily a bad
/// thing (better groceries cost more too), just something worth noticing.
class _TrendBadge extends StatelessWidget {
  final int percent;

  const _TrendBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = AppTheme.noticeColors(
      Theme.of(context).colorScheme,
    );
    final up = percent > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: foreground,
          ),
          Text(
            '${percent.abs()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the two secondary figures under the meal rate, on a soft tile of
/// the body colour so the pair reads as a set beneath the headline.
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          CountUpText(
            value: count,
            format: format,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
