import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/expense.dart';
import '../../models/member.dart';
import '../../providers/expense_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/selection_providers.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';
import 'add_edit_expense_screen.dart';
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(messId: widget.messId),
      ),
    );
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AddEditExpenseScreen(messId: messId, existing: expense),
          ),
        ),
        title: Text(
          expense.category,
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
