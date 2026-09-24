import '../../models/expense.dart';
import '../../models/insight.dart';
import '../../models/meal_entry.dart';
import '../../models/member.dart';
import '../../models/month_calculation_result.dart';
import '../utils/money.dart';

/// Pure domain service that turns the current month's records into a short,
/// prioritized list of [Insight]s for the Dashboard. Like
/// [CalculationEngine][calculation_engine.dart] it has no Flutter/Drift/
/// Riverpod dependency, and takes [now] explicitly so it's testable.
///
/// Every rule has a threshold so the card only speaks up when there's
/// something worth saying — early in the month, or with little data, most
/// insights stay quiet rather than reporting noise.
class InsightEngine {
  const InsightEngine();

  /// From this hour on, an unmarked day is worth a nudge.
  static const markMealsReminderHour = 14;

  /// Days without a bazar entry before it's worth mentioning.
  static const staleBazarDays = 3;

  /// Minimum meal-rate swing, and how many meals this month must have before
  /// the rate is stable enough to compare with last month.
  static const rateChangePercent = 5;
  static const rateChangeMinMeals = 15;

  /// Day of the month from which "hasn't done bazar" is fair to point out.
  static const bazarFairnessFromDay = 10;

  /// Day of the month from which there's enough spending to extrapolate.
  static const projectionFromDay = 7;

  /// Returns insights for the month containing [now], most useful first.
  List<Insight> build({
    required DateTime now,
    required MonthCalculationResult current,
    MonthCalculationResult? previous,
    required List<MealEntry> meals,
    required List<Expense> expenses,
    required List<Member> activeMembers,
  }) {
    if (activeMembers.isEmpty) return const [];

    final today = _dateOnly(now);
    final eatenMeals = meals.where((m) => m.totalMeals > 0).toList();

    return [
      if (now.hour >= markMealsReminderHour &&
          !eatenMeals.any((m) => _dateOnly(m.date) == today))
        const MealsNotMarkedToday(),
      ?_noRecentBazar(today, eatenMeals, expenses),
      ?_mealRateChange(current, previous),
      ?_membersWithoutBazar(today, eatenMeals, expenses, activeMembers),
      ?_bazarProjection(today, current),
    ];
  }

  NoRecentBazar? _noRecentBazar(
    DateTime today,
    List<MealEntry> eatenMeals,
    List<Expense> expenses,
  ) {
    if (expenses.isEmpty) return null;
    final lastBazar = expenses
        .map((e) => _dateOnly(e.date))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final days = today.difference(lastBazar).inDays;
    final stillEating = eatenMeals.any(
      (m) => _dateOnly(m.date).isAfter(lastBazar),
    );
    return days >= staleBazarDays && stillEating ? NoRecentBazar(days) : null;
  }

  MealRateChange? _mealRateChange(
    MonthCalculationResult current,
    MonthCalculationResult? previous,
  ) {
    if (previous == null || previous.hasNoMeals) return null;
    if (current.totalMeals < rateChangeMinMeals) return null;
    final before = previous.mealRate.minorUnits;
    if (before == 0) return null;
    final percent = ((current.mealRate.minorUnits - before) * 100 / before)
        .round();
    return percent.abs() >= rateChangePercent
        ? MealRateChange(percent: percent, previousRate: previous.mealRate)
        : null;
  }

  MembersWithoutBazar? _membersWithoutBazar(
    DateTime today,
    List<MealEntry> eatenMeals,
    List<Expense> expenses,
    List<Member> activeMembers,
  ) {
    if (today.day < bazarFairnessFromDay || expenses.isEmpty) return null;
    final eaters = {for (final m in eatenMeals) m.memberId};
    final buyers = {for (final e in expenses) e.paidByMemberId};
    final names = [
      for (final member in activeMembers)
        if (eaters.contains(member.id) && !buyers.contains(member.id))
          member.name,
    ];
    return names.isEmpty ? null : MembersWithoutBazar(names);
  }

  BazarProjection? _bazarProjection(
    DateTime today,
    MonthCalculationResult current,
  ) {
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    if (today.day < projectionFromDay || today.day >= daysInMonth) return null;
    if (current.totalExpense.isZero) return null;
    final projected = current.totalExpense.minorUnits * daysInMonth / today.day;
    // Rounded to the nearest 100 (in major units): it's an estimate, and
    // false precision would suggest otherwise.
    const step = 100 * 100;
    return BazarProjection(Money((projected / step).round() * step));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
