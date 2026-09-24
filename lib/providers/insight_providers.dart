import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/insight_engine.dart';
import '../models/insight.dart';
import 'expense_providers.dart';
import 'meal_providers.dart';
import 'member_providers.dart';
import 'month_calculation_provider.dart';

final insightEngineProvider = Provider<InsightEngine>((ref) {
  return const InsightEngine();
});

/// Dashboard insights for the month containing [hour]. Callers pass the
/// current time truncated to the hour, so time-based insights ("today's
/// meals aren't marked yet") refresh hourly without recomputing on every
/// rebuild.
final dashboardInsightsProvider =
    Provider.family<List<Insight>, ({String messId, DateTime hour})>((
      ref,
      params,
    ) {
      final now = params.hour;
      final month = (messId: params.messId, year: now.year, month: now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      final members =
          ref.watch(activeMembersProvider(params.messId)).value ?? const [];
      final meals = ref.watch(mealsForMonthProvider(month)).value ?? const [];
      final expenses =
          ref.watch(expensesForMonthProvider(month)).value ?? const [];

      return ref
          .watch(insightEngineProvider)
          .build(
            now: now,
            current: ref.watch(monthCalculationProvider(month)),
            previous: ref.watch(
              monthCalculationProvider((
                messId: params.messId,
                year: lastMonth.year,
                month: lastMonth.month,
              )),
            ),
            meals: meals,
            expenses: expenses,
            activeMembers: members,
          );
    });
