import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/errors/app_exception.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/repositories/local/local_settlement_repository.dart';

void main() {
  late AppDatabase db;
  late LocalMealRepository mealRepo;
  late LocalSettlementRepository settlementRepo;
  late Mess mess;
  late Member rahim;
  late Member karim;
  final date = DateTime(2026, 9, 16);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mealRepo = LocalMealRepository(db);
    settlementRepo = LocalSettlementRepository(db);
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

  Future<String> closeSeptember() async {
    final settlement = await settlementRepo.closeMonth(
      messId: mess.id,
      year: 2026,
      month: 9,
      totalExpense: const Money(0),
      totalMeals: 0,
      mealRate: const Money(0),
      balances: const [],
    );
    return settlement.id;
  }

  test('setMealsForDate writes every member in one go', () async {
    await mealRepo.setMeal(messId: mess.id, memberId: rahim.id, date: date, lunch: 1);

    await mealRepo.setMealsForDate(
      messId: mess.id,
      date: date,
      countsByMember: {
        rahim.id: (breakfast: 1, lunch: 2, dinner: 0),
        karim.id: (breakfast: 0, lunch: 1, dinner: 1),
      },
    );

    final meals = await mealRepo.watchMealsForDate(mess.id, date).first;
    final byMember = {for (final m in meals) m.memberId: m};
    expect(meals, hasLength(2));
    expect(byMember[rahim.id]!.totalMeals, 3);
    expect(byMember[rahim.id]!.lunch, 2);
    expect(byMember[karim.id]!.totalMeals, 2);
  });

  test('a failing bulk write leaves the day exactly as it was', () async {
    await mealRepo.setMeal(messId: mess.id, memberId: rahim.id, date: date, lunch: 1);

    await expectLater(
      mealRepo.setMealsForDate(
        messId: mess.id,
        date: date,
        countsByMember: {
          rahim.id: (breakfast: 1, lunch: 1, dinner: 1),
          'no-such-member': (breakfast: 1, lunch: 1, dinner: 1),
        },
      ),
      throwsA(anything),
    );

    final meals = await mealRepo.watchMealsForDate(mess.id, date).first;
    expect(meals.single.totalMeals, 1);
  });

  test('meals in a closed month cannot be changed until it is reopened', () async {
    await mealRepo.setMeal(messId: mess.id, memberId: rahim.id, date: date, lunch: 1);
    final settlementId = await closeSeptember();

    await expectLater(
      mealRepo.setMeal(messId: mess.id, memberId: rahim.id, date: date, dinner: 1),
      throwsA(isA<MonthClosedException>()),
    );
    await expectLater(
      mealRepo.setMealsForDate(
        messId: mess.id,
        date: date,
        countsByMember: {karim.id: (breakfast: 1, lunch: 1, dinner: 1)},
      ),
      throwsA(isA<MonthClosedException>()),
    );
    final frozen = await mealRepo.watchMealsForDate(mess.id, date).first;
    expect(frozen.single.totalMeals, 1);

    // Other months stay editable.
    await mealRepo.setMeal(
      messId: mess.id,
      memberId: rahim.id,
      date: DateTime(2026, 10, 1),
      lunch: 1,
    );

    await settlementRepo.reopenMonth(settlementId);
    await mealRepo.setMeal(messId: mess.id, memberId: rahim.id, date: date, dinner: 1);
    final entry = await mealRepo.getMealEntry(mess.id, rahim.id, date);
    expect(entry!.totalMeals, 2);
  });
}
