import '../models/activity_log_entry.dart';

/// Read-only from the outside: every mutation elsewhere in the app writes
/// its own log entry directly (see repositories/local/activity_logger.dart)
/// rather than going through a `record()` method here, so a write can share
/// the same transaction as the change it's logging.
abstract interface class ActivityLogRepository {
  Stream<List<ActivityLogEntry>> watchLog(String messId);

  /// Every logged change to [date]'s meals (made after that day had
  /// passed), oldest first — the history behind a row's "Edited later" tag.
  Stream<List<ActivityLogEntry>> watchMealChangesForDate(
    String messId,
    DateTime date,
  );

  /// Every logged late change to a meal on a day within [year]/[month],
  /// ordered by that day and then by when the change was made — the list
  /// the shared monthly summary and meal statements disclose.
  Stream<List<ActivityLogEntry>> watchMealChangesForMonth(
    String messId,
    int year,
    int month,
  );
}
