import '../../l10n/gen/app_localizations.dart';
import '../../models/meal_slot.dart';

/// The localized name of [slot] ("Lunch").
String mealSlotLabel(AppLocalizations l10n, MealSlot slot) => switch (slot) {
  MealSlot.breakfast => l10n.breakfastLabel,
  MealSlot.lunch => l10n.lunchLabel,
  MealSlot.dinner => l10n.dinnerLabel,
};
