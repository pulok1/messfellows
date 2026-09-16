import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
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
    final settlementsAsync = ref.watch(settlementsProvider(mess.id));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeaderCard(title: 'Month History'),
            Expanded(
              child: settlementsAsync.when(
                data: (settlements) {
                  if (settlements.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history,
                      title: 'No closed months yet',
                      message: 'Closed months will show up here once you close your first month.',
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
                            _monthYear(settlement.year, settlement.month),
                          ),
                          subtitle: Text(
                            '${settlement.totalMeals} meals · ${settlement.totalExpense.format()} · '
                            'Rate ${settlement.mealRate.format()}',
                          ),
                          trailing: Chip(
                            label: Text(
                              settlement.isClosed ? 'Closed' : 'Open',
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
                error: (_, _) =>
                    const Center(child: Text("Couldn't load month history.")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _monthYear(int year, int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[month - 1]} $year';
}
