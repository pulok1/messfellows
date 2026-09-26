import 'meal_entry.dart';
import 'mess.dart';

/// The three meals a day can hold, so code that treats them alike —
/// mark-all, whole-day toggles, copying a day — says it once.
enum MealSlot {
  breakfast,
  lunch,
  dinner;

  int countIn(MealCounts counts) => switch (this) {
    MealSlot.breakfast => counts.breakfast,
    MealSlot.lunch => counts.lunch,
    MealSlot.dinner => counts.dinner,
  };

  /// [counts] with this slot replaced by [value].
  MealCounts setIn(MealCounts counts, int value) => switch (this) {
    MealSlot.breakfast => (
      breakfast: value,
      lunch: counts.lunch,
      dinner: counts.dinner,
    ),
    MealSlot.lunch => (
      breakfast: counts.breakfast,
      lunch: value,
      dinner: counts.dinner,
    ),
    MealSlot.dinner => (
      breakfast: counts.breakfast,
      lunch: counts.lunch,
      dinner: value,
    ),
  };

  bool isTrackedBy(Mess mess) => switch (this) {
    MealSlot.breakfast => mess.trackBreakfast,
    MealSlot.lunch => mess.trackLunch,
    MealSlot.dinner => mess.trackDinner,
  };
}
