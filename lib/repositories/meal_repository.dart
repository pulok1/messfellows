import '../core/errors/app_exception.dart';
import '../models/meal_entry.dart';

/// One member's breakfast/lunch/dinner counts for a day — the unit a bulk
/// write (and its undo) works in.
typedef MealCounts = ({int breakfast, int lunch, int dinner});

abstract interface class MealRepository {
  /// One row per active-that-day member for [date] (date-only, time
  /// truncated) — the source for the daily meal tracker screen.
  Stream<List<MealEntry>> watchMealsForDate(String messId, DateTime date);

  /// Every meal entry within [year]/[month] — the source for monthly totals
  /// and reports.
  Stream<List<MealEntry>> watchMealsForMonth(
    String messId,
    int year,
    int month,
  );

  Future<MealEntry?> getMealEntry(
    String messId,
    String memberId,
    DateTime date,
  );

  /// Creates or updates the single meal record for [memberId] on [date].
  /// Only the meals explicitly passed are changed; omitted ones keep their
  /// current value (or default to 0 on first creation). A count above 1
  /// records an extra/guest meal in that slot.
  Future<void> setMeal({
    required String messId,
    required String memberId,
    required DateTime date,
    int? breakfast,
    int? lunch,
    int? dinner,
  });

  /// Sets every slot for each member in [countsByMember] on [date], all in
  /// one transaction — so a mark-all, a copied day or an undo either lands
  /// completely or not at all, never leaving the day half-changed.
  ///
  /// Throws [MonthClosedException] if [date]'s month has been closed.
  Future<void> setMealsForDate({
    required String messId,
    required DateTime date,
    required Map<String, MealCounts> countsByMember,
  });
}
