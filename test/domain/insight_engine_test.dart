import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/services/insight_engine.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/models/expense.dart';
import 'package:messfellows/models/insight.dart';
import 'package:messfellows/models/meal_entry.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/month_calculation_result.dart';

void main() {
  const engine = InsightEngine();
  final epoch = DateTime(2026);

  Member member(String id) => Member(
    id: id,
    messId: 'm',
    name: id.toUpperCase(),
    joinedAt: epoch,
    isActive: true,
    createdAt: epoch,
    updatedAt: epoch,
  );

  MealEntry meal(String memberId, int day, {int count = 1}) => MealEntry(
    id: '$memberId-$day',
    messId: 'm',
    memberId: memberId,
    date: DateTime(2026, 9, day),
    breakfast: 0,
    lunch: count,
    dinner: 0,
    createdAt: epoch,
    updatedAt: epoch,
  );

  Expense bazar(String paidBy, int day, int taka) => Expense(
    id: '$paidBy-$day-$taka',
    messId: 'm',
    date: DateTime(2026, 9, day),
    amount: Money.fromMajor(taka),
    paidByMemberId: paidBy,
    bazarList: 'Chal, dal',
    createdAt: epoch,
    updatedAt: epoch,
  );

  MonthCalculationResult result({int meals = 0, int taka = 0}) =>
      MonthCalculationResult(
        totalExpense: Money.fromMajor(taka),
        totalMeals: meals,
        mealRate: Money.fromMajor(taka).divide(meals),
        memberBalances: const [],
      );

  List<Insight> run({
    required DateTime now,
    MonthCalculationResult? current,
    MonthCalculationResult? previous,
    List<MealEntry> meals = const [],
    List<Expense> expenses = const [],
    List<Member>? members,
  }) => engine.build(
    now: now,
    current: current ?? result(),
    previous: previous,
    meals: meals,
    expenses: expenses,
    activeMembers: members ?? [member('a'), member('b')],
  );

  test('says nothing for a mess with no members', () {
    expect(run(now: DateTime(2026, 9, 20, 20), members: const []), isEmpty);
  });

  group('meals not marked today', () {
    test('nudges in the afternoon when today has no eaten meals', () {
      final insights = run(
        now: DateTime(2026, 9, 5, 15),
        meals: [meal('a', 4), meal('b', 5, count: 0)],
      );
      expect(insights.first, isA<MealsNotMarkedToday>());
    });

    test('stays quiet in the morning or once a meal is marked', () {
      expect(
        run(now: DateTime(2026, 9, 5, 9)).whereType<MealsNotMarkedToday>(),
        isEmpty,
      );
      expect(
        run(
          now: DateTime(2026, 9, 5, 15),
          meals: [meal('a', 5)],
        ).whereType<MealsNotMarkedToday>(),
        isEmpty,
      );
    });
  });

  group('no recent bazar', () {
    test('reports the gap when meals continued after the last bazar', () {
      final insights = run(
        now: DateTime(2026, 9, 8, 9),
        meals: [meal('a', 7)],
        expenses: [bazar('a', 2, 500), bazar('b', 4, 300)],
      );
      expect(insights.whereType<NoRecentBazar>().single.days, 4);
    });

    test('stays quiet for short gaps or when nobody ate since', () {
      expect(
        run(
          now: DateTime(2026, 9, 6, 9),
          meals: [meal('a', 5)],
          expenses: [bazar('a', 4, 300)],
        ).whereType<NoRecentBazar>(),
        isEmpty,
      );
      expect(
        run(
          now: DateTime(2026, 9, 12, 9),
          meals: [meal('a', 3)],
          expenses: [bazar('a', 4, 300)],
        ).whereType<NoRecentBazar>(),
        isEmpty,
      );
    });
  });

  group('meal rate change', () {
    test('compares against last month once there are enough meals', () {
      final insights = run(
        now: DateTime(2026, 9, 20, 9),
        current: result(meals: 20, taka: 1100), // 55.00
        previous: result(meals: 20, taka: 1000), // 50.00
      );
      final change = insights.whereType<MealRateChange>().single;
      expect(change.percent, 10);
      expect(change.previousRate, Money.fromMajor(50));
    });

    test('ignores small swings, thin data and a missing last month', () {
      final now = DateTime(2026, 9, 20, 9);
      expect(
        run(
          now: now,
          current: result(meals: 20, taka: 1020),
          previous: result(meals: 20, taka: 1000),
        ).whereType<MealRateChange>(),
        isEmpty,
      );
      expect(
        run(
          now: now,
          current: result(meals: 5, taka: 500),
          previous: result(meals: 20, taka: 1000),
        ).whereType<MealRateChange>(),
        isEmpty,
      );
      expect(
        run(
          now: now,
          current: result(meals: 20, taka: 1500),
        ).whereType<MealRateChange>(),
        isEmpty,
      );
    });
  });

  group('members without bazar', () {
    test('names members who ate but never paid for bazar', () {
      final insights = run(
        now: DateTime(2026, 9, 12, 9),
        members: [member('a'), member('b'), member('c')],
        meals: [meal('a', 11), meal('b', 11)],
        expenses: [bazar('a', 11, 400)],
      );
      // C hasn't eaten, so isn't singled out.
      expect(insights.whereType<MembersWithoutBazar>().single.memberNames, [
        'B',
      ]);
    });

    test('waits until the 10th', () {
      expect(
        run(
          now: DateTime(2026, 9, 9, 9),
          meals: [meal('a', 8), meal('b', 8)],
          expenses: [bazar('a', 8, 400)],
        ).whereType<MembersWithoutBazar>(),
        isEmpty,
      );
    });
  });

  group('bazar projection', () {
    test('extrapolates to month end, rounded to 100', () {
      final insights = run(
        now: DateTime(2026, 9, 10, 9),
        current: result(meals: 30, taka: 3070),
      );
      // 3070 / 10 days * 30 days = 9210 -> 9200.
      expect(
        insights.whereType<BazarProjection>().single.projectedTotal,
        Money.fromMajor(9200),
      );
    });

    test('stays quiet early in the month and on its last day', () {
      expect(
        run(
          now: DateTime(2026, 9, 3, 9),
          current: result(meals: 5, taka: 900),
        ).whereType<BazarProjection>(),
        isEmpty,
      );
      expect(
        run(
          now: DateTime(2026, 9, 30, 9),
          current: result(meals: 90, taka: 9000),
        ).whereType<BazarProjection>(),
        isEmpty,
      );
    });
  });
}
