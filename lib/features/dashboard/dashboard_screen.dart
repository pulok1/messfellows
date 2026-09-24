import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/money.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/mess.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../members/add_edit_member_dialog.dart';
import '../members/member_detail_screen.dart';
import '../members/members_screen.dart';
import '../rules/rules_summary_card.dart';
import '../settings/settings_screen.dart';
import '../shared/widgets/count_up_text.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/stat_tile.dart';
import 'widgets/dashboard_header_card.dart';
import 'widgets/settlement_tile.dart';

/// The Home tab (section 11): always shows the current, still-open month —
/// meal rate, totals, and each member's live balance. Month navigation and
/// history live on the Report tab instead.
class DashboardScreen extends ConsumerWidget {
  final Mess mess;

  const DashboardScreen({super.key, required this.mess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final membersAsync = ref.watch(activeMembersProvider(mess.id));
    final calculation = ref.watch(
      monthCalculationProvider((
        messId: mess.id,
        year: now.year,
        month: now.month,
      )),
    );

    final rateStyle = Theme.of(context).textTheme.headlineMedium
        ?.copyWith(fontWeight: FontWeight.bold);

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
                      title: l10n.noMembersYetTitle,
                      message: l10n.addMembersToTrackMealsAndBazar,
                      actionLabel: l10n.addMember,
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
                                l10n.currentMealRate,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              if (calculation.hasNoMeals)
                                Text(l10n.noMealsRecordedYet, style: rateStyle)
                              else
                                CountUpText(
                                  value: calculation.mealRate.major,
                                  format: (v) =>
                                      '${mess.currencySymbol}${v.toStringAsFixed(2)}',
                                  style: rateStyle,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile.animated(
                              label: l10n.totalBazar,
                              count: calculation.totalExpense.minorUnits,
                              // Counts in whole taka, landing on the exact total.
                              format: (v) =>
                                  v == calculation.totalExpense.minorUnits
                                  ? calculation.totalExpense.format()
                                  : Money((v / 100).round() * 100).format(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: StatTile.animated(
                              label: l10n.totalMeals,
                              count: calculation.totalMeals,
                              format: (v) => '${v.round()}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      RulesSummaryCard(messId: mess.id),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(l10n.settlementLabel),
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
                error: (_, _) => Center(child: Text(l10n.couldntLoadMessData)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
