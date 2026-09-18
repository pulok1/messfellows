import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/expense_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../../providers/payment_providers.dart';
import '../payments/add_edit_payment_screen.dart';
import '../shared/widgets/balance_label.dart';
import '../shared/widgets/labeled_value_row.dart';
import '../shared/widgets/page_header_card.dart';
import '../shared/widgets/section_header.dart';

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
    final l10n = AppLocalizations.of(context);
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
        label: Text(l10n.addPaymentTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: member?.name ?? l10n.memberFallback),
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
                              l10n.thisMonthLabel,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            LabeledValueRow(
                              label: l10n.mealsEatenLabel,
                              value: '${balance.mealCount}',
                            ),
                            LabeledValueRow(
                              label: l10n.mealCostLabel,
                              value: balance.mealCost.format(),
                            ),
                            LabeledValueRow(
                              label: l10n.paidLabel,
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
                  SectionHeader(l10n.bazarHistoryLabel),
                  const SizedBox(height: AppSpacing.sm),
                  expenses.when(
                    data: (list) => list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(l10n.noBazarEntriesYet),
                          )
                        : Column(
                            children: [
                              for (final expense in list)
                                Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      expense.bazarList,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formatShortDate(context, expense.date),
                                    ),
                                    trailing: Text(
                                      expense.amount.format(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => Text(l10n.couldntLoadBazarHistory),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(l10n.paymentHistoryLabel),
                  const SizedBox(height: AppSpacing.sm),
                  payments.when(
                    data: (list) => list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(l10n.noPaymentsYet),
                          )
                        : Column(
                            children: [
                              for (final payment in list)
                                Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      payment.amount.format(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formatShortDate(context, payment.date),
                                    ),
                                    trailing: payment.note == null
                                        ? null
                                        : Text(payment.note!),
                                  ),
                                ),
                            ],
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => Text(l10n.couldntLoadPaymentHistory),
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
