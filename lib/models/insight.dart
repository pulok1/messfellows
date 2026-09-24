import '../core/utils/money.dart';

/// A short, data-driven observation about the current month, surfaced on the
/// Dashboard. Each subtype carries only the facts; the UI turns them into
/// localized copy. Produced by [InsightEngine][../core/services/insight_engine.dart].
sealed class Insight {
  const Insight();
}

/// It's past lunchtime and nobody has a meal marked for today yet.
class MealsNotMarkedToday extends Insight {
  const MealsNotMarkedToday();
}

/// The mess is still eating but no bazar has been logged for [days] days.
class NoRecentBazar extends Insight {
  final int days;

  const NoRecentBazar(this.days);
}

/// This month's meal rate so far differs from last month's final rate by
/// [percent] (positive = more expensive).
class MealRateChange extends Insight {
  final int percent;
  final Money previousRate;

  const MealRateChange({required this.percent, required this.previousRate});
}

/// Active members who've eaten this month but haven't paid for any bazar.
class MembersWithoutBazar extends Insight {
  final List<String> memberNames;

  const MembersWithoutBazar(this.memberNames);
}

/// Where this month's bazar total will land if spending keeps its pace.
class BazarProjection extends Insight {
  final Money projectedTotal;

  const BazarProjection(this.projectedTotal);
}
