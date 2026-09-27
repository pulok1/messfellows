import 'package:flutter/widgets.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/activity_log_entry.dart';
import '../../models/meal_entry.dart';
import '../../models/meal_slot.dart';
import '../reports/summary_text.dart';
import 'meal_slot_ui.dart';

/// One member's meals for [year]/[month], day by day, as share-ready text —
/// so a member can check their own count line by line instead of taking the
/// total on trust. Days changed after they'd passed are marked ✏️ and the
/// changes (with reasons) are listed at the end.
///
/// Lists every day of the month up to [today] (all of them for a past
/// month), including days with nothing eaten, so no day is hidden.
String buildMealStatement({
  required BuildContext context,
  required String messName,
  required String memberName,
  required int year,
  required int month,
  required List<MealEntry> memberMeals,
  required List<ActivityLogEntry> memberLateChanges,
  required DateTime today,
}) {
  final l10n = AppLocalizations.of(context);
  final byDay = {for (final meal in memberMeals) dateOnly(meal.date): meal};
  final changedDays = {
    for (final change in memberLateChanges) dateOnly(change.mealDate!),
  };
  final lastOfMonth = addDays(firstDayOfNextMonth(year, month), -1);
  final end = dateOnly(today).isBefore(lastOfMonth)
      ? dateOnly(today)
      : lastOfMonth;

  final buffer = StringBuffer()
    ..writeln('🍚 $messName')
    ..writeln(l10n.mealStatementTitle(memberName))
    ..writeln(formatMonthYear(context, year, month))
    ..writeln();

  var total = 0;
  for (
    var day = firstDayOfMonth(year, month);
    !day.isAfter(end);
    day = addDays(day, 1)
  ) {
    final counts = byDay[day]?.counts ?? noMeals;
    final eaten = [
      for (final slot in MealSlot.values)
        if (slot.countIn(counts) case final count when count > 0)
          count == 1
              ? mealSlotLabel(l10n, slot)
              : '${mealSlotLabel(l10n, slot)} ×$count',
    ];
    final dayTotal = byDay[day]?.totalMeals ?? 0;
    total += dayTotal;
    buffer.writeln(
      '${formatDayMonth(context, day)}: '
      '${eaten.isEmpty ? '—' : '${eaten.join(', ')} ($dayTotal)'}'
      '${changedDays.contains(day) ? ' ✏️' : ''}',
    );
  }

  buffer
    ..writeln()
    ..writeln(l10n.totalMealsLine('$total'));

  if (memberLateChanges.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(l10n.mealStatementEditedNote);
    for (final change in memberLateChanges) {
      buffer.writeln(describeLateMealChange(context, change, const {}));
    }
  }

  return buffer.toString().trimRight();
}
