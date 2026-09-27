import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/services/backup_service.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/activity_type.dart';
import 'package:messfellows/models/meal_slot.dart';
import 'package:messfellows/repositories/local/local_activity_log_repository.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('late meal changes survive a backup, and the restore is logged', () async {
    final mess = await LocalMessRepository(
      source,
    ).createMess(name: 'Round Trip', currencyCode: 'BDT', currencySymbol: '৳');
    final rahim = await LocalMemberRepository(
      source,
    ).addMember(messId: mess.id, name: 'Rahim');
    await LocalMealRepository(source, clock: () => DateTime(2026, 9, 25, 9)).setMeal(
      messId: mess.id,
      memberId: rahim.id,
      date: DateTime(2026, 9, 24),
      lunch: 1,
      reason: 'Forgot to mark',
    );

    final json = await BackupService(source).exportToJson();
    await BackupService(target).importFromJson(json);

    final log = await LocalActivityLogRepository(target).watchLog(mess.id).first;
    final change = log.singleWhere((e) => e.type == ActivityType.mealChangedLater);
    expect(change.mealSlot, MealSlot.lunch);
    expect(change.mealDate, DateTime(2026, 9, 24));
    expect(change.previousCount, 0);
    expect(change.count, 1);
    expect(change.detail, 'Forgot to mark');
    expect(log.where((e) => e.type == ActivityType.backupRestored), hasLength(1));
  });

  test('an older backup without a log still imports, and the restore is logged', () async {
    final mess = await LocalMessRepository(
      source,
    ).createMess(name: 'Old Backup', currencyCode: 'BDT', currencySymbol: '৳');
    final document =
        jsonDecode(await BackupService(source).exportToJson()) as Map<String, dynamic>
          ..remove('activityLogs');

    await BackupService(target).importFromJson(jsonEncode(document));

    final log = await LocalActivityLogRepository(target).watchLog(mess.id).first;
    expect(log.single.type, ActivityType.backupRestored);
  });
}
