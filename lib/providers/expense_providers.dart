import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import 'params.dart';
import 'repository_providers.dart';

final expensesForMonthProvider = StreamProvider.family<List<Expense>, MonthParams>((
  ref,
  params,
) {
  return ref
      .watch(expenseRepositoryProvider)
      .watchExpensesForMonth(params.messId, params.year, params.month);
});

final expensesForMemberProvider = StreamProvider.family<List<Expense>, MemberParams>((
  ref,
  params,
) {
  return ref
      .watch(expenseRepositoryProvider)
      .watchExpensesForMember(params.messId, params.memberId);
});
