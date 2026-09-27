import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/errors/app_exception.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/activity_type.dart';
import 'package:messfellows/models/meal_slot.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/repositories/local/local_activity_log_repository.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

void main() {
  late AppDatabase db;
  late LocalMealRepository mealRepo;
  late LocalActivityLogRepository logRepo;
  late Mess mess;
  late Member rahim;
  late Member karim;
  // "Now" is midday on the 20th, so the 19th is a past day.
  final now = DateTime(2026, 9, 20, 12);
  final today = DateTime(2026, 9, 20);
  final yesterday = DateTime(2026, 9, 19);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mealRepo = LocalMealRepository(db, clock: () => now);
    logRepo = LocalActivityLogRepository(db);
    mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final memberRepo = LocalMemberRepository(db);
    rahim = await memberRepo.addMember(messId: mess.id, name: 'Rahim');
    karim = await memberRepo.addMember(messId: mess.id, name: 'Karim');
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<dynamic>> mealLog() async => (await logRepo.watchLog(mess.id).first)
      .where((e) => e.type == ActivityType.mealChangedLater)
      .toList();

  test('today and tomorrow need no reason and are not logged', () async {
    await mealRepo.setMeal(messId: mess.id, memberId: rahim.id, date: today, lunch: 1);
    await mealRepo.setMeal(
      messId: mess.id,
      memberId: rahim.id,
      date: DateTime(2026, 9, 21),
      lunch: 1,
    );

    expect(await mealLog(), isEmpty);
  });

  test('a past day is refused without a reason, and nothing changes', () async {
    for (final reason in [null, '', '   ']) {
      await expectLater(
        mealRepo.setMeal(
          messId: mess.id,
          memberId: rahim.id,
          date: yesterday,
          lunch: 1,
          reason: reason,
        ),
        throwsA(isA<ReasonRequiredException>()),
      );
    }
    await expectLater(
      mealRepo.setMealsForDate(
        messId: mess.id,
        date: yesterday,
        countsByMember: {rahim.id: (breakfast: 1, lunch: 1, dinner: 1)},
      ),
      throwsA(isA<ReasonRequiredException>()),
    );

    expect(await mealRepo.getMealEntry(mess.id, rahim.id, yesterday), isNull);
    expect(await mealLog(), isEmpty);
  });

  test('a past-day change is saved and logged slot by slot with its reason', () async {
    await mealRepo.setMeal(
      messId: mess.id,
      memberId: rahim.id,
      date: yesterday,
      lunch: 1,
      reason: '  Forgot to mark lunch  ',
    );

    final entry = (await mealLog()).single;
    expect(entry.memberId, rahim.id);
    expect(entry.mealDate, yesterday);
    expect(entry.mealSlot, MealSlot.lunch);
    expect(entry.previousCount, 0);
    expect(entry.count, 1);
    expect(entry.detail, 'Forgot to mark lunch');
  });

  test('a past-day bulk write logs only the slots that really changed', () async {
    await mealRepo.setMealsForDate(
      messId: mess.id,
      date: yesterday,
      countsByMember: {rahim.id: (breakfast: 0, lunch: 1, dinner: 0)},
      reason: 'Entered late',
    );
    await mealRepo.setMealsForDate(
      messId: mess.id,
      date: yesterday,
      countsByMember: {
        // Lunch stays 1 (not logged); dinner 0 -> 2 (logged).
        rahim.id: (breakfast: 0, lunch: 1, dinner: 2),
        // Nothing changes for Karim (not logged).
        karim.id: (breakfast: 0, lunch: 0, dinner: 0),
      },
      reason: 'Guest at dinner',
    );

    final changes = await logRepo
        .watchMealChangesForDate(mess.id, yesterday)
        .first;
    expect(changes.map((e) => (e.mealSlot, e.previousCount, e.count, e.detail)), [
      (MealSlot.lunch, 0, 1, 'Entered late'),
      (MealSlot.dinner, 0, 2, 'Guest at dinner'),
    ]);
    expect(await logRepo.watchMealChangesForDate(mess.id, today).first, isEmpty);
  });
}
