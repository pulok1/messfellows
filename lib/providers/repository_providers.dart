import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/calculation_engine.dart';
import '../repositories/expense_repository.dart';
import '../repositories/local/local_expense_repository.dart';
import '../repositories/local/local_meal_repository.dart';
import '../repositories/local/local_member_repository.dart';
import '../repositories/local/local_mess_repository.dart';
import '../repositories/local/local_payment_repository.dart';
import '../repositories/local/local_settlement_repository.dart';
import '../repositories/meal_repository.dart';
import '../repositories/member_repository.dart';
import '../repositories/mess_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/settlement_repository.dart';
import 'database_provider.dart';

/// Every provider below exposes the *interface* type, never the `Local*`
/// implementation — everything downstream (other providers, widgets) reads
/// through the interface. Swapping in a future sync-aware repository is a
/// one-line change here, not a rewrite of the app.
final messRepositoryProvider = Provider<MessRepository>((ref) {
  return LocalMessRepository(ref.watch(appDatabaseProvider));
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return LocalMemberRepository(ref.watch(appDatabaseProvider));
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return LocalMealRepository(ref.watch(appDatabaseProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return LocalExpenseRepository(ref.watch(appDatabaseProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return LocalPaymentRepository(ref.watch(appDatabaseProvider));
});

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  return LocalSettlementRepository(ref.watch(appDatabaseProvider));
});

final calculationEngineProvider = Provider<CalculationEngine>((ref) {
  return const CalculationEngine();
});
