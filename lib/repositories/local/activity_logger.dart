import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../database/app_database.dart';
import '../../models/activity_type.dart';

/// Inserts one Activity Log row. A plain top-level function rather than a
/// repository method so every mutating repository can call it inline —
/// often inside its own transaction — instead of depending on another
/// repository just to record what it did.
Future<void> logActivity(
  AppDatabase db, {
  required String messId,
  required ActivityType type,
  String? memberId,
  int? amountMinorUnits,
  String? detail,
  int? year,
  int? month,
  int? count,
}) {
  return db
      .into(db.activityLogs)
      .insert(
        ActivityLogsCompanion.insert(
          id: IdGenerator.generate(),
          messId: messId,
          type: type,
          memberId: Value(memberId),
          amountMinorUnits: Value(amountMinorUnits),
          detail: Value(detail),
          year: Value(year),
          month: Value(month),
          count: Value(count),
          createdAt: DateTime.now(),
        ),
      );
}
