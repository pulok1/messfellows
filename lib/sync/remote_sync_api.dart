import 'sync_record.dart';

/// The cloud side of sync, for one signed-in account. Behind an interface
/// so the sync engine can be tested against an in-memory fake.
abstract interface class RemoteSyncApi {
  /// Upserts the records (tombstones included) into the account's copy.
  Future<void> push(List<SyncRecord> records);

  /// Every record changed after [since] (all of them when null), oldest
  /// first, each carrying its server [SyncRecord.updatedAt].
  Future<List<SyncRecord>> pullSince(DateTime? since);

  /// Whether the account holds any live (non-deleted) rows.
  Future<bool> hasData();

  /// Marks every row in the account deleted — used when this device's data
  /// replaces the cloud copy, so other devices drop what's gone.
  Future<void> tombstoneAll();

  /// Fires whenever another device writes to the account.
  Stream<void> changes();
}

/// Thrown by a [RemoteSyncApi] when the server couldn't be reached at all,
/// as opposed to rejecting the request — shown as "offline" rather than as
/// a sync failure.
class SyncOfflineException implements Exception {
  final Object cause;

  const SyncOfflineException(this.cause);

  @override
  String toString() => 'SyncOfflineException: $cause';
}
