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
    required String category,
    String? note,
  });

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(String id);
}
