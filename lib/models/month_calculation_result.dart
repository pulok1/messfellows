import '../core/utils/money.dart';
import 'member_balance.dart';

/// Everything the dashboard/report screens need for one month, produced by
/// the calculation engine from raw meal/expense/payment records.
class MonthCalculationResult {
  final Money totalExpense;
  final int totalMeals;
  final Money mealRate;
  final List<MemberBalance> memberBalances;

  const MonthCalculationResult({
    required this.totalExpense,
    required this.totalMeals,
    required this.mealRate,
    required this.memberBalances,
  });

  /// True when there's nothing to divide yet — the UI shows "No meals
  /// recorded yet" instead of a rate in this case.
  bool get hasNoMeals => totalMeals == 0;
}
