import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/meal_entry.dart';
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

  /// Marks everyone who hasn't eaten yet in [countOf]'s slot (leaving
  /// anyone already at 1+, including a guest-meal count, untouched) —
  /// or, if everyone's already marked, clears the whole slot back to 0.
  /// Runs every write in parallel; a household mess is small enough that
  /// this is instant either way.
  Future<void> _toggleAllForSlot(
    BuildContext context,
    WidgetRef ref, {
    required List<Member> members,
    required Map<String, MealEntry> mealsByMember,
    required DateTime date,
    required int Function(MealEntry?) countOf,
    required Future<void> Function(String memberId, int value) setValue,
  }) async {
    final allMarked =
        members.isNotEmpty &&
        members.every((m) => countOf(mealsByMember[m.id]) > 0);
    await _save(
      context,
      () => Future.wait([
        for (final member in members)
          if (allMarked || countOf(mealsByMember[member.id]) == 0)
            setValue(member.id, allMarked ? 0 : 1),
      ]),
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
    required List<MealEntry> previousMeals,
  }) async {
    final members =
        ref.read(activeMembersProvider(messId)).value ?? const <Member>[];
    final previousByMember = {for (final m in previousMeals) m.memberId: m};
    final repo = ref.read(mealRepositoryProvider);

    final saved = await _save(
      context,
      () => Future.wait([
        for (final member in members)
          if (previousByMember[member.id] case final prev?
              when prev.totalMeals > 0)
            repo.setMeal(
              messId: messId,
              memberId: member.id,
              date: date,
              breakfast: mess.trackBreakfast ? prev.breakfast : null,
              lunch: mess.trackLunch ? prev.lunch : null,
              dinner: mess.trackDinner ? prev.dinner : null,
            ),
      ]),
    );

    if (saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).copiedPreviousDaySnackbar),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final date = ref.watch(selectedMealDateProvider);
    final membersAsync = ref.watch(activeMembersProvider(messId));
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
                        onToggleBreakfast: () => _toggleAllForSlot(
                          context,
                          ref,
                          members: members,
                          mealsByMember: mealsByMember,
                          date: date,
                          countOf: (m) => m?.breakfast ?? 0,
                          setValue: (memberId, value) => ref
                              .read(mealRepositoryProvider)
                              .setMeal(
                                messId: messId,
                                memberId: memberId,
                                date: date,
                                breakfast: value,
                              ),
                        ),
                        onToggleLunch: () => _toggleAllForSlot(
                          context,
                          ref,
                          members: members,
                          mealsByMember: mealsByMember,
                          date: date,
                          countOf: (m) => m?.lunch ?? 0,
                          setValue: (memberId, value) => ref
                              .read(mealRepositoryProvider)
                              .setMeal(
                                messId: messId,
                                memberId: memberId,
                                date: date,
                                lunch: value,
                              ),
                        ),
                        onToggleDinner: () => _toggleAllForSlot(
                          context,
                          ref,
                          members: members,
                          mealsByMember: mealsByMember,
                          date: date,
                          countOf: (m) => m?.dinner ?? 0,
                          setValue: (memberId, value) => ref
                              .read(mealRepositoryProvider)
                              .setMeal(
                                messId: messId,
                                memberId: memberId,
                                date: date,
                                dinner: value,
                              ),
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
                          itemCount: members.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
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
