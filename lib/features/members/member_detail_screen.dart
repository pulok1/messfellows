import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../providers/expense_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../../providers/payment_providers.dart';
import '../payments/add_edit_payment_screen.dart';
import '../shared/widgets/balance_label.dart';
import '../shared/widgets/page_header_card.dart';

/// A member's detail view (section 19's "View details"): this month's
/// meals/cost/balance plus their full bazar and payment history.
class MemberDetailScreen extends ConsumerWidget {
  final String messId;
  final String memberId;

  const MemberDetailScreen({
    super.key,
    required this.messId,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider(messId));
    final member = membersAsync.value
        ?.where((m) => m.id == memberId)
        .firstOrNull;
    final now = DateTime.now();
    final calculation = ref.watch(
      monthCalculationProvider((
        messId: messId,
        year: now.year,
        month: now.month,
      )),
    );
    final balance = calculation.memberBalances
        .where((b) => b.memberId == memberId)
        .firstOrNull;
    final expenses = ref.watch(
      expensesForMemberProvider((messId: messId, memberId: memberId)),
    );
    final payments = ref.watch(
      paymentsForMemberProvider((messId: messId, memberId: memberId)),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AddEditPaymentScreen(messId: messId, initialMemberId: memberId),
          ),
        ),
        icon: const Icon(Icons.payments_outlined),
        label: const Text('Add Payment'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: member?.name ?? 'Member'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  if (balance != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This month',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _StatRow(
                              label: 'Meals eaten',
                              value: '${balance.mealCount}',
                            ),
                            _StatRow(
                              label: 'Meal cost',
                              value: balance.mealCost.format(),
                            ),
                            _StatRow(
                              label: 'Paid',
                              value: balance.paidAmount.format(),
                            ),
                            const Divider(height: AppSpacing.lg),
                            BalanceLabel(
                              balance: balance,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Bazar history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  expenses.when(
                    data: (list) => list.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text('No bazar entries yet.'),
                          )
                        : Column(
                            children: [
                              for (final expense in list)
                                Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: ListTile(
                                    title: Text(expense.category),
                                    subtitle: Text(_formatDate(expense.date)),
                                    trailing: Text(
                                      expense.amount.format(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const Text("Couldn't load bazar history."),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Payment history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  payments.when(
                    data: (list) => list.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text('No payments yet.'),
                          )
                        : Column(
                            children: [
                              for (final payment in list)
                                Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: ListTile(
                                    title: Text(payment.amount.format()),
                                    subtitle: Text(_formatDate(payment.date)),
                                    trailing: payment.note == null
                                        ? null
                                        : Text(payment.note!),
                                  ),
                                ),
                            ],
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text("Couldn't load payment history."),
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

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
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
