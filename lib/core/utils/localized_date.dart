import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware date formatting, so a switch to Bangla also translates
/// month/weekday names instead of leaving them hardcoded in English (as
/// several screens used to do with their own `_monthName`/`_weekdayLabel`
/// arrays). Requires `initializeDateFormatting` to have run for the active
/// locale — see `main.dart`.
String _tag(BuildContext context) => Localizations.localeOf(context).toString();

/// "16 September 2026"
String formatFullDate(BuildContext context, DateTime date) {
  return DateFormat('d MMMM y', _tag(context)).format(date);
}

/// "16 Sep 2026"
String formatShortDate(BuildContext context, DateTime date) {
  return DateFormat('d MMM y', _tag(context)).format(date);
}

/// "September 2026"
String formatMonthYear(BuildContext context, int year, int month) {
  return DateFormat.yMMMM(_tag(context)).format(DateTime(year, month));
}

/// "Monday"
String formatWeekday(BuildContext context, DateTime date) {
  return DateFormat.EEEE(_tag(context)).format(date);
}

/// "3:40 PM"
String formatTimeOfDay(BuildContext context, DateTime date) {
  return DateFormat.jm(_tag(context)).format(date);
}
