import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/insight.dart';
import '../../models/mess.dart';
import '../../providers/insight_providers.dart';
import '../../providers/member_providers.dart';
import '../../providers/month_calculation_provider.dart';
import '../members/add_edit_member_dialog.dart';
import '../members/member_detail_screen.dart';
import '../members/members_screen.dart';
import '../rules/rules_summary_card.dart';
import '../settings/settings_screen.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/staggered_entrance.dart';
import 'widgets/dashboard_header_card.dart';
import 'widgets/insights_card.dart';
import 'widgets/month_overview_card.dart';
import 'widgets/settlement_tile.dart';

/// The Home tab (section 11): always shows the current, still-open month —
/// meal rate, totals, and each member's live balance. Month navigation and
/// history live on the Report tab instead.
class DashboardScreen extends ConsumerWidget {
  final Mess mess;

  /// Switches to the Meals tab (from the "meals not marked" insight).
  final VoidCallback? onOpenMeals;

  const DashboardScreen({super.key, required this.mess, this.onOpenMeals});

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
    // Shares the same cached computation InsightsCard reads below — Riverpod
    // keys on the params, so watching it here doesn't recompute anything.
    final insights = ref.watch(
      dashboardInsightsProvider((
        messId: mess.id,
        hour: DateTime(now.year, now.month, now.day, now.hour),
      )),
    );
    final rateChange = insights.whereType<MealRateChange>().firstOrNull;

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
                      MonthOverviewCard(
                        calculation: calculation,
                        currencySymbol: mess.currencySymbol,
                        rateChangePercent: rateChange?.percent,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InsightsCard(
                        messId: mess.id,
                        currencySymbol: mess.currencySymbol,
                        onOpenMeals: onOpenMeals,
                      ),
                      RulesSummaryCard(messId: mess.id),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(child: SectionHeader(l10n.settlementLabel)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${calculation.memberBalances.length}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final (i, balance)
                          in calculation.memberBalances.indexed)
                        StaggeredEntrance(
                          key: ValueKey(balance.memberId),
                          index: i,
                          child: SettlementTile(
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
