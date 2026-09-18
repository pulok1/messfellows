import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/settlement_status.dart';
import 'tables/expense_table.dart';
import 'tables/meal_entry_table.dart';
import 'tables/member_table.dart';
import 'tables/mess_table.dart';
import 'tables/monthly_settlement_member_table.dart';
import 'tables/monthly_settlement_table.dart';
import 'tables/payment_table.dart';

part 'app_database.g.dart';

/// The app's single local SQLite database. Repositories are the only layer
/// allowed to touch this directly — see lib/repositories — so the UI never
/// depends on Drift/SQLite APIs and a future Supabase-backed repository can
/// be dropped in without touching widgets.
@DriftDatabase(
  tables: [
    Messes,
    Members,
    MealEntries,
    Expenses,
    Payments,
    MonthlySettlements,
    MonthlySettlementMembers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory constructor for tests, so unit tests never touch disk.
  AppDatabase.forTesting(super.executor);

  // Bump this and add a migration step below whenever a table or column
  // changes. Future sync-metadata columns (syncStatus, remoteId, ...) will
  // land as additive migrations here rather than a rewrite.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // expenses.category (required quick-pick text) replaced by
        // expenses.bazarList (a free-text list of what was bought).
        await m.alterTable(
          TableMigration(
            expenses,
            columnTransformer: {expenses.bazarList: const Constant('')},
            newColumns: [expenses.bazarList],
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'mess_fellows',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // Web is not a target platform for this app (section 31 — Android
      // phones), but this keeps `flutter run -d chrome` usable for quick
      // manual checks in environments without an Android emulator. Assets
      // in web/ must match the pinned drift version (see pubspec.lock).
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
