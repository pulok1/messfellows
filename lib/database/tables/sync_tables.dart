import 'package:drift/drift.dart';

/// Rows changed locally that the cloud hasn't seen yet. Never written by
/// Dart code on the normal write path: SQLite triggers on every synced table
/// (see `lib/sync/sync_triggers.dart`) add an entry whenever a row is
/// inserted, updated or deleted, so every repository, the backup import and
/// "delete all data" are captured without having to remember to call
/// anything.
///
/// One entry per row (the unique key below): a row edited five times while
/// offline is pushed once, as it is *now*. Re-inserting replaces the entry,
/// which hands it a fresh [seq] — the push step only clears the exact
/// entries it uploaded, so an edit landing mid-push isn't lost.
@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get rowTableName => text().named('table_name')();
  TextColumn get rowId => text()();
  // True when the row was deleted locally, so a tombstone is pushed.
  BoolColumn get deleted => boolean()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {rowTableName, rowId},
  ];
}

/// Small key/value store for sync bookkeeping (the pull cursor, which
/// account this device's data is linked to). Also holds the
/// `applying_remote` marker the triggers check, so rows written *from* the
/// cloud aren't echoed straight back into [SyncOutbox].
@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
