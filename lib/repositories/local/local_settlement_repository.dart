import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../models/member_balance.dart';
import '../../models/settlement.dart';
import '../../models/settlement_status.dart';
import '../settlement_repository.dart';

class LocalSettlementRepository implements SettlementRepository {
  final AppDatabase _db;

  LocalSettlementRepository(this._db);

  MonthlySettlement _toModel(MonthlySettlementRow row) => MonthlySettlement(
    id: row.id,
    messId: row.messId,
    month: row.month,
    year: row.year,
    totalExpense: Money(row.totalExpenseMinorUnits),
    totalMeals: row.totalMeals,
    mealRate: Money(row.mealRateMinorUnits),
    status: row.status,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  MonthlySettlementMember _memberToModel(MonthlySettlementMemberRow row) =>
      MonthlySettlementMember(
        id: row.id,
        settlementId: row.settlementId,
        memberId: row.memberId,
        mealCount: row.mealCount,
        mealCost: Money(row.mealCostMinorUnits),
        paidAmount: Money(row.paidAmountMinorUnits),
        balance: Money(row.balanceMinorUnits),
        createdAt: row.createdAt,
      );

  @override
  Stream<List<MonthlySettlement>> watchSettlements(String messId) {
    final query = _db.select(_db.monthlySettlements)
      ..where((t) => t.messId.equals(messId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.year),
        (t) => OrderingTerm.desc(t.month),
      ]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<MonthlySettlement?> getSettlement(String messId, int year, int month) async {
    final row = await (_db.select(_db.monthlySettlements)..where(
          (t) => t.messId.equals(messId) & t.year.equals(year) & t.month.equals(month),
        ))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Stream<List<MonthlySettlementMember>> watchSettlementMembers(String settlementId) {
    final query = _db.select(_db.monthlySettlementMembers)
      ..where((t) => t.settlementId.equals(settlementId));
    return query.watch().map((rows) => rows.map(_memberToModel).toList());
  }

  @override
  Future<MonthlySettlement> closeMonth({
    required String messId,
    required int year,
    required int month,
    required Money totalExpense,
    required int totalMeals,
    required Money mealRate,
    required List<MemberBalance> balances,
  }) async {
    final now = DateTime.now();

    return _db.transaction(() async {
      final existing = await (_db.select(_db.monthlySettlements)..where(
            (t) => t.messId.equals(messId) & t.year.equals(year) & t.month.equals(month),
          ))
          .getSingleOrNull();

      final settlementId = existing?.id ?? IdGenerator.generate();

      if (existing == null) {
        await _db
            .into(_db.monthlySettlements)
            .insert(
              MonthlySettlementsCompanion.insert(
                id: settlementId,
                messId: messId,
                month: month,
                year: year,
                totalExpenseMinorUnits: totalExpense.minorUnits,
                totalMeals: totalMeals,
                mealRateMinorUnits: mealRate.minorUnits,
                status: Value(SettlementStatus.closed),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(
          _db.monthlySettlements,
        )..where((t) => t.id.equals(settlementId))).write(
          MonthlySettlementsCompanion(
            totalExpenseMinorUnits: Value(totalExpense.minorUnits),
            totalMeals: Value(totalMeals),
            mealRateMinorUnits: Value(mealRate.minorUnits),
            status: const Value(SettlementStatus.closed),
            updatedAt: Value(now),
          ),
        );
        // Replace the prior per-member snapshot rather than merging it —
        // closeMonth always represents the full, current member set.
        await (_db.delete(
          _db.monthlySettlementMembers,
        )..where((t) => t.settlementId.equals(settlementId))).go();
      }

      await _db.batch((batch) {
        batch.insertAll(
          _db.monthlySettlementMembers,
          balances.map(
            (b) => MonthlySettlementMembersCompanion.insert(
              id: IdGenerator.generate(),
              settlementId: settlementId,
              memberId: b.memberId,
              mealCount: b.mealCount,
              mealCostMinorUnits: b.mealCost.minorUnits,
              paidAmountMinorUnits: b.paidAmount.minorUnits,
              balanceMinorUnits: b.balance.minorUnits,
              createdAt: now,
            ),
          ),
        );
      });

      return MonthlySettlement(
        id: settlementId,
        messId: messId,
        month: month,
        year: year,
        totalExpense: totalExpense,
        totalMeals: totalMeals,
        mealRate: mealRate,
        status: SettlementStatus.closed,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<void> reopenMonth(String settlementId) async {
    await (_db.update(
      _db.monthlySettlements,
    )..where((t) => t.id.equals(settlementId))).write(
      MonthlySettlementsCompanion(
        status: const Value(SettlementStatus.open),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
