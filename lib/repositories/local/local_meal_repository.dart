import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../database/app_database.dart';
import '../../models/activity_type.dart';
import '../../models/meal_entry.dart';
import '../../models/meal_slot.dart';
import '../../models/settlement_status.dart';
import '../meal_repository.dart';
import 'activity_logger.dart';

class LocalMealRepository implements MealRepository {
  final AppDatabase _db;

  /// What "now" is, so tests can decide which days count as past.
  final DateTime Function() _clock;

  LocalMealRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

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
  Stream<List<MealEntry>> watchMealsForMonth(
    String messId,
    int year,
    int month,
  ) {
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
  Future<MealEntry?> getMealEntry(
    String messId,
    String memberId,
    DateTime date,
  ) async {
    final day = dateOnly(date);
    final row =
        await (_db.select(_db.mealEntries)..where(
              (t) =>
                  t.messId.equals(messId) &
                  t.memberId.equals(memberId) &
                  t.date.equals(day),
            ))
            .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> setMeal({
    required String messId,
    required String memberId,
    required DateTime date,
    int? breakfast,
    int? lunch,
    int? dinner,
    String? reason,
  }) async {
    _validateCounts([breakfast, lunch, dinner]);
    final day = dateOnly(date);
    final now = _clock();
    final lateReason = _lateReason(day, now, reason);

    await _db.transaction(() async {
      await _ensureMonthOpen(messId, day);
      await _upsert(
        messId: messId,
        memberId: memberId,
        day: day,
        now: now,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        lateReason: lateReason,
      );
    });
  }

  @override
  Future<void> setMealsForDate({
    required String messId,
    required DateTime date,
    required Map<String, MealCounts> countsByMember,
    String? reason,
  }) async {
    for (final counts in countsByMember.values) {
      _validateCounts([counts.breakfast, counts.lunch, counts.dinner]);
    }
    if (countsByMember.isEmpty) return;
    final day = dateOnly(date);
    final now = _clock();
    final lateReason = _lateReason(day, now, reason);

    await _db.transaction(() async {
      await _ensureMonthOpen(messId, day);
      for (final MapEntry(key: memberId, value: counts)
          in countsByMember.entries) {
        await _upsert(
          messId: messId,
          memberId: memberId,
          day: day,
          now: now,
          breakfast: counts.breakfast,
          lunch: counts.lunch,
          dinner: counts.dinner,
          lateReason: lateReason,
        );
      }
    });
  }

  /// The trimmed [reason] if [day] is before [now]'s day (so the change
  /// must be logged), null for today or later. Throws if a past day has no
  /// reason.
  String? _lateReason(DateTime day, DateTime now, String? reason) {
    if (!day.isBefore(dateOnly(now))) return null;
    final trimmed = reason?.trim() ?? '';
    if (trimmed.isEmpty) {
      throw const ReasonRequiredException(
        'Changing a past day needs a reason.',
      );
    }
    return trimmed;
  }

  void _validateCounts(List<int?> counts) {
    for (final count in counts) {
      if (count != null && count < 0) {
        throw const ValidationException('Meal count cannot be negative.');
      }
    }
  }

  /// Rejects a write into a closed month. Checked inside the write's own
  /// transaction so a month can't be closed between the check and the
  /// write.
  Future<void> _ensureMonthOpen(String messId, DateTime day) async {
    final closed =
        await (_db.select(_db.monthlySettlements)..where(
              (t) =>
                  t.messId.equals(messId) &
                  t.year.equals(day.year) &
                  t.month.equals(day.month) &
                  t.status.equalsValue(SettlementStatus.closed),
            ))
            .getSingleOrNull();
    if (closed != null) {
      throw const MonthClosedException(
        'This month is closed. Reopen it to change its meals.',
      );
    }
  }

  /// Creates or updates [memberId]'s row for [day]. Null counts keep their
  /// current value (or 0 on a new row). With a [lateReason], logs one
  /// Activity Log entry per slot whose count actually changes.
  Future<void> _upsert({
    required String messId,
    required String memberId,
    required DateTime day,
    required DateTime now,
    int? breakfast,
    int? lunch,
    int? dinner,
    String? lateReason,
  }) async {
    final existing =
        await (_db.select(_db.mealEntries)..where(
              (t) =>
                  t.messId.equals(messId) &
                  t.memberId.equals(memberId) &
                  t.date.equals(day),
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
              breakfast: Value(breakfast ?? 0),
              lunch: Value(lunch ?? 0),
              dinner: Value(dinner ?? 0),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(
        _db.mealEntries,
      )..where((t) => t.id.equals(existing.id))).write(
        MealEntriesCompanion(
          breakfast: breakfast == null
              ? const Value.absent()
              : Value(breakfast),
          lunch: lunch == null ? const Value.absent() : Value(lunch),
          dinner: dinner == null ? const Value.absent() : Value(dinner),
          updatedAt: Value(now),
        ),
      );
    }

    if (lateReason == null) return;
    final before = existing == null
        ? noMeals
        : (
            breakfast: existing.breakfast,
            lunch: existing.lunch,
            dinner: existing.dinner,
          );
    final requested = {
      MealSlot.breakfast: breakfast,
      MealSlot.lunch: lunch,
      MealSlot.dinner: dinner,
    };
    for (final MapEntry(key: slot, value: after) in requested.entries) {
      final previous = slot.countIn(before);
      if (after == null || after == previous) continue;
      await logActivity(
        _db,
        messId: messId,
        type: ActivityType.mealChangedLater,
        memberId: memberId,
        mealDate: day,
        mealSlot: slot,
        previousCount: previous,
        count: after,
        detail: lateReason,
      );
    }
  }
}
