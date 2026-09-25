import 'package:drift/drift.dart';

import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../models/activity_log_entry.dart';
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
    createdAt: row.createdAt,
  );

  @override
  Stream<List<ActivityLogEntry>> watchLog(String messId) {
    final query = _db.select(_db.activityLogs)
      ..where((t) => t.messId.equals(messId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }
}
