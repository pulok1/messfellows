import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/expense.dart';
import '../../models/member.dart';
import '../../models/payment.dart';
import '../../providers/expense_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/payment_providers.dart';
import '../../providers/selection_providers.dart';
import '../payments/add_edit_payment_screen.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';
import 'add_edit_expense_screen.dart';
import 'widgets/month_selector_bar.dart';

/// The Bazar tab (section 16): expense history for the selected month,
/// with a Payments sub-tab (section 17) since both are money-in/money-out
/// records for the same month and belong together in the entry flow.
class BazarScreen extends ConsumerStatefulWidget {
  final String messId;

  const BazarScreen({super.key, required this.messId});

  @override
  ConsumerState<BazarScreen> createState() => _BazarScreenState();
}

class _BazarScreenState extends ConsumerState<BazarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _filterMemberId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final membersAsync = ref.watch(activeMembersProvider(widget.messId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(
              title: 'Bazar',
              showBackButton: false,
              actions: [
                HeaderIconButton(
                  icon: Icons.add,
                  tooltip: 'Add',
                  onPressed: () =>
                      _tabController.index == 0 ? _addExpense() : _addPayment(),
                ),
              ],
              bottom: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Bazar'),
                      Tab(text: 'Payments'),
                    ],
                  ),
                  MonthSelectorBar(
                    year: selectedMonth.year,
                    month: selectedMonth.month,
                    onPrevious: () => ref
                        .read(selectedMonthProvider.notifier)
                        .goToPreviousMonth(),
                    onNext: () => ref
                        .read(selectedMonthProvider.notifier)
                        .goToNextMonth(),
                  ),
                ],
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ExpenseList(
                    messId: widget.messId,
                    year: selectedMonth.year,
                    month: selectedMonth.month,
                    filterMemberId: _filterMemberId,
                  ),
                  _PaymentList(
                    messId: widget.messId,
                    year: selectedMonth.year,
                    month: selectedMonth.month,
                    filterMemberId: _filterMemberId,
                  ),
                ],
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

  Future<void> _addPayment() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditPaymentScreen(messId: widget.messId),
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
              label: const Text('All'),
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
          return const EmptyState(
            icon: Icons.shopping_basket_outlined,
            title: 'No bazar entries',
            message:
                'Add a bazar entry to start tracking food expenses this month.',
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
      error: (_, _) =>
          const Center(child: Text("Couldn't load bazar entries.")),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  final String messId;
  final Expense expense;

  const _ExpenseTile({required this.messId, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          '${_formatDate(expense.date)} · ${payer?.name ?? "Unknown"}'
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

class _PaymentList extends ConsumerWidget {
  final String messId;
  final int year;
  final int month;
  final String? filterMemberId;

  const _PaymentList({
    required this.messId,
    required this.year,
    required this.month,
    required this.filterMemberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(
      paymentsForMonthProvider((messId: messId, year: year, month: month)),
    );

    return paymentsAsync.when(
      data: (payments) {
        final filtered = filterMemberId == null
            ? payments
            : payments.where((p) => p.memberId == filterMemberId).toList();

        if (filtered.isEmpty) {
          return const EmptyState(
            icon: Icons.payments_outlined,
            title: 'No payments',
            message:
                'Record a payment when a member contributes money to the mess.',
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
              _PaymentTile(messId: messId, payment: filtered[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text("Couldn't load payments.")),
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  final String messId;
  final Payment payment;

  const _PaymentTile({required this.messId, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(allMembersProvider(messId)).value ?? const [];
    final member = members.firstWhereOrNull((m) => m.id == payment.memberId);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AddEditPaymentScreen(messId: messId, existing: payment),
          ),
        ),
        title: Text(
          member?.name ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatDate(payment.date)}'
          '${payment.note == null || payment.note!.isEmpty ? "" : " · ${payment.note}"}',
        ),
        trailing: Text(
          payment.amount.format(),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
