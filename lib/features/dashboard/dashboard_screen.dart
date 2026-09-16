import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/mess.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../members/add_edit_member_dialog.dart';
import '../members/member_detail_screen.dart';
import '../members/members_screen.dart';
import '../settings/settings_screen.dart';
import '../shared/widgets/empty_state.dart';
import 'widgets/dashboard_header_card.dart';
import 'widgets/settlement_tile.dart';
import 'widgets/stat_tile.dart';

/// The Home tab (section 11): always shows the current, still-open month —
/// meal rate, totals, and each member's live balance. Month navigation and
/// history live on the Report tab instead.
class DashboardScreen extends ConsumerWidget {
  final Mess mess;

  const DashboardScreen({super.key, required this.mess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final membersAsync = ref.watch(activeMembersProvider(mess.id));
    final calculation = ref.watch(
      monthCalculationProvider((
        messId: mess.id,
        year: now.year,
        month: now.month,
      )),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DashboardHeaderCard(
              mess: mess,
              month: now,
              onMembers: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MembersScreen(messId: mess.id),
                ),
              ),
              onSettings: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SettingsScreen(mess: mess)),
              ),
            ),
            Expanded(
              child: membersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return EmptyState(
                      icon: Icons.group_outlined,
                      title: 'No members yet',
                      message: 'Add the people in your mess to start tracking meals and bazar.',
                      actionLabel: 'Add Member',
                      onAction: () =>
                          showAddEditMemberDialog(context, messId: mess.id),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xxl,
                    ),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Meal Rate',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                calculation.hasNoMeals
                                    ? 'No meals recorded yet'
                                    : '${mess.currencySymbol}${calculation.mealRate.major.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
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
                              label: 'Total Bazar',
                              value: calculation.totalExpense.format(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: StatTile(
                              label: 'Total Meals',
                              value: '${calculation.totalMeals}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Settlement',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final balance in calculation.memberBalances)
                        SettlementTile(
                          balance: balance,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MemberDetailScreen(
                                messId: mess.id,
                                memberId: balance.memberId,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) =>
                    const Center(child: Text("Couldn't load your mess data.")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
