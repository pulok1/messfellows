import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../models/activity_type.dart';
import '../../models/payment.dart';
import '../payment_repository.dart';
import 'activity_logger.dart';

class LocalPaymentRepository implements PaymentRepository {
  final AppDatabase _db;

  LocalPaymentRepository(this._db);

  Payment _toModel(PaymentRow row) => Payment(
    id: row.id,
    messId: row.messId,
    date: row.date,
    memberId: row.memberId,
    amount: Money(row.amountMinorUnits),
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );

  @override
  Stream<List<Payment>> watchPaymentsForMonth(
    String messId,
    int year,
    int month,
  ) {
    final start = firstDayOfMonth(year, month);
    final end = firstDayOfNextMonth(year, month);
    final query = _db.select(_db.payments)
      ..where(
        (t) =>
            t.messId.equals(messId) &
            t.date.isBiggerOrEqualValue(start) &
            t.date.isSmallerThanValue(end) &
            t.deletedAt.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<Payment>> watchPaymentsForMember(String messId, String memberId) {
    final query = _db.select(_db.payments)
      ..where(
        (t) =>
            t.messId.equals(messId) &
            t.memberId.equals(memberId) &
            t.deletedAt.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Stream<List<Payment>> watchDeletedPayments(String messId) {
    final query = _db.select(_db.payments)
      ..where((t) => t.messId.equals(messId) & t.deletedAt.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<Payment> addPayment({
    required String messId,
    required DateTime date,
    required String memberId,
    required Money amount,
    String? note,
  }) async {
    if (amount.minorUnits <= 0) {
      throw const ValidationException('Amount must be greater than zero.');
    }

    final now = DateTime.now();
    final id = IdGenerator.generate();
    final day = dateOnly(date);
    await _db
        .into(_db.payments)
        .insert(
          PaymentsCompanion.insert(
            id: id,
            messId: messId,
            date: day,
            memberId: memberId,
            amountMinorUnits: amount.minorUnits,
            note: Value(note),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await logActivity(
      _db,
      messId: messId,
      type: ActivityType.paymentAdded,
      memberId: memberId,
      amountMinorUnits: amount.minorUnits,
      detail: note,
    );
    return Payment(
      id: id,
      messId: messId,
      date: day,
      memberId: memberId,
      amount: amount,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    if (payment.amount.minorUnits <= 0) {
      throw const ValidationException('Amount must be greater than zero.');
    }
    await (_db.update(
      _db.payments,
    )..where((t) => t.id.equals(payment.id))).write(
      PaymentsCompanion(
        date: Value(dateOnly(payment.date)),
        memberId: Value(payment.memberId),
        amountMinorUnits: Value(payment.amount.minorUnits),
        note: Value(payment.note),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await logActivity(
      _db,
      messId: payment.messId,
      type: ActivityType.paymentEdited,
      memberId: payment.memberId,
      amountMinorUnits: payment.amount.minorUnits,
      detail: payment.note,
    );
  }

  @override
  Future<void> deletePayment(String id) async {
    final row = await (_db.select(
      _db.payments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.update(
      _db.payments,
    )..where((t) => t.id.equals(id))).write(
      PaymentsCompanion(deletedAt: Value(DateTime.now())),
    );
    if (row != null) {
      await logActivity(
        _db,
        messId: row.messId,
        type: ActivityType.paymentDeleted,
        memberId: row.memberId,
        amountMinorUnits: row.amountMinorUnits,
        detail: row.note,
      );
    }
  }

  @override
  Future<void> restorePayment(String id) async {
    final row = await (_db.select(
      _db.payments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.update(
      _db.payments,
    )..where((t) => t.id.equals(id))).write(
      const PaymentsCompanion(deletedAt: Value(null)),
    );
    if (row != null) {
      await logActivity(
        _db,
        messId: row.messId,
        type: ActivityType.paymentRestored,
        memberId: row.memberId,
        amountMinorUnits: row.amountMinorUnits,
        detail: row.note,
      );
    }
  }

  @override
  Future<void> permanentlyDeletePayment(String id) async {
    final row = await (_db.select(
      _db.payments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.payments)..where((t) => t.id.equals(id))).go();
    if (row != null) {
      await logActivity(
        _db,
        messId: row.messId,
        type: ActivityType.paymentPurged,
        memberId: row.memberId,
        amountMinorUnits: row.amountMinorUnits,
        detail: row.note,
      );
    }
  }

  @override
  Future<void> purgeExpiredPayments(String messId, Duration retention) async {
    final cutoff = DateTime.now().subtract(retention);
    await (_db.delete(_db.payments)..where(
          (t) =>
              t.messId.equals(messId) &
              t.deletedAt.isNotNull() &
              t.deletedAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }
}
