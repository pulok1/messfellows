import '../models/meal_entry.dart';

abstract interface class MealRepository {
  /// One row per active-that-day member for [date] (date-only, time
  /// truncated) — the source for the daily meal tracker screen.
  Stream<List<MealEntry>> watchMealsForDate(String messId, DateTime date);

  /// Every meal entry within [year]/[month] — the source for monthly totals
  /// and reports.
  Stream<List<MealEntry>> watchMealsForMonth(String messId, int year, int month);

  Future<MealEntry?> getMealEntry(String messId, String memberId, DateTime date);

  /// Creates or updates the single meal record for [memberId] on [date].
  /// Only the meals explicitly passed are changed; omitted ones keep their
  /// current value (or default to false on first creation).
  Future<void> setMeal({
    required String messId,
    required String memberId,
    required DateTime date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  });
}
