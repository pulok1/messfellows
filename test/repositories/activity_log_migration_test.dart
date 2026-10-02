import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/activity_type.dart';
import 'package:messfellows/models/meal_slot.dart';
import 'package:messfellows/repositories/local/activity_logger.dart';
import 'package:messfellows/repositories/local/local_activity_log_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

void main() {
  test('a v6 database gains the meal-change log columns on upgrade', () async {
    final dir = await Directory.systemTemp.createTemp('messfellows_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    // Build today's schema, then roll activity_logs back to its v6 shape.
    var db = AppDatabase.forTesting(NativeDatabase(file));
    final mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    for (final column in [
      'meal_date',
      'meal_slot',
      'previous_count',
      'previous_amount_minor_units',
      'previous_detail',
    ]) {
      await db.customStatement('ALTER TABLE activity_logs DROP COLUMN $column');
    }
    await db.customStatement('PRAGMA user_version = 6');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    await logActivity(
      db,
      messId: mess.id,
      type: ActivityType.mealChangedLater,
      mealDate: DateTime(2026, 9, 20),
      mealSlot: MealSlot.lunch,
      previousCount: 0,
      count: 1,
      detail: 'Forgot to mark',
    );

    final entry = (await LocalActivityLogRepository(db).watchLog(mess.id).first).single;
    expect(entry.mealSlot, MealSlot.lunch);
    expect(entry.mealDate, DateTime(2026, 9, 20));
    expect(entry.previousCount, 0);
    expect(entry.count, 1);
  });
}
