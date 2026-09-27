import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';

/// The reason given for editing each past day this session, keyed by date.
/// A past day's meals stay locked on the Meals screen until a reason is
/// entered here; every change made while it's unlocked is logged with it.
/// Kept in memory only, so every past day starts locked again next launch.
class PastDayEditReasons extends Notifier<Map<DateTime, String>> {
  @override
  Map<DateTime, String> build() => const {};

  void unlock(DateTime date, String reason) {
    state = {...state, dateOnly(date): reason.trim()};
  }

  void lock(DateTime date) {
    state = {...state}..remove(dateOnly(date));
  }
}

final pastDayEditReasonsProvider =
    NotifierProvider<PastDayEditReasons, Map<DateTime, String>>(
      PastDayEditReasons.new,
    );
