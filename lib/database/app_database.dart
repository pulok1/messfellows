import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/rule_category.dart';
import '../models/settlement_status.dart';
import 'tables/expense_table.dart';
import 'tables/meal_entry_table.dart';
import 'tables/member_table.dart';
import 'tables/mess_rule_table.dart';
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
    MessRules,
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
  int get schemaVersion => 5;

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
      if (from < 3) {
        // mealEntries.breakfast/lunch/dinner: bool -> int (a meal count, so
        // a slot can be 2+ for an extra/guest meal). SQLite has no native
        // boolean type — Drift's boolean() columns are already stored as
        // plain 0/1 INTEGER — so existing data needs no conversion, only
        // the Dart-side column type changes. No SQL step needed here.
      }
      if (from < 4) {
        // messes gains per-mess toggles for which meal slots it tracks (not
        // every mess serves breakfast). Default true so existing messes
        // keep showing all three slots exactly as before.
        await m.alterTable(
          TableMigration(
            messes,
            columnTransformer: {
              messes.trackBreakfast: const Constant(true),
              messes.trackLunch: const Constant(true),
              messes.trackDinner: const Constant(true),
            },
            newColumns: [
              messes.trackBreakfast,
              messes.trackLunch,
              messes.trackDinner,
            ],
          ),
        );
      }
      if (from < 5) {
        // Mess rules & regulations: a new table, plus a stamp on messes for
        // when the rules last changed (nullable, so no backfill needed).
        await m.createTable(messRules);
        await m.addColumn(messes, messes.rulesUpdatedAt);
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
