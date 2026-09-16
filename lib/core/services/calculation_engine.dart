import '../../models/expense.dart';
import '../../models/meal_entry.dart';
import '../../models/member.dart';
import '../../models/member_balance.dart';
import '../../models/month_calculation_result.dart';
import '../../models/payment.dart';
import '../utils/money.dart';

/// Pure domain service that turns raw records into meal rates and member
/// balances. Deliberately has no dependency on Flutter, Drift, or
/// Riverpod — see section 8 of the product spec — so it can be unit tested
/// in isolation and reused unchanged by both the live dashboard (for the
/// current, still-open month) and the month-closing flow (which freezes its
/// output into a [MonthlySettlement][../../models/settlement.dart]).
///
/// Accounting rule (section 10/11): meal rate is strictly
/// `total food expense / total meals`. No carry-forward, guest meals, or
/// other adjustments are applied — those are out of scope for this engine
/// until the product spec defines them.
class CalculationEngine {
  const CalculationEngine();

  /// Computes totals and a per-member balance for every [members] entry,
  /// from that month's [mealEntries], [expenses] and [payments].
  ///
  /// Members with zero meals or zero payments are still included with a
  /// zero-valued balance rather than being omitted — see section 9's
  /// "member has zero meals but paid money" case.
  MonthCalculationResult calculateMonth({
    required List<Member> members,
    required List<MealEntry> mealEntries,
    required List<Expense> expenses,
    required List<Payment> payments,
  }) {
    final totalMeals = mealEntries.fold<int>(0, (sum, e) => sum + e.totalMeals);

    final totalExpense = expenses.fold<Money>(
      const Money.zero(),
      (sum, e) => sum + e.amount,
    );

    // Money.divide already returns zero for a zero divisor, so a mess with
    // no recorded meals yet gets a zero rate rather than throwing or
    // producing NaN/infinity.
    final mealRate = totalExpense.divide(totalMeals);

    final balances = members.map((member) {
      final memberMeals = mealEntries
          .where((entry) => entry.memberId == member.id)
          .fold<int>(0, (sum, entry) => sum + entry.totalMeals);

      final mealCost = mealRate * memberMeals;

      final paidAmount = payments
          .where((payment) => payment.memberId == member.id)
          .fold<Money>(const Money.zero(), (sum, payment) => sum + payment.amount);

      final balance = paidAmount - mealCost;

      return MemberBalance(
        memberId: member.id,
        memberName: member.name,
        mealCount: memberMeals,
        mealCost: mealCost,
        paidAmount: paidAmount,
        balance: balance,
      );
    }).toList(growable: false);

    return MonthCalculationResult(
      totalExpense: totalExpense,
      totalMeals: totalMeals,
      mealRate: mealRate,
      memberBalances: balances,
    );
  }
}
