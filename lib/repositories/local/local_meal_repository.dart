import 'package:drift/drift.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../database/app_database.dart';
import '../../models/meal_entry.dart';
import '../meal_repository.dart';

class LocalMealRepository implements MealRepository {
  final AppDatabase _db;

  LocalMealRepository(this._db);

  MealEntry _toModel(MealEntryRow row) => MealEntry(
    id: row.id,
    messId: row.messId,
    memberId: row.memberId,
    date: row.date,
    breakfast: row.breakfast,
    lunch: row.lunch,
    dinner: row.dinner,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  @override
  Stream<List<MealEntry>> watchMealsForDate(String messId, DateTime date) {
    final day = dateOnly(date);
    final query = _db.select(_db.mealEntries)
      ..where((t) => t.messId.equals(messId) & t.date.equals(day));
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<MealEntry>> watchMealsForMonth(String messId, int year, int month) {
    final start = firstDayOfMonth(year, month);
    final end = firstDayOfNextMonth(year, month);
    final query = _db.select(_db.mealEntries)
      ..where(
        (t) =>
            t.messId.equals(messId) &
            t.date.isBiggerOrEqualValue(start) &
            t.date.isSmallerThanValue(end),
      );
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<MealEntry?> getMealEntry(String messId, String memberId, DateTime date) async {
    final day = dateOnly(date);
    final row = await (_db.select(_db.mealEntries)..where(
          (t) => t.messId.equals(messId) & t.memberId.equals(memberId) & t.date.equals(day),
        ))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> setMeal({
    required String messId,
    required String memberId,
    required DateTime date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) async {
    final day = dateOnly(date);
    final now = DateTime.now();

    await _db.transaction(() async {
      final existing = await (_db.select(_db.mealEntries)..where(
            (t) => t.messId.equals(messId) & t.memberId.equals(memberId) & t.date.equals(day),
          ))
          .getSingleOrNull();

      if (existing == null) {
        await _db
            .into(_db.mealEntries)
            .insert(
              MealEntriesCompanion.insert(
                id: IdGenerator.generate(),
                messId: messId,
                memberId: memberId,
                date: day,
                breakfast: Value(breakfast ?? false),
                lunch: Value(lunch ?? false),
                dinner: Value(dinner ?? false),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(
          _db.mealEntries,
        )..where((t) => t.id.equals(existing.id))).write(
          MealEntriesCompanion(
            breakfast: breakfast == null ? const Value.absent() : Value(breakfast),
            lunch: lunch == null ? const Value.absent() : Value(lunch),
            dinner: dinner == null ? const Value.absent() : Value(dinner),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
