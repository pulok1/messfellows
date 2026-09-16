import '../core/utils/money.dart';
import 'balance_status.dart';

/// The calculation engine's output for one member within a month: how many
/// meals they ate, what those meals cost, what they paid in, and the net
/// balance. This is a computed value, not a database row — it's recomputed
/// live for an open month, and frozen into a [MonthlySettlementMember] row
/// only when the month is closed.
class MemberBalance {
  final String memberId;
  final String memberName;
  final int mealCount;
  final Money mealCost;

  /// This member's total contribution: cash [Payment]s plus any [Expense]s
  /// (bazar) they personally paid for — see CalculationEngine for why both
  /// count.
  final Money paidAmount;
  final Money balance;

  const MemberBalance({
    required this.memberId,
    required this.memberName,
    required this.mealCount,
    required this.mealCost,
    required this.paidAmount,
    required this.balance,
  });

  BalanceStatus get status {
    if (balance.isPositive) return BalanceStatus.willReceive;
    if (balance.isNegative) return BalanceStatus.needsToPay;
    return BalanceStatus.settled;
  }

  /// The balance magnitude, since UI copy already conveys direction via
  /// "will receive" / "needs to pay" and shouldn't show a signed amount.
  Money get balanceMagnitude => balance.isNegative ? -balance : balance;
}
