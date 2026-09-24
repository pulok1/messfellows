import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/insight.dart';
import '../../../providers/insight_providers.dart';
import '../../shared/widgets/staggered_entrance.dart';

/// A few short, data-driven observations about the current month (see
/// [InsightEngine]), shown on the Dashboard only when there's something
/// worth saying. Grows and shrinks smoothly as insights come and go.
class InsightsCard extends ConsumerWidget {
  final String messId;
  final String currencySymbol;

  /// Opens the Meals tab, for the "today's meals aren't marked" insight.
  final VoidCallback? onOpenMeals;

  /// Keeps the card glanceable; the engine already orders by usefulness.
  static const maxShown = 3;

  const InsightsCard({
    super.key,
    required this.messId,
    required this.currencySymbol,
    this.onOpenMeals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final insights = ref
        .watch(
          dashboardInsightsProvider((
            messId: messId,
            hour: DateTime(now.year, now.month, now.day, now.hour),
          )),
        )
        .take(maxShown)
        .toList();

    return AnimatedSize(
      duration: AppMotion.of(context, AppMotion.medium),
      curve: AppMotion.emphasized,
      alignment: Alignment.topCenter,
      child: insights.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(),
                      const SizedBox(height: AppSpacing.xs),
                      for (final (i, insight) in insights.indexed)
                        StaggeredEntrance(
                          key: ValueKey(insight.runtimeType),
                          index: i,
                          child: _InsightRow(
                            insight: insight,
                            currencySymbol: currencySymbol,
                            onOpenMeals: onOpenMeals,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          AppLocalizations.of(context).insightsTitle,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final Insight insight;
  final String currencySymbol;
  final VoidCallback? onOpenMeals;

  const _InsightRow({
    required this.insight,
    required this.currencySymbol,
    required this.onOpenMeals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, text) = switch (insight) {
      MealsNotMarkedToday() => (
        Icons.restaurant_outlined,
        l10n.insightMealsNotMarkedToday,
      ),
      NoRecentBazar(:final days) => (
        Icons.shopping_basket_outlined,
        l10n.insightNoRecentBazar(days),
      ),
      MealRateChange(:final percent, :final previousRate) => (
        percent > 0 ? Icons.trending_up : Icons.trending_down,
        (percent > 0 ? l10n.insightMealRateUp : l10n.insightMealRateDown)(
          percent.abs(),
          previousRate.format(currencySymbol: currencySymbol),
        ),
      ),
      MembersWithoutBazar(:final memberNames) => (
        Icons.person_search_outlined,
        memberNames.length == 1
            ? l10n.insightOneMemberNoBazar(memberNames.single)
            : l10n.insightMembersNoBazar(_nameList(l10n, memberNames)),
      ),
      BazarProjection(:final projectedTotal) => (
        Icons.insights_outlined,
        l10n.insightBazarProjection(
          projectedTotal.format(currencySymbol: currencySymbol),
        ),
      ),
    };

    final action = insight is MealsNotMarkedToday && onOpenMeals != null
        ? TextButton(
            onPressed: onOpenMeals,
            child: Text(l10n.insightMarkMealsAction),
          )
        : null;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  /// "A, B" or "A, B, 3 others" — long lists would crowd the card.
  static String _nameList(AppLocalizations l10n, List<String> names) {
    const shown = 2;
    return [
      ...names.take(shown),
      if (names.length > shown) l10n.insightMoreMembers(names.length - shown),
    ].join(', ');
  }
}
