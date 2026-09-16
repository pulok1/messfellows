import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settlement.dart';
import 'params.dart';
import 'repository_providers.dart';

/// All settlements for a mess, newest first — the source for the month
/// history list.
final settlementsProvider = StreamProvider.family<List<MonthlySettlement>, String>((ref, messId) {
  return ref.watch(settlementRepositoryProvider).watchSettlements(messId);
});

/// The settlement for one specific month, or null if it hasn't been closed
/// yet. Derived from [settlementsProvider] rather than a separate query so
/// there's one stream per mess instead of one per month screen visited.
final settlementForMonthProvider = Provider.family<MonthlySettlement?, MonthParams>((
  ref,
  params,
) {
  final settlements = ref.watch(settlementsProvider(params.messId)).value ?? const [];
  for (final settlement in settlements) {
    if (settlement.year == params.year && settlement.month == params.month) {
      return settlement;
    }
  }
  return null;
});

final settlementMembersProvider = StreamProvider.family<List<MonthlySettlementMember>, String>((
  ref,
  settlementId,
) {
  return ref.watch(settlementRepositoryProvider).watchSettlementMembers(settlementId);
});
