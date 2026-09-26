import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/meal_entry.dart';
import '../../models/meal_slot.dart';
import '../../models/member.dart';
import '../../models/mess.dart';
import '../../providers/meal_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/selection_providers.dart';
import '../../providers/settlement_providers.dart';
import '../members/add_edit_member_dialog.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';
import 'widgets/meal_day_row.dart';
import 'widgets/meal_progress_row.dart';

/// The daily meal tracker (sections 14/15) — the screen a manager is
/// expected to open several times a day, so it defaults to today and
/// requires no navigation or confirmation to mark a meal off.
class MealsScreen extends ConsumerWidget {
  final Mess mess;

  const MealsScreen({super.key, required this.mess});

  String get messId => mess.id;

  /// Runs a meal write, turning a failure into a snackbar instead of
  /// letting it vanish — a tap that didn't save must never look like it
  /// did. The screen itself only ever shows what the database holds, so a
  /// rejected write simply leaves the toggle where it was.
  Future<bool> _save(
    BuildContext context,
    Future<void> Function() write,
  ) async {
    try {
      await write();
      return true;
    } catch (error) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                error is MonthClosedException
                    ? l10n.mealsLockedSnackbar
                    : l10n.couldntSaveMeal,
              ),
            ),
          );
      }
      return false;
    }
  }

  /// Writes [changes] for [date] in one atomic step, then offers an Undo
  /// that puts back exactly what those members had before — one tap here
  /// can change the whole mess's day, so it must be just as easy to take
  /// back.
  Future<void> _applyBulk(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required Map<String, MealEntry> mealsByMember,
    required Map<String, MealCounts> changes,
    required String message,
  }) async {
    if (changes.isEmpty) return;
    final repo = ref.read(mealRepositoryProvider);
    final previous = {
      for (final memberId in changes.keys)
        memberId: mealsByMember[memberId]?.counts ?? noMeals,
    };

    final saved = await _save(
      context,
      () => repo.setMealsForDate(
        messId: messId,
        date: date,
        countsByMember: changes,
      ),
    );
    if (!saved || !context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: AppLocalizations.of(context).undoAction,
            onPressed: () => _save(
              context,
              () => repo.setMealsForDate(
                messId: messId,
                date: date,
                countsByMember: previous,
              ),
            ),
          ),
        ),
      );
  }

  /// Marks [slot] for everyone who hasn't had it yet (leaving anyone
  /// already at 1+, including a guest-meal count, untouched) — or, if
  /// everyone's already marked, clears it for the whole mess.
  Future<void> _toggleAllForSlot(
    BuildContext context,
    WidgetRef ref, {
    required MealSlot slot,
    required String label,
    required List<Member> members,
    required Map<String, MealEntry> mealsByMember,
    required DateTime date,
  }) {
    int countOf(Member m) =>
        slot.countIn(mealsByMember[m.id]?.counts ?? noMeals);
    final allMarked =
        members.isNotEmpty && members.every((m) => countOf(m) > 0);
    final changes = {
      for (final member in members)
        if (allMarked || countOf(member) == 0)
          member.id: slot.setIn(
            mealsByMember[member.id]?.counts ?? noMeals,
            allMarked ? 0 : 1,
          ),
    };
    final l10n = AppLocalizations.of(context);
    return _applyBulk(
      context,
      ref,
      date: date,
      mealsByMember: mealsByMember,
      changes: changes,
      message: allMarked
          ? l10n.clearedSlotSnackbar(label)
          : l10n.markedSlotSnackbar(changes.length, label),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: latestMealDate(),
    );
    if (picked != null) {
      ref.read(selectedMealDateProvider.notifier).goTo(picked);
    }
  }

  /// Copies each member's meal counts from [previousMeals] onto [date] —
  /// only for members who actually ate something the day before, and only
  /// into slots this mess currently tracks. Only offered when [date] has
  /// no meals recorded yet (see the header action's guard), so this never
  /// overwrites a day already in progress.
  Future<void> _copyPreviousDay(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required List<Member> members,
    required Map<String, MealEntry> mealsByMember,
    required List<MealEntry> previousMeals,
  }) {
    final previousByMember = {for (final m in previousMeals) m.memberId: m};
    final changes = <String, MealCounts>{};
    for (final member in members) {
      final prev = previousByMember[member.id];
      if (prev == null || prev.totalMeals == 0) continue;
      var counts = mealsByMember[member.id]?.counts ?? noMeals;
      for (final slot in MealSlot.values) {
        if (slot.isTrackedBy(mess)) {
          counts = slot.setIn(counts, slot.countIn(prev.counts));
        }
      }
      changes[member.id] = counts;
    }
    return _applyBulk(
      context,
      ref,
      date: date,
      mealsByMember: mealsByMember,
      changes: changes,
      message: AppLocalizations.of(context).copiedPreviousDaySnackbar,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final date = ref.watch(selectedMealDateProvider);
    final membersAsync = ref.watch(activeMembersProvider(messId));
    final allMembers =
        ref.watch(allMembersProvider(messId)).value ?? const <Member>[];
    final monthMeals =
        ref
            .watch(
              mealsForMonthProvider((
                messId: messId,
                year: date.year,
                month: date.month,
              )),
            )
            .value ??
        const <MealEntry>[];
    final monthMealsByMember = <String, int>{};
    for (final meal in monthMeals) {
      monthMealsByMember.update(
        meal.memberId,
        (total) => total + meal.totalMeals,
        ifAbsent: () => meal.totalMeals,
      );
    }
    final mealsAsync = ref.watch(
      mealsForDateProvider((messId: messId, date: date)),
    );
    final previousMeals = ref
        .watch(mealsForDateProvider((messId: messId, date: addDays(date, -1))))
        .value;
    final isToday = _isSameDay(date, DateTime.now());
    // A closed month's settlement is frozen, so its meals are shown
    // read-only (the repository refuses the write anyway).
    final locked =
        ref
            .watch(
              settlementForMonthProvider((
                messId: messId,
                year: date.year,
                month: date.month,
              )),
            )
            ?.isClosed ??
        false;
    // Offered only when today has nothing recorded yet and yesterday has
    // something to copy — never as a way to overwrite a day in progress.
    final canCopyPreviousDay =
        !locked &&
        (mealsAsync.value?.every((m) => m.totalMeals == 0) ?? true) &&
        (previousMeals?.any((m) => m.totalMeals > 0) ?? false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: l10n.navMeals,
              showBackButton: false,
              actions: [
                if (canCopyPreviousDay)
                  HeaderIconButton(
                    icon: Icons.repeat,
                    tooltip: l10n.copyPreviousDayTooltip,
                    onPressed: () => _copyPreviousDay(
                      context,
                      ref,
                      date: date,
                      members: membersAsync.value ?? const [],
                      mealsByMember: {
                        for (final meal
                            in mealsAsync.value ?? const <MealEntry>[])
                          meal.memberId: meal,
                      },
                      previousMeals: previousMeals!,
                    ),
                  ),
                HeaderIconButton(
                  icon: Icons.bar_chart_outlined,
                  tooltip: l10n.monthlyTotalsTooltip,
                  onPressed: () => _showMonthlyTotals(context, ref, date),
                ),
              ],
              bottom: _DateBar(
                date: date,
                isToday: isToday,
                onToday: () =>
                    ref.read(selectedMealDateProvider.notifier).goToToday(),
                onPrevious: () => ref
                    .read(selectedMealDateProvider.notifier)
                    .goToPreviousDay(),
                onNext: date.isBefore(latestMealDate())
                    ? () => ref
                          .read(selectedMealDateProvider.notifier)
                          .goToNextDay()
                    : null,
                onPickDate: () => _pickDate(context, ref, date),
              ),
            ),
            if (locked)
              _LockedBanner(
                monthYear: formatMonthYear(context, date.year, date.month),
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
                      onAction: () =>
                          showAddEditMemberDialog(context, messId: messId),
                    );
                  }

                  final meals = mealsAsync.value ?? const <MealEntry>[];
                  final mealsByMember = {
                    for (final meal in meals) meal.memberId: meal,
                  };
                  // Someone archived since still owns the meals they ate
                  // here, and those still count toward the month — so
                  // they're listed (after everyone active) rather than
                  // silently hidden. They're left out of the progress
                  // counts and mark-all, which are about today's mess.
                  final listed = [
                    ...members,
                    ...allMembers.where(
                      (m) =>
                          !m.isActive &&
                          (mealsByMember[m.id]?.totalMeals ?? 0) > 0,
                    ),
                  ];

                  return Column(
                    children: [
                      MealProgressRow(
                        totalMembers: members.length,
                        breakfastMarked: members
                            .where(
                              (m) => (mealsByMember[m.id]?.breakfast ?? 0) > 0,
                            )
                            .length,
                        lunchMarked: members
                            .where((m) => (mealsByMember[m.id]?.lunch ?? 0) > 0)
                            .length,
                        dinnerMarked: members
                            .where(
                              (m) => (mealsByMember[m.id]?.dinner ?? 0) > 0,
                            )
                            .length,
                        showBreakfast: mess.trackBreakfast,
                        showLunch: mess.trackLunch,
                        showDinner: mess.trackDinner,
                        enabled: !locked,
                        summary: _daySummary(l10n, meals),
                        onToggleBreakfast: () => _toggleAllForSlot(
                          context,
                          ref,
                          slot: MealSlot.breakfast,
                          label: l10n.breakfastLabel,
                          members: members,
                          mealsByMember: mealsByMember,
                          date: date,
                        ),
                        onToggleLunch: () => _toggleAllForSlot(
                          context,
                          ref,
                          slot: MealSlot.lunch,
                          label: l10n.lunchLabel,
                          members: members,
                          mealsByMember: mealsByMember,
                          date: date,
                        ),
                        onToggleDinner: () => _toggleAllForSlot(
                          context,
                          ref,
                          slot: MealSlot.dinner,
                          label: l10n.dinnerLabel,
                          members: members,
                          mealsByMember: mealsByMember,
                          date: date,
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          itemCount: listed.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final member = listed[index];
                            final meal = mealsByMember[member.id];
                            return MealDayRow(
                              member: member,
                              breakfast: meal?.breakfast ?? 0,
                              lunch: meal?.lunch ?? 0,
                              dinner: meal?.dinner ?? 0,
                              monthMeals: monthMealsByMember[member.id] ?? 0,
                              showBreakfast: mess.trackBreakfast,
                              showLunch: mess.trackLunch,
                              showDinner: mess.trackDinner,
                              enabled: !locked,
                              onBreakfastChanged: (value) => _save(
                                context,
                                () => ref
                                    .read(mealRepositoryProvider)
                                    .setMeal(
                                      messId: messId,
                                      memberId: member.id,
                                      date: date,
                                      breakfast: value,
                                    ),
                              ),
                              onLunchChanged: (value) => _save(
                                context,
                                () => ref
                                    .read(mealRepositoryProvider)
                                    .setMeal(
                                      messId: messId,
                                      memberId: member.id,
                                      date: date,
                                      lunch: value,
                                    ),
                              ),
                              onDinnerChanged: (value) => _save(
                                context,
                                () => ref
                                    .read(mealRepositoryProvider)
                                    .setMeal(
                                      messId: messId,
                                      memberId: member.id,
                                      date: date,
                                      dinner: value,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

  /// "7 meals this day · 1 extra" — extras being every meal past the first
  /// in a slot, i.e. guests and second helpings.
  String _daySummary(AppLocalizations l10n, List<MealEntry> meals) {
    var total = 0;
    var extra = 0;
    for (final meal in meals) {
      total += meal.totalMeals;
      for (final count in [meal.breakfast, meal.lunch, meal.dinner]) {
        if (count > 1) extra += count - 1;
      }
    }
    final summary = l10n.dayMealTotal(total);
    return extra > 0 ? '$summary · ${l10n.dayExtraMeals(extra)}' : summary;
  }

  void _showMonthlyTotals(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final result = ref.watch(
          monthCalculationProvider((
            messId: messId,
            year: date.year,
            month: date.month,
          )),
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
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
                if (result.memberBalances.isEmpty)
                  Text(l10n.noMembersYetInline),
                for (final balance in result.memberBalances)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
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

/// Explains why a closed month's toggles don't respond, and where to go
/// to change them — so a locked day never looks like a broken screen.
class _LockedBanner extends StatelessWidget {
  final String monthYear;

  const _LockedBanner({required this.monthYear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 18,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppLocalizations.of(context).mealsLockedBanner(monthYear),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onToday;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
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
          if (!isToday)
            TextButton(onPressed: onToday, child: Text(l10n.todayLabel)),
        ],
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
