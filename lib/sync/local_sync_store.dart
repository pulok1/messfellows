import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'sync_record.dart';
import 'sync_triggers.dart';

/// The SQLite side of cloud sync: reads what's queued in `sync_outbox` and
/// writes rows pulled from the cloud. Talks raw SQL over [syncedTables]
/// rather than per-table drift code, so a new column syncs with no changes
/// here.
class LocalSyncStore {
  final AppDatabase _db;

  LocalSyncStore(this._db);

  static const pullCursorKey = 'pull_cursor';
  static const linkedUserKey = 'linked_user_id';

  // ---- Bookkeeping -------------------------------------------------------

  Future<String?> readMeta(String key) async {
    final row = await (_db.select(
      _db.syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeMeta(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.syncMeta)..where((t) => t.key.equals(key))).go();
    } else {
      await _db
          .into(_db.syncMeta)
          .insertOnConflictUpdate(SyncMetaCompanion.insert(key: key, value: value));
    }
  }

  /// Whether this device has a mess at all — an empty device can simply
  /// adopt the cloud copy on sign-in, with nothing to ask about.
  Future<bool> hasLocalData() async {
    final row = await _db
        .customSelect('SELECT EXISTS (SELECT 1 FROM messes) AS present')
        .getSingle();
    return row.read<int>('present') == 1;
  }

  // ---- Push --------------------------------------------------------------

  Future<int> pendingCount() async {
    final count = _db.syncOutbox.seq.count();
    final row = await (_db.selectOnly(_db.syncOutbox)..addColumns([count]))
        .getSingle();
    return row.read(count) ?? 0;
  }

  /// The oldest [limit] queued changes, each carrying the row's *current*
  /// contents (or a tombstone if it has since been deleted).
  Future<List<PendingChange>> pendingChanges({int limit = 500}) async {
    final entries = await (_db.select(_db.syncOutbox)
          ..orderBy([(t) => OrderingTerm.asc(t.seq)])
          ..limit(limit))
        .get();
    final changes = <PendingChange>[];
    for (final entry in entries) {
      final data = entry.deleted
          ? null
          : await _readRow(entry.rowTableName, entry.rowId);
      changes.add(
        PendingChange(
          entry.seq,
          data == null
              ? SyncRecord.tombstone(entry.rowTableName, entry.rowId)
              : SyncRecord(
                  table: entry.rowTableName,
                  rowId: entry.rowId,
                  data: data,
                  deleted: false,
                ),
        ),
      );
    }
    return changes;
  }

  /// Clears exactly the entries that were uploaded. An entry re-queued
  /// mid-push got a new seq, so it stays and goes up next time.
  Future<void> markPushed(Iterable<int> seqs) async {
    final list = seqs.toList();
    if (list.isEmpty) return;
    await (_db.delete(_db.syncOutbox)..where((t) => t.seq.isIn(list))).go();
  }

  /// Queues every existing row, replacing whatever was queued — used when
  /// this device's data becomes the account's copy for the first time.
  Future<void> queueEverything() async {
    await _db.transaction(() async {
      await _db.delete(_db.syncOutbox).go();
      for (final table in syncedTables) {
        await _db.customStatement(
          'INSERT OR REPLACE INTO sync_outbox (table_name, row_id, deleted) '
          "SELECT '$table', id, 0 FROM $table",
        );
      }
    });
  }

  /// Deletes every synced row *without* queueing tombstones (the cloud copy
  /// is about to replace it), and forgets anything queued.
  Future<void> wipeLocalData() async {
    await _db.transaction(() async {
      await _setApplyingRemote(true);
      for (final table in syncedTables.reversed) {
        await _db.customStatement('DELETE FROM $table');
      }
      await _db.delete(_db.syncOutbox).go();
      await _setApplyingRemote(false);
    });
    _notify(syncedTables);
  }

  // ---- Pull --------------------------------------------------------------

  /// Writes cloud rows into SQLite in one transaction.
  ///
  /// - A row with a local change still waiting to be pushed is left alone:
  ///   the local edit is newer and will overwrite the cloud copy.
  /// - Two rows with different ids but the same natural key (two phones
  ///   both recording Alice's meals for the same day while offline) can't
  ///   both exist. The smaller id wins on every device, so they converge;
  ///   the loser is deleted everywhere.
  /// - Anything left pointing at a missing parent afterwards (e.g. a
  ///   phone added an expense while another reset all data) is removed.
  ///
  /// Returns how many local rows actually changed.
  Future<int> applyRemote(List<SyncRecord> records) async {
    if (records.isEmpty) return 0;
    final byTable = groupBy(records, (SyncRecord r) => r.table);
    final touched = <String>{};
    var changed = 0;

    await _db.transaction(() async {
      // Parents and children may arrive in any order; check the foreign
      // keys once, at commit.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      final pending = await _pendingKeys();
      await _setApplyingRemote(true);

      for (final table in syncedTables) {
        for (final record in byTable[table] ?? const <SyncRecord>[]) {
          if (record.deleted || pending.contains((table, record.rowId))) {
            continue;
          }
          if (await _upsert(table, record)) {
            changed++;
            touched.add(table);
          }
        }
      }
      for (final table in syncedTables.reversed) {
        for (final record in byTable[table] ?? const <SyncRecord>[]) {
          if (!record.deleted || pending.contains((table, record.rowId))) {
            continue;
          }
          final removed = await _db.customUpdate(
            'DELETE FROM $table WHERE id = ?',
            variables: [Variable.withString(record.rowId)],
          );
          if (removed > 0) {
            changed += removed;
            touched.add(table);
          }
        }
      }

      await _setApplyingRemote(false);
      final orphans = await _removeOrphans();
      changed += orphans.length;
      touched.addAll(orphans);
    });

    _notify(touched);
    return changed;
  }

