import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/utils/meal_gaps.dart';
import 'package:messfellows/models/meal_entry.dart';

MealEntry _meal(DateTime date, {int lunch = 1}) {
  return MealEntry(
    id: date.toIso8601String(),
    messId: 'mess-1',
    memberId: 'm1',
    date: date,
    breakfast: 0,
    lunch: lunch,
    dinner: 0,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  test('finds days between the first recorded meal and yesterday', () {
    final gaps = unrecordedMealDays(
      [
        _meal(DateTime(2026, 9, 3)),
        _meal(DateTime(2026, 9, 5)),
        _meal(DateTime(2026, 9, 6, 14)), // time of day is ignored
        _meal(DateTime(2026, 9, 7), lunch: 0), // a row with nothing eaten
      ],
      year: 2026,
      month: 9,
      today: DateTime(2026, 9, 9),
    );

    // Not the 1st/2nd (before the mess started), not the 9th (today).
    expect(gaps, [
      DateTime(2026, 9, 4),
      DateTime(2026, 9, 7),
      DateTime(2026, 9, 8),
    ]);
  });

  test('a past month is checked through its last day', () {
    final gaps = unrecordedMealDays(
      [_meal(DateTime(2026, 2, 26)), _meal(DateTime(2026, 2, 28))],
      year: 2026,
      month: 2,
      today: DateTime(2026, 9, 9),
    );

    expect(gaps, [DateTime(2026, 2, 27)]);
  });

  test('an empty month reports no gaps', () {
    expect(
      unrecordedMealDays(
        const [],
        year: 2026,
        month: 9,
        today: DateTime(2026, 9, 9),
      ),
      isEmpty,
    );
  });
}
