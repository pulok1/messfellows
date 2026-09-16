import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/services/calculation_engine.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/models/balance_status.dart';
import 'package:messfellows/models/expense.dart';
import 'package:messfellows/models/meal_entry.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/payment.dart';

/// Builds a member with sensible defaults so each test only has to specify
/// what it cares about.
Member _member(String id, {String name = 'Member'}) {
  final now = DateTime(2026, 9, 1);
  return Member(
    id: id,
    messId: 'mess-1',
    name: name,
    joinedAt: now,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

MealEntry _meal(
  String memberId,
  DateTime date, {
  bool breakfast = false,
  bool lunch = false,
  bool dinner = false,
}) {
  final now = DateTime(2026, 9, 1);
  return MealEntry(
    id: '${memberId}_${date.toIso8601String()}',
    messId: 'mess-1',
    memberId: memberId,
    date: date,
    breakfast: breakfast,
    lunch: lunch,
    dinner: dinner,
    createdAt: now,
    updatedAt: now,
  );
}

Expense _expense(String id, Money amount, {String paidBy = 'm1'}) {
  final now = DateTime(2026, 9, 1);
  return Expense(
    id: id,
    messId: 'mess-1',
    date: now,
    amount: amount,
    paidByMemberId: paidBy,
    category: 'Grocery',
    createdAt: now,
    updatedAt: now,
  );
}

Payment _payment(String id, String memberId, Money amount) {
  final now = DateTime(2026, 9, 1);
  return Payment(
    id: id,
    messId: 'mess-1',
    date: now,
    memberId: memberId,
    amount: amount,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const engine = CalculationEngine();
  final d1 = DateTime(2026, 9, 1);
  final d2 = DateTime(2026, 9, 2);

  test('one member, straightforward meals/expense/payment', () {
    final m1 = _member('m1', name: 'Rahim');
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, breakfast: true, lunch: true, dinner: true)],
      expenses: [_expense('e1', const Money(30000))], // ৳300
      payments: [_payment('p1', 'm1', const Money(50000))], // ৳500
    );

    expect(result.totalMeals, 3);
    expect(result.totalExpense, const Money(30000));
    expect(result.mealRate, const Money(10000)); // ৳100/meal
    expect(result.memberBalances.single.mealCost, const Money(30000));
    expect(result.memberBalances.single.balance, const Money(20000)); // will receive ৳200
    expect(result.memberBalances.single.status, BalanceStatus.willReceive);
  });

  test('multiple members split a shared expense by meal count', () {
    final m1 = _member('m1', name: 'Rahim');
    final m2 = _member('m2', name: 'Karim');
    final result = engine.calculateMonth(
      members: [m1, m2],
      mealEntries: [
        _meal('m1', d1, breakfast: true, lunch: true, dinner: true), // 3
        _meal('m2', d1, breakfast: true, lunch: false, dinner: true), // 2
      ],
      expenses: [_expense('e1', const Money(50000))], // ৳500 / 5 meals = ৳100/meal
      payments: [_payment('p1', 'm1', const Money(30000)), _payment('p2', 'm2', const Money(20000))],
    );

    expect(result.totalMeals, 5);
    expect(result.mealRate, const Money(10000));

    final rahim = result.memberBalances.firstWhere((b) => b.memberId == 'm1');
    final karim = result.memberBalances.firstWhere((b) => b.memberId == 'm2');
    expect(rahim.mealCost, const Money(30000));
    expect(karim.mealCost, const Money(20000));
  });

  test('different meal counts per member are reflected in meal cost', () {
    final m1 = _member('m1');
    final m2 = _member('m2');
    final result = engine.calculateMonth(
      members: [m1, m2],
      mealEntries: [
        _meal('m1', d1, breakfast: true, lunch: true, dinner: true),
        _meal('m1', d2, breakfast: true, lunch: true, dinner: true),
        _meal('m2', d1, lunch: true),
      ],
      expenses: [_expense('e1', const Money(70000))], // 7 meals -> ৳100/meal
      payments: const [],
    );

    final m1Balance = result.memberBalances.firstWhere((b) => b.memberId == 'm1');
    final m2Balance = result.memberBalances.firstWhere((b) => b.memberId == 'm2');
    expect(m1Balance.mealCount, 6);
    expect(m2Balance.mealCount, 1);
    expect(m1Balance.mealCost, const Money(60000));
    expect(m2Balance.mealCost, const Money(10000));
  });

  test('different payment amounts per member produce different balances', () {
    final m1 = _member('m1');
    final m2 = _member('m2');
    final result = engine.calculateMonth(
      members: [m1, m2],
      mealEntries: [
        _meal('m1', d1, lunch: true),
        _meal('m2', d1, lunch: true),
      ],
      expenses: [_expense('e1', const Money(20000))], // ৳100/meal
      payments: [_payment('p1', 'm1', const Money(50000)), _payment('p2', 'm2', const Money(5000))],
    );

    final m1Balance = result.memberBalances.firstWhere((b) => b.memberId == 'm1');
    final m2Balance = result.memberBalances.firstWhere((b) => b.memberId == 'm2');
    expect(m1Balance.balance, const Money(40000));
    expect(m1Balance.status, BalanceStatus.willReceive);
    expect(m2Balance.balance, const Money(-5000));
    expect(m2Balance.status, BalanceStatus.needsToPay);
  });

  test('different expense amounts across multiple entries sum correctly', () {
    final m1 = _member('m1');
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [
        _expense('e1', const Money(10000)),
        _expense('e2', const Money(25000)),
        _expense('e3', const Money(5000)),
      ],
      payments: const [],
    );

    expect(result.totalExpense, const Money(40000));
  });

  test('zero meals recorded yields zero rate, not a division error', () {
    final m1 = _member('m1');
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: const [],
      expenses: [_expense('e1', const Money(10000))],
      payments: const [],
    );

    expect(result.totalMeals, 0);
    expect(result.hasNoMeals, isTrue);
    expect(result.mealRate, const Money.zero());
    expect(result.memberBalances.single.mealCost, const Money.zero());
  });

  test('zero expenses yields zero rate and zero meal cost, no NaN/infinity', () {
    final m1 = _member('m1');
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true, dinner: true)],
      expenses: const [],
      payments: [_payment('p1', 'm1', const Money(10000))],
    );

    expect(result.mealRate, const Money.zero());
    expect(result.memberBalances.single.mealCost, const Money.zero());
    expect(result.memberBalances.single.balance, const Money(10000));
    expect(result.memberBalances.single.status, BalanceStatus.willReceive);
  });

  test('member with no meals but who paid money is owed the full amount back', () {
    final m1 = _member('m1');
    final m2 = _member('m2');
    final result = engine.calculateMonth(
      members: [m1, m2],
      mealEntries: [_meal('m2', d1, lunch: true, dinner: true)],
      expenses: [_expense('e1', const Money(20000))],
      payments: [_payment('p1', 'm1', const Money(15000))],
    );

    final m1Balance = result.memberBalances.firstWhere((b) => b.memberId == 'm1');
    expect(m1Balance.mealCount, 0);
    expect(m1Balance.mealCost, const Money.zero());
    expect(m1Balance.balance, const Money(15000));
    expect(m1Balance.status, BalanceStatus.willReceive);
  });

  test('member with meals but who paid nothing owes their full meal cost', () {
    final m1 = _member('m1');
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, breakfast: true, lunch: true, dinner: true)],
      expenses: [_expense('e1', const Money(30000))],
      payments: const [],
    );

    final balance = result.memberBalances.single;
    expect(balance.paidAmount, const Money.zero());
    expect(balance.mealCost, const Money(30000));
    expect(balance.balance, const Money(-30000));
    expect(balance.status, BalanceStatus.needsToPay);
  });

  test('decimal meal rate rounds to the nearest poisha', () {
    final m1 = _member('m1');
    // ৳100 across 3 meals = 33.333... -> rounds to ৳33.33 (3333 poisha).
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, breakfast: true, lunch: true, dinner: true)],
      expenses: [_expense('e1', const Money(10000))],
      payments: const [],
    );

    expect(result.mealRate, const Money(3333));
  });

  test('rounding: member meal cost uses the rounded rate, not re-derived fractions', () {
    final m1 = _member('m1');
    final m2 = _member('m2');
    // ৳100 across 3 meals -> rate rounds to ৳33.33; member with 2 meals costs
    // 2 * 33.33 = ৳66.66, not a separately-rounded 2/3 share of ৳100.
    final result = engine.calculateMonth(
      members: [m1, m2],
      mealEntries: [
        _meal('m1', d1, breakfast: true),
        _meal('m2', d1, lunch: true, dinner: true),
      ],
      expenses: [_expense('e1', const Money(10000))],
      payments: const [],
    );

    final m2Balance = result.memberBalances.firstWhere((b) => b.memberId == 'm2');
    expect(m2Balance.mealCost, const Money(6666));
  });

  test('a member exactly settled has zero balance and Settled status', () {
    final m1 = _member('m1');
    final result = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [_expense('e1', const Money(10000))],
      payments: [_payment('p1', 'm1', const Money(10000))],
    );

    final balance = result.memberBalances.single;
    expect(balance.balance, const Money.zero());
    expect(balance.status, BalanceStatus.settled);
  });

  test('editing a meal entry (recomputing with an updated list) changes the result', () {
    final m1 = _member('m1');
    final before = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [_expense('e1', const Money(20000))],
      payments: const [],
    );
    expect(before.memberBalances.single.mealCount, 1);

    // Simulate the meal being edited to add dinner.
    final after = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true, dinner: true)],
      expenses: [_expense('e1', const Money(20000))],
      payments: const [],
    );
    expect(after.memberBalances.single.mealCount, 2);
    expect(after.totalMeals, 2);
  });

  test('editing an expense amount changes the meal rate', () {
    final m1 = _member('m1');
    final before = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [_expense('e1', const Money(10000))],
      payments: const [],
    );
    expect(before.mealRate, const Money(10000));

    final after = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [_expense('e1', const Money(25000))],
      payments: const [],
    );
    expect(after.mealRate, const Money(25000));
  });

  test('editing a payment amount changes the member balance', () {
    final m1 = _member('m1');
    final before = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [_expense('e1', const Money(10000))],
      payments: [_payment('p1', 'm1', const Money(5000))],
    );
    expect(before.memberBalances.single.balance, const Money(-5000));

    final after = engine.calculateMonth(
      members: [m1],
      mealEntries: [_meal('m1', d1, lunch: true)],
      expenses: [_expense('e1', const Money(10000))],
      payments: [_payment('p1', 'm1', const Money(20000))],
    );
    expect(after.memberBalances.single.balance, const Money(10000));
  });

  test('closed-month recomputation from the same frozen inputs is stable/idempotent', () {
    final m1 = _member('m1');
    final m2 = _member('m2');
    final inputs = (
      members: [m1, m2],
      mealEntries: [
        _meal('m1', d1, breakfast: true, lunch: true),
        _meal('m2', d1, dinner: true),
      ],
      expenses: [_expense('e1', const Money(15000))],
      payments: [_payment('p1', 'm1', const Money(10000)), _payment('p2', 'm2', const Money(5000))],
    );

    final first = engine.calculateMonth(
      members: inputs.members,
      mealEntries: inputs.mealEntries,
      expenses: inputs.expenses,
      payments: inputs.payments,
    );
    // Re-running the engine on a closed month's stored inputs (as a
    // "reopen and recompute" flow would) must reproduce the exact same
    // frozen numbers.
    final second = engine.calculateMonth(
      members: inputs.members,
      mealEntries: inputs.mealEntries,
      expenses: inputs.expenses,
      payments: inputs.payments,
    );

    expect(second.mealRate, first.mealRate);
    expect(second.totalMeals, first.totalMeals);
    for (var i = 0; i < first.memberBalances.length; i++) {
      expect(second.memberBalances[i].balance, first.memberBalances[i].balance);
    }
  });
}
