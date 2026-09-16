import '../models/mess.dart';

/// Abstraction over where mess data lives. The UI and providers depend only
/// on this interface, never on Drift/SQLite directly, so a future
/// `SupabaseMessRepository` (or a `SyncingRepository` composing local +
/// remote) can replace [LocalMessRepository] without touching a single
/// widget — see sections 27/48 of the product spec.
abstract interface class MessRepository {
  /// Emits the single local mess, or null before one has been created.
  /// A stream (not a one-shot future) so onboarding → dashboard transitions
  /// automatically once a mess is created.
  Stream<Mess?> watchMess();

  Future<Mess> createMess({
    required String name,
    required String currencyCode,
    required String currencySymbol,
  });

  Future<void> updateMess(Mess mess);

  /// Wipes every table. Used by the "Delete all local data" setting.
  Future<void> deleteAllData();
}
