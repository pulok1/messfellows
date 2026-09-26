import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/errors/app_exception.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/repositories/local/local_expense_repository.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

/// Data-integrity tests against a real (in-memory) SQLite database, per
/// section 37 of the product spec — these exercise the schema's own
/// constraints (unique keys, foreign keys) and the repository-level
/// validation, not just the pure calculation engine.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('duplicate meal record for the same member/date is impossible', () async {
    final messRepo = LocalMessRepository(db);
    final memberRepo = LocalMemberRepository(db);
    final mealRepo = LocalMealRepository(db);

    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await memberRepo.addMember(messId: mess.id, name: 'Rahim');
    final date = DateTime(2026, 9, 16);

    await mealRepo.setMeal(messId: mess.id, memberId: member.id, date: date, lunch: 1);
    // A second call for the same member/date must update the existing row,
    // not create a second one.
    await mealRepo.setMeal(messId: mess.id, memberId: member.id, date: date, dinner: 1);

    final entry = await mealRepo.getMealEntry(mess.id, member.id, date);
    expect(entry, isNotNull);
    expect(entry!.lunch, 1);
    expect(entry.dinner, 1);

    final allForDate = await mealRepo.watchMealsForDate(mess.id, date).first;
    expect(allForDate.length, 1);
  });

  test('the unique index rejects a direct duplicate insert at the database level', () async {
    final messRepo = LocalMessRepository(db);
    final memberRepo = LocalMemberRepository(db);
    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await memberRepo.addMember(messId: mess.id, name: 'Rahim');
    final date = DateTime(2026, 9, 16);

    await db
        .into(db.mealEntries)
        .insert(
          MealEntriesCompanion.insert(
            id: 'meal-1',
            messId: mess.id,
            memberId: member.id,
            date: date,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    expect(
      () => db.into(db.mealEntries).insert(
        MealEntriesCompanion.insert(
          id: 'meal-2',
          messId: mess.id,
          memberId: member.id,
          date: date,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('invalid member references are rejected by the foreign key constraint', () async {
    final messRepo = LocalMessRepository(db);
    final expenseRepo = LocalExpenseRepository(db);
    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');

    expect(
      () => expenseRepo.addExpense(
        messId: mess.id,
        date: DateTime(2026, 9, 16),
        amount: const Money(10000),
        paidByMemberId: 'no-such-member',
        bazarList: 'Rice, dal',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('invalid (non-positive) expense amounts are rejected', () async {
    final messRepo = LocalMessRepository(db);
    final memberRepo = LocalMemberRepository(db);
    final expenseRepo = LocalExpenseRepository(db);
    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await memberRepo.addMember(messId: mess.id, name: 'Rahim');

    expect(
      () => expenseRepo.addExpense(
        messId: mess.id,
        date: DateTime(2026, 9, 16),
        amount: const Money(0),
        paidByMemberId: member.id,
        bazarList: 'Rice, dal',
      ),
      throwsA(isA<ValidationException>()),
    );
    expect(
      () => expenseRepo.addExpense(
        messId: mess.id,
        date: DateTime(2026, 9, 16),
        amount: const Money(-500),
        paidByMemberId: member.id,
        bazarList: 'Rice, dal',
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('empty member names are rejected', () async {
    final messRepo = LocalMessRepository(db);
    final memberRepo = LocalMemberRepository(db);
    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');

    expect(
      () => memberRepo.addMember(messId: mess.id, name: ''),
      throwsA(isA<ValidationException>()),
    );
    expect(
      () => memberRepo.addMember(messId: mess.id, name: '   '),
      throwsA(isA<ValidationException>()),
    );
  });

  test('archiving keeps a member available for historical reports', () async {
    final messRepo = LocalMessRepository(db);
    final memberRepo = LocalMemberRepository(db);
    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await memberRepo.addMember(messId: mess.id, name: 'Rahim');

    await memberRepo.archiveMember(member.id);

    final active = await memberRepo.watchActiveMembers(mess.id).first;
    expect(active, isEmpty);

    final all = await memberRepo.watchAllMembers(mess.id).first;
    expect(all, hasLength(1));
    expect(all.single.isActive, isFalse);
    expect(all.single.id, member.id);
  });

  test('editing a meal, expense or payment is reflected on the next read', () async {
    final messRepo = LocalMessRepository(db);
    final memberRepo = LocalMemberRepository(db);
    final mealRepo = LocalMealRepository(db);
    final expenseRepo = LocalExpenseRepository(db);
    final mess = await messRepo.createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await memberRepo.addMember(messId: mess.id, name: 'Rahim');
    final date = DateTime(2026, 9, 16);

    await mealRepo.setMeal(messId: mess.id, memberId: member.id, date: date, lunch: 1);
    var entry = await mealRepo.getMealEntry(mess.id, member.id, date);
    expect(entry!.lunch, 1);
    expect(entry.dinner, 0);

    await mealRepo.setMeal(messId: mess.id, memberId: member.id, date: date, dinner: 1);
    entry = await mealRepo.getMealEntry(mess.id, member.id, date);
    expect(entry!.lunch, 1);
    expect(entry.dinner, 1);

    final expense = await expenseRepo.addExpense(
      messId: mess.id,
      date: date,
      amount: const Money(10000),
      paidByMemberId: member.id,
      bazarList: 'Rice, dal',
    );
    await expenseRepo.updateExpense(expense.copyWith(amount: const Money(25000)));
    final expenses = await expenseRepo.watchExpensesForMonth(mess.id, date.year, date.month).first;
    expect(expenses.single.amount, const Money(25000));
  });
}
