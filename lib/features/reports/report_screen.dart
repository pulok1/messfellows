import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/member_balance.dart';
import '../../models/mess.dart';
import '../../models/month_calculation_result.dart';
import '../../models/settlement.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/selection_providers.dart';
import '../../providers/settlement_providers.dart';
import '../bazar/widgets/month_selector_bar.dart';
import '../shared/widgets/balance_label.dart';
import '../shared/widgets/labeled_value_row.dart';
import '../shared/widgets/page_header_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/stat_tile.dart';
import 'month_history_screen.dart';
import 'summary_text.dart';

/// The Report tab (sections 20/21/22/23): the monthly settlement, live
/// while the month is open and frozen once closed, plus copy/share and
/// month-closing actions.
class ReportScreen extends ConsumerWidget {
  final Mess mess;

  const ReportScreen({super.key, required this.mess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final settlement = ref.watch(
      settlementForMonthProvider((
        messId: mess.id,
        year: selectedMonth.year,
        month: selectedMonth.month,
      )),
    );
    final isClosed = settlement?.isClosed ?? false;

    final liveResult = ref.watch(
      monthCalculationProvider((
        messId: mess.id,
        year: selectedMonth.year,
        month: selectedMonth.month,
      )),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: l10n.navReport,
              showBackButton: false,
              actions: [
                HeaderIconButton(
                  icon: Icons.history,
                  tooltip: l10n.monthHistoryTooltip,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MonthHistoryScreen(mess: mess),
                    ),
                  ),
                ),
              ],
              bottom: MonthSelectorBar(
                year: selectedMonth.year,
                month: selectedMonth.month,
                onPrevious: () => ref
                    .read(selectedMonthProvider.notifier)
                    .goToPreviousMonth(),
                onNext: () =>
                    ref.read(selectedMonthProvider.notifier).goToNextMonth(),
              ),
            ),
            if (isClosed) const _ClosedBanner(),
            Expanded(
              child: isClosed
                  ? _FrozenReportBody(mess: mess, settlement: settlement!)
                  : _LiveReportBody(
                      mess: mess,
                      year: selectedMonth.year,
                      month: selectedMonth.month,
                      result: liveResult,
                      hasExistingSettlement: settlement != null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 18,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            AppLocalizations.of(context).monthClosedBanner,
            style: TextStyle(color: colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

/// Renders a still-open month using live figures, with a Close Month action.
class _LiveReportBody extends ConsumerWidget {
  final Mess mess;
  final int year;
  final int month;
  final MonthCalculationResult result;
  final bool hasExistingSettlement;

  const _LiveReportBody({
    required this.mess,
    required this.year,
    required this.month,
    required this.result,
    required this.hasExistingSettlement,
  });

  Future<void> _closeMonth(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final monthYear = formatMonthYear(context, year, month);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reviewMonthTitle(monthYear)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledValueRow(
              label: l10n.totalMealsLowerLabel,
              value: '${result.totalMeals}',
              mutedLabel: false,
            ),
            LabeledValueRow(
              label: l10n.foodCostLabel,
              value: result.totalExpense.format(),
              mutedLabel: false,
            ),
            LabeledValueRow(
              label: l10n.mealRateLowerLabel,
              value: result.hasNoMeals ? l10n.notApplicable : result.mealRate.format(),
              mutedLabel: false,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.closeMonthExplain),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.closeMonthButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(settlementRepositoryProvider)
        .closeMonth(
          messId: mess.id,
          year: year,
          month: month,
          totalExpense: result.totalExpense,
          totalMeals: result.totalMeals,
          mealRate: result.mealRate,
          balances: result.memberBalances,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.monthClosedSnackbar(monthYear))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _ReportContent(
      mess: mess,
      year: year,
      month: month,
      result: result,
      footer: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FilledButton.icon(
          onPressed: result.memberBalances.isEmpty
              ? null
              : () => _closeMonth(context, ref),
          icon: const Icon(Icons.lock_outline),
          label: Text(hasExistingSettlement ? l10n.recloseMonthButton : l10n.closeMonthButton),
        ),
      ),
    );
  }
}


/// Renders a closed month from its frozen settlement rows, with a Reopen
/// action.
class _FrozenReportBody extends ConsumerWidget {
  final Mess mess;
  final MonthlySettlement settlement;

  const _FrozenReportBody({required this.mess, required this.settlement});

  Future<void> _reopenMonth(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reopenMonthConfirmTitle),
        content: Text(l10n.reopenMonthConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.reopenButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settlementRepositoryProvider).reopenMonth(settlement.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settlementMembersAsync = ref.watch(
      settlementMembersProvider(settlement.id),
    );
    final allMembers = ref.watch(allMembersProvider(mess.id)).value ?? const [];

    return settlementMembersAsync.when(
      data: (rows) {
        final balances = rows
            .map(
              (row) => MemberBalance(
                memberId: row.memberId,
                memberName:
                    allMembers
                        .firstWhereOrNull((m) => m.id == row.memberId)
                        ?.name ??
                    l10n.unknown,
                mealCount: row.mealCount,
                mealCost: row.mealCost,
                paidAmount: row.paidAmount,
                balance: row.balance,
              ),
            )
            .sortedBy((b) => b.memberName);

        final result = MonthCalculationResult(
          totalExpense: settlement.totalExpense,
          totalMeals: settlement.totalMeals,
          mealRate: settlement.mealRate,
          memberBalances: balances,
        );

        return _ReportContent(
          mess: mess,
          year: settlement.year,
          month: settlement.month,
          result: result,
          footer: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: OutlinedButton.icon(
              onPressed: () => _reopenMonth(context, ref),
              icon: const Icon(Icons.lock_open),
              label: Text(l10n.reopenMonthButton),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.couldntLoadSettlement)),
    );
  }
}

/// Shared rendering for both the live and frozen cases: totals, per-member
/// balances, and copy/share actions.
class _ReportContent extends StatelessWidget {
  final Mess mess;
  final int year;
  final int month;
  final MonthCalculationResult result;
  final Widget footer;

  const _ReportContent({
    required this.mess,
    required this.year,
    required this.month,
    required this.result,
    required this.footer,
  });

  void _copySummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = buildMonthlySummary(
      context: context,
      messName: mess.name,
      year: year,
      month: month,
      result: result,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.summaryCopiedSnackbar)),
    );
  }

  void _shareSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = buildMonthlySummary(
      context: context,
      messName: mess.name,
      year: year,
      month: month,
      result: result,
    );
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: l10n.shareSubject(mess.name, formatMonthYear(context, year, month)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (result.memberBalances.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            l10n.noMembersReportMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mealRateUpperLabel,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        result.hasNoMeals
                            ? l10n.noMealsRecordedYet
                            : result.mealRate.format(),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.totalFoodCost,
                      value: result.totalExpense.format(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatTile(
                      label: l10n.totalMeals,
                      value: '${result.totalMeals}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copySummary(context),
                      icon: const Icon(Icons.copy_outlined),
                      label: Text(l10n.copySummaryButton),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareSummary(context),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.shareButton),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(l10n.perMemberLabel),
              const SizedBox(height: AppSpacing.sm),
              for (final balance in result.memberBalances)
                Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balance.memberName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.mealsCount(balance.mealCount)),
                        Text(l10n.mealCostLine(balance.mealCost.format())),
                        Text(l10n.paidLine(balance.paidAmount.format())),
                        const SizedBox(height: AppSpacing.xs),
                        BalanceLabel(balance: balance),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        footer,
      ],
    );
  }
}