  /// Returns true if the local row was inserted or changed.
  Future<bool> _upsert(String table, SyncRecord record) async {
    final info = _tableInfo(table);
    final columns = info.$columns.map((c) => c.$name).toSet();
    // Ignore columns this app version doesn't know (pushed by a newer one).
    final data = {
      for (final entry in record.data!.entries)
        if (columns.contains(entry.key)) entry.key: entry.value,
    }..['id'] = record.rowId;

    final existing = await _readRow(table, record.rowId);
    if (existing != null &&
        data.entries.every((e) => existing[e.key] == e.value)) {
      return false;
    }

    if (!await _resolveUniqueConflicts(info, data)) return false;

    final names = data.keys.toList();
    final updates = names
        .where((n) => n != 'id')
        .map((n) => '"$n" = excluded."$n"')
        .join(', ');
    await _db.customStatement(
      'INSERT INTO $table (${names.map((n) => '"$n"').join(', ')}) '
      'VALUES (${List.filled(names.length, '?').join(', ')}) '
      'ON CONFLICT (id) DO ${updates.isEmpty ? 'NOTHING' : 'UPDATE SET $updates'}',
      [for (final n in names) data[n]],
    );
    return true;
  }

  /// Settles a clash between [data] and a different local row on one of
  /// the table's unique keys. Returns false if the incoming row lost and
  /// shouldn't be written.
  Future<bool> _resolveUniqueConflicts(
    TableInfo info,
    Map<String, Object?> data,
  ) async {
    final table = info.actualTableName;
    final incomingId = data['id']! as String;
    for (final key in info.uniqueKeys) {
      final names = key.map((c) => c.$name).toList();
      if (!names.every(data.containsKey)) continue;
      final rows = await _db
          .customSelect(
            'SELECT id FROM $table WHERE '
            '${names.map((n) => '"$n" IS ?').join(' AND ')} AND id <> ?',
            variables: [
              for (final n in names) _variable(data[n]),
              Variable.withString(incomingId),
            ],
          )
          .get();
      for (final row in rows) {
        final localId = row.read<String>('id');
        if (incomingId.compareTo(localId) < 0) {
          // Incoming wins: drop the local row here and in the cloud.
          await _db.customStatement('DELETE FROM $table WHERE id = ?', [
            localId,
          ]);
          await _queueTombstone(table, localId);
        } else {
          // Local wins: keep it and delete the incoming one in the cloud.
          await _queueTombstone(table, incomingId);
          return false;
        }
      }
    }
    return true;
  }

  /// Deletes rows whose parent is gone, queueing tombstones for them (the
  /// triggers are live again by now). Repeats, since removing a member can
  /// orphan its meals in turn. Returns the tables touched.
  Future<List<String>> _removeOrphans() async {
    final touched = <String>[];
    for (var pass = 0; pass < syncedTables.length; pass++) {
      final violations = await _db
          .customSelect('PRAGMA foreign_key_check')
          .get();
      if (violations.isEmpty) break;
      for (final v in violations) {
        final table = v.read<String>('table');
        final rowid = v.read<int>('rowid');
        await _db.customStatement('DELETE FROM $table WHERE rowid = ?', [
          rowid,
        ]);
        touched.add(table);
      }
    }
    return touched;
  }

  // ---- Helpers -----------------------------------------------------------

  Future<Map<String, Object?>?> _readRow(String table, String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM $table WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null ? null : Map.of(row.data);
  }

  Future<Set<(String, String)>> _pendingKeys() async {
    final rows = await _db.select(_db.syncOutbox).get();
    return {for (final r in rows) (r.rowTableName, r.rowId)};
  }

  Future<void> _queueTombstone(String table, String id) =>
      _db.customStatement(
        'INSERT OR REPLACE INTO sync_outbox (table_name, row_id, deleted) '
        'VALUES (?, ?, 1)',
        [table, id],
      );

  Future<void> _setApplyingRemote(bool on) => on
      ? _db.customStatement(
          'INSERT OR REPLACE INTO sync_meta (key, value) VALUES (?, ?)',
          [applyingRemoteKey, '1'],
        )
      : _db.customStatement('DELETE FROM sync_meta WHERE key = ?', [
          applyingRemoteKey,
        ]);

  TableInfo _tableInfo(String name) =>
      _db.allTables.firstWhere((t) => t.actualTableName == name);

  /// Raw SQL writes bypass drift's change tracking, so streams watching
  /// these tables (every screen) have to be told explicitly.
  void _notify(Iterable<String> tables) {
    final infos = {for (final t in tables.toSet()) _tableInfo(t)};
    if (infos.isNotEmpty) _db.markTablesUpdated(infos);
  }

  static Variable _variable(Object? value) => switch (value) {
    null => const Variable(null),
    final int v => Variable.withInt(v),
    final double v => Variable.withReal(v),
    final bool v => Variable.withBool(v),
    final String v => Variable.withString(v),
    final Object v => Variable(v),
  };
}
