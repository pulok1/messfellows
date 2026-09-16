import '../models/member_balance.dart';
import '../models/settlement.dart';
import '../core/utils/money.dart';

abstract interface class SettlementRepository {
  /// All settlements for a mess, newest month first — the source for the
  /// month history list.
  Stream<List<MonthlySettlement>> watchSettlements(String messId);

  Future<MonthlySettlement?> getSettlement(String messId, int year, int month);

  Stream<List<MonthlySettlementMember>> watchSettlementMembers(String settlementId);

  /// Freezes [balances] (already computed by [CalculationEngine]) into a
  /// settlement row + one member row each. Overwrites any existing
  /// settlement for the same month so re-closing after a reopen replaces
  /// the prior snapshot rather than duplicating it.
  Future<MonthlySettlement> closeMonth({
    required String messId,
    required int year,
    required int month,
    required Money totalExpense,
    required int totalMeals,
    required Money mealRate,
    required List<MemberBalance> balances,
  });

  /// Reopens a closed month so its meals/expenses/payments can be edited
  /// again. Does not delete the frozen settlement row — closing again will
  /// overwrite it — so a manager can back out of a reopen without losing
  /// the last-closed numbers.
  Future<void> reopenMonth(String settlementId);
}
