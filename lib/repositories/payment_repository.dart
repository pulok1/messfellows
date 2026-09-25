import '../core/utils/money.dart';
import '../models/payment.dart';

abstract interface class PaymentRepository {
  Stream<List<Payment>> watchPaymentsForMonth(
    String messId,
    int year,
    int month,
  );

  Stream<List<Payment>> watchPaymentsForMember(String messId, String memberId);

  Future<Payment> addPayment({
    required String messId,
    required DateTime date,
    required String memberId,
    required Money amount,
    String? note,
  });

  Future<void> updatePayment(Payment payment);

  /// Soft-deletes: the payment moves to the Recycle Bin rather than
  /// disappearing outright. See [restorePayment]/[permanentlyDeletePayment].
  Future<void> deletePayment(String id);

  /// All soft-deleted payments for [messId], most recently deleted first —
  /// the Recycle Bin's source.
  Stream<List<Payment>> watchDeletedPayments(String messId);

  Future<void> restorePayment(String id);

  Future<void> permanentlyDeletePayment(String id);

  /// Hard-deletes payments soft-deleted more than [retention] ago.
  Future<void> purgeExpiredPayments(String messId, Duration retention);
}
