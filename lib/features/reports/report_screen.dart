import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_spacing.dart';
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
    final selectedMonth = ref.watch(selectedMonthProvider);
    final settlement = ref.watch(
      settlementForMonthProvider((messId: mess.id, year: selectedMonth.year, month: selectedMonth.month)),
    );
    final isClosed = settlement?.isClosed ?? false;

    final liveResult = ref.watch(
      monthCalculationProvider((messId: mess.id, year: selectedMonth.year, month: selectedMonth.month)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
            tooltip: 'Month history',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => MonthHistoryScreen(mess: mess))),
          ),
        ],
      ),
      body: Column(
        children: [
          MonthSelectorBar(
            year: selectedMonth.year,
            month: selectedMonth.month,
            onPrevious: () => ref.read(selectedMonthProvider.notifier).goToPreviousMonth(),
            onNext: () => ref.read(selectedMonthProvider.notifier).goToNextMonth(),
          ),
          if (isClosed) const _ClosedBanner(),
          const Divider(height: 1),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'This month is closed. Numbers are frozen from when it was closed.',
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review ${_monthName(month)} $year'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewRow(label: 'Total meals', value: '${result.totalMeals}'),
            _ReviewRow(label: 'Food cost', value: result.totalExpense.format()),
            _ReviewRow(
              label: 'Meal rate',
              value: result.hasNoMeals ? 'N/A' : result.mealRate.format(),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'This freezes the settlement for this month. You can reopen it later if you need '
              'to make changes.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close Month'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_monthName(month)} $year closed.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ReportContent(
      mess: mess,
      year: year,
      month: month,
      result: result,
      footer: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FilledButton.icon(
          onPressed: result.memberBalances.isEmpty ? null : () => _closeMonth(context, ref),
          icon: const Icon(Icons.lock_outline),
          label: Text(hasExistingSettlement ? 'Re-close Month' : 'Close Month'),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reopen this month?'),
        content: const Text(
          'You can edit meals, bazar and payments again. Close the month once more when '
          "you're done to refresh the settlement.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settlementRepositoryProvider).reopenMonth(settlement.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementMembersAsync = ref.watch(settlementMembersProvider(settlement.id));
    final allMembers = ref.watch(allMembersProvider(mess.id)).value ?? const [];

    return settlementMembersAsync.when(
      data: (rows) {
        final balances = rows
            .map(
              (row) => MemberBalance(
                memberId: row.memberId,
                memberName:
                    allMembers.firstWhereOrNull((m) => m.id == row.memberId)?.name ?? 'Unknown',
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
              label: const Text('Reopen Month'),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text("Couldn't load this month's settlement.")),
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
    final text = buildMonthlySummary(messName: mess.name, year: year, month: month, result: result);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Summary copied to clipboard.')));
  }

  void _shareSummary(BuildContext context) {
    final text = buildMonthlySummary(messName: mess.name, year: year, month: month, result: result);
    SharePlus.instance.share(ShareParams(text: text, subject: '${mess.name} — ${_monthName(month)} $year'));
  }

  @override
  Widget build(BuildContext context) {
    if (result.memberBalances.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No members yet — add members to see a report for this month.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatLine(label: 'Total Food Cost', value: result.totalExpense.format()),
                      _StatLine(label: 'Total Meals', value: '${result.totalMeals}'),
                      _StatLine(
                        label: 'Meal Rate',
                        value: result.hasNoMeals ? 'No meals recorded yet' : result.mealRate.format(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copySummary(context),
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy Summary'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareSummary(context),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Per Member', style: Theme.of(context).textTheme.titleMedium),
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
                        Text('${balance.mealCount} meals'),
                        Text('Meal Cost: ${balance.mealCost.format()}'),
                        Text('Paid: ${balance.paidAmount.format()}'),
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

class _StatLine extends StatelessWidget {
  final String label;
  final String value;

  const _StatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

String _monthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return months[month - 1];
}
