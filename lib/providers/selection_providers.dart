import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';

/// The date currently shown on the Meals screen. Defaults to today so the
/// manager never has to pick a date just to log today's meals (section 15).
class SelectedMealDate extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void goToToday() => state = dateOnly(DateTime.now());
  void goToPreviousDay() => state = addDays(state, -1);

  /// No-op past [latestMealDate], so the next-day arrow can't wander into
  /// the future.
  void goToNextDay() {
    final next = addDays(state, 1);
    if (!next.isAfter(latestMealDate())) state = next;
  }

  void goTo(DateTime date) => state = dateOnly(date);
}

final selectedMealDateProvider = NotifierProvider<SelectedMealDate, DateTime>(
  SelectedMealDate.new,
);

/// The (year, month) currently shown on the Dashboard/Report screens.
typedef SelectedMonth = ({int year, int month});

class SelectedMonthNotifier extends Notifier<SelectedMonth> {
  @override
  SelectedMonth build() {
    final now = DateTime.now();
    return (year: now.year, month: now.month);
  }

  void goToPreviousMonth() {
    state = state.month == 1
        ? (year: state.year - 1, month: 12)
        : (year: state.year, month: state.month - 1);
  }

  void goToNextMonth() {
    state = state.month == 12
        ? (year: state.year + 1, month: 1)
        : (year: state.year, month: state.month + 1);
  }

  void goTo(int year, int month) => state = (year: year, month: month);
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, SelectedMonth>(
      SelectedMonthNotifier.new,
    );
