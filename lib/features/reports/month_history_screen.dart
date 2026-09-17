import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/mess.dart';
import '../../providers/selection_providers.dart';
import '../../providers/settlement_providers.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/page_header_card.dart';

/// Lists every closed month (section 22), newest first. Tapping one jumps
/// the Report tab to that month.
class MonthHistoryScreen extends ConsumerWidget {
  final Mess mess;

  const MonthHistoryScreen({super.key, required this.mess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settlementsAsync = ref.watch(settlementsProvider(mess.id));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderCard(title: l10n.monthHistoryTitle),
            Expanded(
              child: settlementsAsync.when(
                data: (settlements) {
                  if (settlements.isEmpty) {
                    return EmptyState(
                      icon: Icons.history,
                      title: l10n.noClosedMonthsTitle,
                      message: l10n.noClosedMonthsMessage,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: settlements.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final settlement = settlements[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            formatMonthYear(context, settlement.year, settlement.month),
                          ),
                          subtitle: Text(
                            l10n.monthHistorySubtitle(
                              settlement.totalMeals,
                              settlement.totalExpense.format(),
                              settlement.mealRate.format(),
                            ),
                          ),
                          trailing: Chip(
                            label: Text(
                              settlement.isClosed ? l10n.closedLabel : l10n.openLabel,
                            ),
                            avatar: Icon(
                              settlement.isClosed
                                  ? Icons.lock_outline
                                  : Icons.lock_open,
                              size: 16,
                            ),
                          ),
                          onTap: () {
                            ref
                                .read(selectedMonthProvider.notifier)
                                .goTo(settlement.year, settlement.month);
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.couldntLoadMonthHistory)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
