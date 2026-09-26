/// Truncates a [DateTime] to just its calendar date (midnight, local time).
/// Used everywhere a "day" is the unit of record — meal entries, expenses,
/// payments — so two timestamps on the same day always compare equal.
DateTime dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

/// The first moment of [year]/[month].
DateTime firstDayOfMonth(int year, int month) => DateTime(year, month, 1);

/// The first moment of the month after [year]/[month] — an exclusive upper
/// bound for "within this month" range queries.
DateTime firstDayOfNextMonth(int year, int month) {
  return month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
}

/// [date] moved by [days] calendar days, at midnight. Built from the
/// year/month/day fields rather than adding a 24-hour [Duration], which
/// lands an hour short of midnight — on the wrong day — across a
/// daylight-saving change.
DateTime addDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}

/// The latest day meals can be recorded for: tomorrow, so a member can be
/// marked off ahead of time, but not further out where a stray tap would
/// silently add meals to a day that hasn't happened.
DateTime latestMealDate() => addDays(DateTime.now(), 1);
