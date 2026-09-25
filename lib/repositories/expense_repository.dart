import '../core/utils/money.dart';
import '../models/expense.dart';

abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchExpensesForMonth(
    String messId,
    int year,
    int month,
  );

  /// All of one member's expense entries, for the member detail screen and
  /// the "filter by member" view on the bazar screen.
  Stream<List<Expense>> watchExpensesForMember(String messId, String memberId);

  Future<Expense> addExpense({
    required String messId,
    required DateTime date,
    required Money amount,
    required String paidByMemberId,
    required String bazarList,
    String? note,
  });

  Future<void> updateExpense(Expense expense);

  /// Soft-deletes: the entry moves to the Recycle Bin rather than
  /// disappearing outright. See [restoreExpense]/[permanentlyDeleteExpense].
  Future<void> deleteExpense(String id);

  /// All soft-deleted entries for [messId], most recently deleted first —
  /// the Recycle Bin's source.
  Stream<List<Expense>> watchDeletedExpenses(String messId);

  Future<void> restoreExpense(String id);

  Future<void> permanentlyDeleteExpense(String id);

  /// Hard-deletes entries soft-deleted more than [retention] ago.
  Future<void> purgeExpiredExpenses(String messId, Duration retention);
}
