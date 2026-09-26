import '../../models/meal_entry.dart';
import 'date_utils.dart';

/// Days in [year]/[month] with no meals recorded at all — the likeliest
/// sign of a day someone forgot to fill in, which would quietly lower the
/// month's meal count and raise everyone's meal rate.
///
/// Only looks from the month's first recorded meal (so a mess that started
/// using the app mid-month isn't told its earlier days are missing) up to
/// yesterday (today may simply not be marked yet). A month with no meals
/// at all returns nothing: there's no pattern to measure gaps against.
List<DateTime> unrecordedMealDays(
  Iterable<MealEntry> monthMeals, {
  required int year,
  required int month,
  required DateTime today,
}) {
  final recorded = {
    for (final meal in monthMeals)
      if (meal.totalMeals > 0) dateOnly(meal.date),
  };
  if (recorded.isEmpty) return const [];

  final start = recorded.reduce((a, b) => a.isBefore(b) ? a : b);
  final lastOfMonth = addDays(firstDayOfNextMonth(year, month), -1);
  final yesterday = addDays(today, -1);
  final end = yesterday.isBefore(lastOfMonth) ? yesterday : lastOfMonth;

  return [
    for (var day = start; !day.isAfter(end); day = addDays(day, 1))
      if (!recorded.contains(day)) day,
  ];
}
