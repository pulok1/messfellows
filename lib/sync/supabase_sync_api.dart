import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_sync_api.dart';
import 'sync_record.dart';

/// [RemoteSyncApi] over the `sync_records` table — see
/// supabase/migrations/ for its shape and row-level security.
class SupabaseSyncApi implements RemoteSyncApi {
  final SupabaseClient _client;
  final String _userId;

  SupabaseSyncApi(this._client, this._userId);

  static const _table = 'sync_records';

  // PostgREST caps a response at 1000 rows by default.
  static const _pageSize = 1000;

  @override
  Future<void> push(List<SyncRecord> records) => _guard(() async {
    if (records.isEmpty) return;
    await _client.from(_table).upsert([
      for (final r in records)
        {
          'user_id': _userId,
          'table_name': r.table,
          'row_id': r.rowId,
          'data': r.deleted ? null : r.data,
          'deleted': r.deleted,
        },
    ], onConflict: 'user_id,table_name,row_id');
  });

  @override
  Future<List<SyncRecord>> pullSince(DateTime? since) => _guard(() async {
    final records = <SyncRecord>[];
    Map<String, dynamic>? last;
    while (true) {
      var query = _client
          .from(_table)
          .select('table_name, row_id, data, deleted, updated_at')
          .eq('user_id', _userId);
      if (since != null) {
        query = query.gt('updated_at', since.toUtc().toIso8601String());
      }
      if (last != null) {
        // Keyset paging on (updated_at, table_name, row_id): unlike offset
        // paging, a row edited mid-pull can't shift another row out of the
        // window. Values are quoted because timestamps contain ':' and '.'.
        final ts = '"${last['updated_at']}"';
        final table = '"${last['table_name']}"';
        final row = '"${last['row_id']}"';
        query = query.or(
          'updated_at.gt.$ts,'
          'and(updated_at.eq.$ts,table_name.gt.$table),'
          'and(updated_at.eq.$ts,table_name.eq.$table,row_id.gt.$row)',
        );
      }
      final page = await query
          .order('updated_at', ascending: true)
          .order('table_name', ascending: true)
          .order('row_id', ascending: true)
          .limit(_pageSize);
      for (final r in page) {
        records.add(
          SyncRecord(
            table: r['table_name'] as String,
            rowId: r['row_id'] as String,
            data: (r['data'] as Map?)?.cast<String, Object?>(),
            deleted: r['deleted'] as bool,
            updatedAt: DateTime.parse(r['updated_at'] as String),
          ),
        );
      }
      if (page.length < _pageSize) return records;
      last = page.last;
    }
  });

  @override
  Future<bool> hasData() => _guard(() async {
    final rows = await _client
        .from(_table)
        .select('row_id')
        .eq('user_id', _userId)
        .eq('deleted', false)
        .limit(1);
    return rows.isNotEmpty;
  });

  @override
  Future<void> tombstoneAll() => _guard(() async {
    await _client
        .from(_table)
        .update({'deleted': true, 'data': null})
        .eq('user_id', _userId)
        .eq('deleted', false);
  });

  @override
  Stream<void> changes() {
    late final RealtimeChannel channel;
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () {
        channel = _client
            .channel('sync_records:$_userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: _table,
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: _userId,
              ),
              callback: (_) => controller.add(null),
            )
            .subscribe();
      },
      onCancel: () => _client.removeChannel(channel),
    );
    return controller.stream;
  }

  /// Turns "couldn't reach the server" failures into [SyncOfflineException]
  /// so they read as offline, not as errors.
  static Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on SocketException catch (e) {
      throw SyncOfflineException(e);
    } on http.ClientException catch (e) {
      throw SyncOfflineException(e);
    } on TimeoutException catch (e) {
      throw SyncOfflineException(e);
    } on AuthRetryableFetchException catch (e) {
      throw SyncOfflineException(e);
    }
  }
}
