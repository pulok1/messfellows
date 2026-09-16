import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/month_calculation_result.dart';
import 'expense_providers.dart';
import 'meal_providers.dart';
import 'member_providers.dart';
import 'params.dart';
import 'payment_providers.dart';
import 'repository_providers.dart';

/// Live meal-rate/balance calculation for one month, recomputed whenever
/// any underlying meal, expense, payment or member stream emits.
///
/// Returns a plain [MonthCalculationResult] rather than an [AsyncValue] —
/// local Drift streams resolve effectively instantly, so each dependency
/// simply contributes an empty list until its first emission rather than
/// the UI showing a loading spinner (section 34 of the product spec).
final monthCalculationProvider =
    Provider.family<MonthCalculationResult, MonthParams>((ref, params) {
      final allMembers =
          ref.watch(allMembersProvider(params.messId)).value ?? const [];
      final meals =
          ref
              .watch(
                mealsForMonthProvider((
                  messId: params.messId,
                  year: params.year,
                  month: params.month,
                )),
              )
              .value ??
          const [];
      final expenses =
          ref.watch(expensesForMonthProvider(params)).value ?? const [];
      final payments =
          ref.watch(paymentsForMonthProvider(params)).value ?? const [];

      // Always include currently-active members (even with zero meals/pay so
      // far this month); include an archived member only if they actually have
      // a meal or payment record this month, so old leavers don't clutter
      // every future month's report.
      final memberIdsWithActivity = {
        for (final meal in meals) meal.memberId,
        for (final payment in payments) payment.memberId,
      };
      final relevantMembers = allMembers
          .where(
            (member) =>
                member.isActive || memberIdsWithActivity.contains(member.id),
          )
          .toList(growable: false);

      return ref
          .watch(calculationEngineProvider)
          .calculateMonth(
            members: relevantMembers,
            mealEntries: meals,
            expenses: expenses,
            payments: payments,
          );
    });
