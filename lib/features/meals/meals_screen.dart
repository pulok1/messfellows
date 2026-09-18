import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/meal_entry.dart';
import '../../models/mess.dart';
import '../../providers/meal_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/selection_providers.dart';
import '../members/add_edit_member_dialog.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';
import 'widgets/meal_day_row.dart';

/// The daily meal tracker (sections 14/15) — the screen a manager is
/// expected to open several times a day, so it defaults to today and
/// requires no navigation or confirmation to mark a meal off.
class MealsScreen extends ConsumerWidget {
  final Mess mess;

  const MealsScreen({super.key, required this.mess});

  String get messId => mess.id;

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      ref.read(selectedMealDateProvider.notifier).goTo(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final date = ref.watch(selectedMealDateProvider);
    final membersAsync = ref.watch(activeMembersProvider(messId));
    final mealsAsync = ref.watch(mealsForDateProvider((messId: messId, date: date)));
    final isToday = _isSameDay(date, DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: l10n.navMeals,
              showBackButton: false,
              actions: [
                HeaderIconButton(
                  icon: Icons.bar_chart_outlined,
                  tooltip: l10n.monthlyTotalsTooltip,
                  onPressed: () => _showMonthlyTotals(context, ref, date),
                ),
              ],
              bottom: _DateBar(
                date: date,
                isToday: isToday,
                onToday: () => ref.read(selectedMealDateProvider.notifier).goToToday(),
                onPrevious: () => ref.read(selectedMealDateProvider.notifier).goToPreviousDay(),
                onNext: () => ref.read(selectedMealDateProvider.notifier).goToNextDay(),
                onPickDate: () => _pickDate(context, ref, date),
              ),
            ),
            Expanded(
              child: membersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return EmptyState(
                      icon: Icons.group_outlined,
                      title: l10n.noMembersYetTitle,
                      message: l10n.addMembersToTrackMeals,
                      actionLabel: l10n.addMember,
                      onAction: () => showAddEditMemberDialog(context, messId: messId),
                    );
                  }

                  final meals = mealsAsync.value ?? const <MealEntry>[];
                  final mealsByMember = {for (final meal in meals) meal.memberId: meal};

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: members.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final meal = mealsByMember[member.id];
                      return MealDayRow(
                        member: member,
                        breakfast: meal?.breakfast ?? 0,
                        lunch: meal?.lunch ?? 0,
                        dinner: meal?.dinner ?? 0,
                        showBreakfast: mess.trackBreakfast,
                        showLunch: mess.trackLunch,
                        showDinner: mess.trackDinner,
                        onBreakfastChanged: (value) => ref
                            .read(mealRepositoryProvider)
                            .setMeal(
                              messId: messId,
                              memberId: member.id,
                              date: date,
                              breakfast: value,
                            ),
                        onLunchChanged: (value) => ref
                            .read(mealRepositoryProvider)
                            .setMeal(
                              messId: messId,
                              memberId: member.id,
                              date: date,
                              lunch: value,
                            ),
                        onDinnerChanged: (value) => ref
                            .read(mealRepositoryProvider)
                            .setMeal(
                              messId: messId,
                              memberId: member.id,
                              date: date,
                              dinner: value,
                            ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.couldntLoadMembers)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthlyTotals(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final result = ref.watch(
          monthCalculationProvider((messId: messId, year: date.year, month: date.month)),
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.monthlyMealCountsTitle(
                    formatMonthYear(sheetContext, date.year, date.month),
                  ),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                if (result.memberBalances.isEmpty) Text(l10n.noMembersYetInline),
                for (final balance in result.memberBalances)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(balance.memberName),
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
      },
    );
  }
}

class _DateBar extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  const _DateBar({
    required this.date,
    required this.isToday,
    required this.onToday,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousDayTooltip,
          ),
          Expanded(
            child: InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  children: [
                    Text(
                      isToday ? l10n.todayLabel : formatWeekday(context, date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      formatFullDate(context, date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextDayTooltip,
          ),
          if (!isToday) TextButton(onPressed: onToday, child: Text(l10n.todayLabel)),
        ],
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
