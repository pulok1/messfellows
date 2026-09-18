import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../models/expense.dart';
import '../expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  final AppDatabase _db;

  LocalExpenseRepository(this._db);

  Expense _toModel(ExpenseRow row) => Expense(
    id: row.id,
    messId: row.messId,
    date: row.date,
    amount: Money(row.amountMinorUnits),
    paidByMemberId: row.paidByMemberId,
    bazarList: row.bazarList,
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  @override
  Stream<List<Expense>> watchExpensesForMonth(
    String messId,
    int year,
    int month,
  ) {
    final start = firstDayOfMonth(year, month);
    final end = firstDayOfNextMonth(year, month);
    final query = _db.select(_db.expenses)
      ..where(
        (t) =>
            t.messId.equals(messId) &
            t.date.isBiggerOrEqualValue(start) &
            t.date.isSmallerThanValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<Expense>> watchExpensesForMember(String messId, String memberId) {
    final query = _db.select(_db.expenses)
      ..where(
        (t) => t.messId.equals(messId) & t.paidByMemberId.equals(memberId),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<Expense> addExpense({
    required String messId,
    required DateTime date,
    required Money amount,
    required String paidByMemberId,
    required String bazarList,
    String? note,
  }) async {
    if (amount.minorUnits <= 0) {
      throw const ValidationException('Amount must be greater than zero.');
    }

    final now = DateTime.now();
    final id = IdGenerator.generate();
    final day = dateOnly(date);
    await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: id,
            messId: messId,
            date: day,
            amountMinorUnits: amount.minorUnits,
            paidByMemberId: paidByMemberId,
            bazarList: bazarList,
            note: Value(note),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return Expense(
      id: id,
      messId: messId,
      date: day,
      amount: amount,
      paidByMemberId: paidByMemberId,
      bazarList: bazarList,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    if (expense.amount.minorUnits <= 0) {
      throw const ValidationException('Amount must be greater than zero.');
    }
    await (_db.update(
      _db.expenses,
    )..where((t) => t.id.equals(expense.id))).write(
      ExpensesCompanion(
        date: Value(dateOnly(expense.date)),
        amountMinorUnits: Value(expense.amount.minorUnits),
        paidByMemberId: Value(expense.paidByMemberId),
        bazarList: Value(expense.bazarList),
        note: Value(expense.note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
  }
}
