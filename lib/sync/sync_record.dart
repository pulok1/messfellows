/// One row as it travels between this device and the cloud: the raw SQLite
/// column values (keyed by column name), or a tombstone when [deleted].
///
/// Values are kept exactly as SQLite stores them (dates as unix seconds,
/// booleans as 0/1) so a row round-trips byte-for-byte without any
/// per-table mapping code.
class SyncRecord {
  final String table;
  final String rowId;
  final Map<String, Object?>? data;
  final bool deleted;

  /// Server-assigned time of the last write; null for records about to be
  /// pushed. Drives the pull cursor.
  final DateTime? updatedAt;

  const SyncRecord({
    required this.table,
    required this.rowId,
    required this.data,
    required this.deleted,
    this.updatedAt,
  });

  const SyncRecord.tombstone(this.table, this.rowId, {this.updatedAt})
    : data = null,
      deleted = true;

  @override
  String toString() =>
      'SyncRecord($table/$rowId${deleted ? ', deleted' : ''})';
}

/// A queued local change ready to push, remembering which outbox entry it
/// came from so only that exact entry is cleared afterwards.
class PendingChange {
  final int seq;
  final SyncRecord record;

  const PendingChange(this.seq, this.record);
}
