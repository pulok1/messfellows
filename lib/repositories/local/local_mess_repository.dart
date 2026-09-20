import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../database/app_database.dart';
import '../../models/mess.dart';
import '../mess_repository.dart';

/// Drift-backed [MessRepository]. The MVP only ever has one mess, so
/// [watchMess] simply reads the first row.
class LocalMessRepository implements MessRepository {
  final AppDatabase _db;

  LocalMessRepository(this._db);

  Mess _toModel(MessRow row) => Mess(
    id: row.id,
    name: row.name,
    currencyCode: row.currencyCode,
    currencySymbol: row.currencySymbol,
    trackBreakfast: row.trackBreakfast,
    trackLunch: row.trackLunch,
    trackDinner: row.trackDinner,
    rulesUpdatedAt: row.rulesUpdatedAt,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  @override
  Stream<Mess?> watchMess() {
    final query = _db.select(_db.messes)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(1);
    return query.watch().map(
      (rows) => rows.isEmpty ? null : _toModel(rows.first),
    );
  }

  @override
  Future<Mess> createMess({
    required String name,
    required String currencyCode,
    required String currencySymbol,
  }) async {
    final now = DateTime.now();
    final id = IdGenerator.generate();
    await _db
        .into(_db.messes)
        .insert(
          MessesCompanion.insert(
            id: id,
            name: name,
            currencyCode: Value(currencyCode),
            currencySymbol: Value(currencySymbol),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return Mess(
      id: id,
      name: name,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateMess(Mess mess) async {
    await (_db.update(_db.messes)..where((t) => t.id.equals(mess.id))).write(
      MessesCompanion(
        name: Value(mess.name),
        currencyCode: Value(mess.currencyCode),
        currencySymbol: Value(mess.currencySymbol),
        trackBreakfast: Value(mess.trackBreakfast),
        trackLunch: Value(mess.trackLunch),
        trackDinner: Value(mess.trackDinner),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteAllData() async {
    // Children before parents so foreign-key constraints don't reject the
    // deletes (PRAGMA foreign_keys is on — see AppDatabase.beforeOpen).
    await _db.transaction(() async {
      await _db.delete(_db.monthlySettlementMembers).go();
      await _db.delete(_db.monthlySettlements).go();
      await _db.delete(_db.mealEntries).go();
      await _db.delete(_db.expenses).go();
      await _db.delete(_db.payments).go();
      await _db.delete(_db.members).go();
      await _db.delete(_db.messes).go();
    });
  }
}
