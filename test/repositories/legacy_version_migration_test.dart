import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/repositories/local/local_expense_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

// Regression test: a real installed app that hasn't been updated in a long
// time upgrades straight from its original schema (v1) to today's in one
// jump. TableMigration always rebuilds a table to *today's* full column
// set, so any migration block that doesn't account for a column a *later*
// block adds to the same table will fail with "no such column" for a
// device old enough to skip straight past both — which is exactly what
// broke the Bazar screen (and silently dropped new entries) for a real
// user updating from an old build. See the `from < 2` (expenses) and
// `from < 4` (messes) blocks in app_database.dart.
void main() {
  test('a v1 database upgrades straight to current without losing data', () async {
    final dir = await Directory.systemTemp.createTemp('messfellows_diag');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    var db = AppDatabase.forTesting(NativeDatabase(file));
    final mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await LocalMemberRepository(db).addMember(messId: mess.id, name: 'Alice');

    await db.customStatement('ALTER TABLE expenses DROP COLUMN bazar_list');
    await db.customStatement('ALTER TABLE expenses DROP COLUMN deleted_at');
    await db.customStatement("ALTER TABLE expenses ADD COLUMN category TEXT NOT NULL DEFAULT ''");
    await db.customStatement('ALTER TABLE payments DROP COLUMN deleted_at');
    await db.customStatement('ALTER TABLE messes DROP COLUMN track_breakfast');
    await db.customStatement('ALTER TABLE messes DROP COLUMN track_lunch');
    await db.customStatement('ALTER TABLE messes DROP COLUMN track_dinner');
    await db.customStatement('ALTER TABLE messes DROP COLUMN rules_updated_at');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final expenseRepo = LocalExpenseRepository(db);
    await expenseRepo.addExpense(
      messId: mess.id,
      date: DateTime(2026, 9, 30),
      amount: Money.fromMajor(100),
      paidByMemberId: member.id,
      bazarList: 'Rice, Fish',
    );

    final entries = await expenseRepo.watchExpensesForMonth(mess.id, 2026, 9).first;
    expect(entries, hasLength(1));
    expect(entries.single.bazarList, 'Rice, Fish');
  });
}
