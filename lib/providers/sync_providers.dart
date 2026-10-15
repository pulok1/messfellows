import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/cloud_auth_service.dart';
import '../sync/local_sync_store.dart';
import '../sync/supabase_sync_api.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_triggers.dart';
import 'database_provider.dart';

/// Overridden in main() with the initialized client. Null otherwise (a
/// build with cloud sync switched off, and tests) — the app is then
/// offline-only and every cloud entry point hides itself.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

/// Null when cloud sync isn't configured in this build.
final cloudAuthServiceProvider = Provider<CloudAuthService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : CloudAuthService(client.auth);
});

/// The signed-in account, or null. Re-emits on token refreshes, so watch
/// [signedInUserIdProvider] for anything that should only react to an
/// actual sign-in or sign-out.
final authUserProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value(null);
  return client.auth.onAuthStateChange.map((state) => state.session?.user);
});

final signedInUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authUserProvider.select((user) => user.value?.id));
});

/// Runs while someone is signed in; torn down on sign-out (local data
/// stays). Watched by AppRoot so it lives for the whole session, not just
/// while Settings is open.
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(signedInUserIdProvider);
  if (client == null || userId == null) return null;

  final db = ref.watch(appDatabaseProvider);
  final synced = db.allTables.where(
    (t) => syncedTables.contains(t.actualTableName),
  );
  final engine = SyncEngine(
    store: LocalSyncStore(db),
    remote: SupabaseSyncApi(client, userId),
    userId: userId,
    localChanges: db
        .tableUpdates(TableUpdateQuery.onAllTables(synced))
        .map((_) {}),
  );
  final lifecycle = AppLifecycleListener(onResume: engine.syncNow);
  ref.onDispose(() {
    lifecycle.dispose();
    engine.dispose();
  });
  engine.start();
  return engine;
});

/// Null while signed out.
final syncStatusProvider = StreamProvider<SyncStatus?>((ref) {
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) return Stream.value(null);
  return Stream.multi((controller) {
    controller.add(engine.status);
    final sub = engine.statusStream.listen(controller.add);
    controller.onCancel = sub.cancel;
  });
});
