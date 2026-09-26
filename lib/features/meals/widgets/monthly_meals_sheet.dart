import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/localized_date.dart';
import '../../../core/utils/meal_gaps.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/meal_entry.dart';
import '../../../models/mess.dart';
import '../../../providers/meal_providers.dart';
import '../../../providers/month_calculation_provider.dart';

/// Opens [MonthlyMealsSheet] for [year]/[month]. Tapping one of its
/// unrecorded days calls [onJumpToDay] after the sheet closes.
Future<void> showMonthlyMealsSheet(
  BuildContext context, {
  required Mess mess,
  required int year,
  required int month,
  required ValueChanged<DateTime> onJumpToDay,
}) async {
  final day = await showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => MonthlyMealsSheet(mess: mess, year: year, month: month),
  );
  if (day != null) onJumpToDay(day);
}

/// A month's meal counts per member, broken down by meal so a member can
/// check exactly where their number comes from, plus any days in the month
/// with nothing recorded — each one tappable to go and fill it in.
///
/// Watches its own providers (rather than being handed a snapshot) so the
/// numbers stay live while it's open.
class MonthlyMealsSheet extends ConsumerWidget {
  final Mess mess;
  final int year;
  final int month;

  const MonthlyMealsSheet({
    super.key,
    required this.mess,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final params = (messId: mess.id, year: year, month: month);
    final result = ref.watch(monthCalculationProvider(params));
    final meals =
        ref.watch(mealsForMonthProvider(params)).value ?? const <MealEntry>[];

    final slotTotals = <String, MealCounts>{};
    for (final meal in meals) {
      final sum = slotTotals[meal.memberId] ?? noMeals;
      slotTotals[meal.memberId] = (
        breakfast: sum.breakfast + meal.breakfast,
        lunch: sum.lunch + meal.lunch,
        dinner: sum.dinner + meal.dinner,
      );
    }
    final gaps = unrecordedMealDays(
      meals,
      year: year,
      month: month,
      today: dateOnly(DateTime.now()),
    );

    String breakdown(MealCounts counts) => [
      if (mess.trackBreakfast) '${l10n.breakfastLabel} ${counts.breakfast}',
      if (mess.trackLunch) '${l10n.lunchLabel} ${counts.lunch}',
      if (mess.trackDinner) '${l10n.dinnerLabel} ${counts.dinner}',
    ].join(' · ');

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            Text(
              l10n.monthlyMealCountsTitle(
                formatMonthYear(context, year, month),
              ),
              style: theme.textTheme.titleMedium,
            ),
            Text(
              l10n.totalMealsLine('${result.totalMeals}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (gaps.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _UnrecordedDays(days: gaps),
            ],
            const SizedBox(height: AppSpacing.md),
            if (result.memberBalances.isEmpty) Text(l10n.noMembersYetInline),
            for (final balance in result.memberBalances)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(balance.memberName),
                          Text(
                            breakdown(slotTotals[balance.memberId] ?? noMeals),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.mealsCount(balance.mealCount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnrecordedDays extends StatelessWidget {
  final List<DateTime> days;

  const _UnrecordedDays({required this.days});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 18,
                color: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.unrecordedDaysTitle(days.length),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.unrecordedDaysHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final day in days)
                ActionChip(
                  label: Text(formatDayMonth(context, day)),
                  onPressed: () => Navigator.of(context).pop(day),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
