import '../core/utils/money.dart';
import 'settlement_status.dart';

/// A frozen snapshot of one calendar month's totals, created when the
/// manager closes the month. Per-member results live alongside it in
/// [MonthlySettlementMember] rows.
class MonthlySettlement {
  final String id;
  final String messId;
  final int month; // 1-12
  final int year;
  final Money totalExpense;
  final int totalMeals;
  final Money mealRate;
  final SettlementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonthlySettlement({
    required this.id,
    required this.messId,
    required this.month,
    required this.year,
    required this.totalExpense,
    required this.totalMeals,
    required this.mealRate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isClosed => status == SettlementStatus.closed;
}

/// One member's frozen result within a [MonthlySettlement].
class MonthlySettlementMember {
  final String id;
  final String settlementId;
  final String memberId;
  final int mealCount;
  final Money mealCost;
  final Money paidAmount;
  final Money balance;
  final DateTime createdAt;

  const MonthlySettlementMember({
    required this.id,
    required this.settlementId,
    required this.memberId,
    required this.mealCount,
    required this.mealCost,
    required this.paidAmount,
    required this.balance,
    required this.createdAt,
  });
}
