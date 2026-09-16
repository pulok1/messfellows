import '../core/utils/money.dart';
import '../models/payment.dart';

abstract interface class PaymentRepository {
  Stream<List<Payment>> watchPaymentsForMonth(String messId, int year, int month);

  Stream<List<Payment>> watchPaymentsForMember(String messId, String memberId);

  Future<Payment> addPayment({
    required String messId,
    required DateTime date,
    required String memberId,
    required Money amount,
    String? note,
  });

  Future<void> updatePayment(Payment payment);

  Future<void> deletePayment(String id);
}
