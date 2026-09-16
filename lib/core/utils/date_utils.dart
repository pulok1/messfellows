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
