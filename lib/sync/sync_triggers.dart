import 'package:drift/drift.dart';

/// Every table mirrored to the cloud, parents before children. Pulled rows
/// are applied in this order and deletes in reverse, which keeps foreign
/// keys happy without relying solely on deferred checks.
///
/// A new table only syncs once it's added here. Columns need nothing extra,
/// but must be nullable or have a default: a row pushed by an older app
/// version won't carry a column that didn't exist yet.
const syncedTables = [
  'messes',
  'members',
  'mess_rules',
  'meal_entries',
  'expenses',
  'payments',
  'monthly_settlements',
  'monthly_settlement_members',
  'activity_logs',
];

/// Present in `sync_meta` only while cloud rows are being written locally,
/// so the triggers below don't queue them to be pushed straight back.
const applyingRemoteKey = 'applying_remote';

/// (Re)creates the change-capture triggers that feed `sync_outbox`.
///
/// Run on every open rather than once in a migration: a drift
/// `TableMigration` rebuilds a table from scratch, which silently drops any
/// trigger attached to it, so re-asserting them here keeps capture working
/// after any future schema change.
Future<void> installSyncTriggers(DatabaseConnectionUser db) async {
  const skipRemote =
      "NOT EXISTS (SELECT 1 FROM sync_meta WHERE key = '$applyingRemoteKey')";
  for (final table in syncedTables) {
    for (final (event, row, deleted) in [
      ('INSERT', 'NEW', 0),
      ('UPDATE', 'NEW', 0),
      ('DELETE', 'OLD', 1),
    ]) {
      await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS sync_capture_${table}_${event.toLowerCase()}
AFTER $event ON $table
WHEN $skipRemote
BEGIN
  INSERT OR REPLACE INTO sync_outbox (table_name, row_id, deleted)
  VALUES ('$table', $row.id, $deleted);
END''');
    }
  }
}
