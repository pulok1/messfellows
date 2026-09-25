import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment.dart';
import 'params.dart';
import 'repository_providers.dart';

final paymentsForMonthProvider =
    StreamProvider.family<List<Payment>, MonthParams>((ref, params) {
      return ref
          .watch(paymentRepositoryProvider)
          .watchPaymentsForMonth(params.messId, params.year, params.month);
    });

final paymentsForMemberProvider =
    StreamProvider.family<List<Payment>, MemberParams>((ref, params) {
      return ref
          .watch(paymentRepositoryProvider)
          .watchPaymentsForMember(params.messId, params.memberId);
    });

/// Soft-deleted payments for the Recycle Bin.
final deletedPaymentsProvider =
    StreamProvider.family<List<Payment>, String>((ref, messId) {
      return ref.watch(paymentRepositoryProvider).watchDeletedPayments(messId);
    });
