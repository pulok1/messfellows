import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../core/utils/money.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/expense.dart';
import '../../models/member.dart';
import '../../providers/expense_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/selection_providers.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/expandable_text.dart';
import '../shared/widgets/page_header_card.dart';
import 'add_edit_expense_dialog.dart';
import 'widgets/month_selector_bar.dart';

/// The Bazar tab (section 16): expense history for the selected month.
/// Payments are recorded elsewhere (Quick Add, a member's detail page) —
/// this screen is bazar-only.
class BazarScreen extends ConsumerStatefulWidget {
  final String messId;

  const BazarScreen({super.key, required this.messId});

  @override
  ConsumerState<BazarScreen> createState() => _BazarScreenState();
}

class _BazarScreenState extends ConsumerState<BazarScreen> {
  String? _filterMemberId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final membersAsync = ref.watch(activeMembersProvider(widget.messId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: l10n.navBazar,
              showBackButton: false,
              actions: [
                HeaderIconButton(
                  icon: Icons.add,
                  tooltip: l10n.addTooltip,
                  onPressed: _addExpense,
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
            membersAsync.maybeWhen(
              data: (members) => members.length > 1
                  ? _MemberFilterRow(
                      members: members,
                      selectedId: _filterMemberId,
                      onChanged: (id) => setState(() => _filterMemberId = id),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            _MemberTotalsRow(
              messId: widget.messId,
              year: selectedMonth.year,
              month: selectedMonth.month,
            ),
            const Divider(height: 1),
            Expanded(
              child: _ExpenseList(
                messId: widget.messId,
                year: selectedMonth.year,
                month: selectedMonth.month,
                filterMemberId: _filterMemberId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExpense() async {
    await showAddEditExpenseDialog(context, messId: widget.messId);
  }
}

class _MemberFilterRow extends StatelessWidget {
  final List<Member> members;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _MemberFilterRow({
    required this.members,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(AppLocalizations.of(context).allChip),
              selected: selectedId == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final member in members)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(member.name),
                selected: selectedId == member.id,
                onSelected: (_) => onChanged(member.id),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows each member's total bazar spend for the selected month — so the
/// manager can see who's been buying groceries without opening the
/// monthly report, which only shows this alongside every other figure.
class _MemberTotalsRow extends ConsumerWidget {
  final String messId;
  final int year;
  final int month;

  const _MemberTotalsRow({
    required this.messId,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(
      expensesForMonthProvider((messId: messId, year: year, month: month)),
    );
    final allMembers = ref.watch(allMembersProvider(messId)).value ?? const [];

    return expensesAsync.maybeWhen(
      data: (expenses) {
        if (expenses.isEmpty) return const SizedBox.shrink();

        final totalsByMember = <String, Money>{};
        for (final expense in expenses) {
          totalsByMember.update(
            expense.paidByMemberId,
            (total) => total + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }

        // Everyone who's active, plus any archived member who still has a
        // total this month (see monthCalculationProvider for the same
        // reasoning: don't drop a leaver's historical contribution).
        final relevantMembers =
            allMembers
                .where((m) => m.isActive || totalsByMember.containsKey(m.id))
                .toList()
              ..sort((a, b) {
                final totalA = totalsByMember[a.id] ?? const Money.zero();
                final totalB = totalsByMember[b.id] ?? const Money.zero();
                final byTotal = totalB.compareTo(totalA);
                return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
              });

        if (relevantMembers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Text(
                AppLocalizations.of(context).perMemberLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              height: 68,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                children: [
                  for (final member in relevantMembers)
                    Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.chipRadius,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  height: 1.2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            (totalsByMember[member.id] ?? const Money.zero())
                                .format(),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  final String messId;
  final int year;
  final int month;
  final String? filterMemberId;

  const _ExpenseList({
    required this.messId,
    required this.year,
    required this.month,
    required this.filterMemberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expensesAsync = ref.watch(
      expensesForMonthProvider((messId: messId, year: year, month: month)),
    );

    return expensesAsync.when(
      data: (expenses) {
        final filtered = filterMemberId == null
            ? expenses
            : expenses
                  .where((e) => e.paidByMemberId == filterMemberId)
                  .toList();

        if (filtered.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_basket_outlined,
            title: l10n.noBazarEntriesTitle,
            message: l10n.noBazarEntriesMessage,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _ExpenseTile(messId: messId, expense: filtered[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.couldntLoadBazarEntries)),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  final String messId;
  final Expense expense;

  const _ExpenseTile({required this.messId, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = ref.watch(allMembersProvider(messId)).value ?? const [];
    final payer = members.firstWhereOrNull(
      (m) => m.id == expense.paidByMemberId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: () => showAddEditExpenseDialog(
          context,
          messId: messId,
          existing: expense,
        ),
        title: ExpandableText(
          expense.bazarList,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${formatShortDate(context, expense.date)} · ${payer?.name ?? l10n.unknown}'
          '${expense.note == null || expense.note!.isEmpty ? "" : " · ${expense.note}"}',
        ),
        isThreeLine: false,
        trailing: Text(
          expense.amount.format(),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
