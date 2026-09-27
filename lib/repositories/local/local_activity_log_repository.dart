import 'package:drift/drift.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../models/activity_log_entry.dart';
import '../../models/activity_type.dart';
import '../activity_log_repository.dart';

class LocalActivityLogRepository implements ActivityLogRepository {
  final AppDatabase _db;

  LocalActivityLogRepository(this._db);

  ActivityLogEntry _toModel(ActivityLogRow row) => ActivityLogEntry(
    id: row.id,
    messId: row.messId,
    type: row.type,
    memberId: row.memberId,
    amount: row.amountMinorUnits == null ? null : Money(row.amountMinorUnits!),
    detail: row.detail,
    year: row.year,
    month: row.month,
    count: row.count,
    mealDate: row.mealDate,
    mealSlot: row.mealSlot,
    previousCount: row.previousCount,
    createdAt: row.createdAt,
  );

  @override
  Stream<List<ActivityLogEntry>> watchLog(String messId) {
    final query = _db.select(_db.activityLogs)
      ..where((t) => t.messId.equals(messId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<ActivityLogEntry>> watchMealChangesForDate(
    String messId,
    DateTime date,
  ) {
    final query = _db.select(_db.activityLogs)
      ..where(
        (t) =>
            t.messId.equals(messId) &
            t.type.equalsValue(ActivityType.mealChangedLater) &
            t.mealDate.equals(dateOnly(date)),
      )
      // rowId breaks ties between changes saved in the same millisecond
      // (one bulk write logs several), keeping them in the order written.
      ..orderBy([
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.rowId),
      ]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<ActivityLogEntry>> watchMealChangesForMonth(
    String messId,
    int year,
    int month,
  ) {
    final query = _db.select(_db.activityLogs)
      ..where(
        (t) =>
            t.messId.equals(messId) &
            t.type.equalsValue(ActivityType.mealChangedLater) &
            t.mealDate.isBiggerOrEqualValue(firstDayOfMonth(year, month)) &
            t.mealDate.isSmallerThanValue(firstDayOfNextMonth(year, month)),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.mealDate),
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.rowId),
      ]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }
}
