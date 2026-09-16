import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// The app's single [AppDatabase] instance. Kept alive for the app's
/// lifetime and closed on dispose (relevant mainly for tests, which create
/// and tear down a fresh container per test).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
