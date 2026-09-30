import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import 'params.dart';
import 'repository_providers.dart';

final expensesForMonthProvider =
    StreamProvider.family<List<Expense>, MonthParams>((ref, params) {
      return ref
          .watch(expenseRepositoryProvider)
          .watchExpensesForMonth(params.messId, params.year, params.month);
    });

final expensesForMemberProvider =
    StreamProvider.family<List<Expense>, MemberParams>((ref, params) {
      return ref
          .watch(expenseRepositoryProvider)
          .watchExpensesForMember(params.messId, params.memberId);
    });

/// Soft-deleted bazar entries for the Recycle Bin.
final deletedExpensesProvider =
    StreamProvider.family<List<Expense>, String>((ref, messId) {
      return ref.watch(expenseRepositoryProvider).watchDeletedExpenses(messId);
    });

/// Recent bazar-list text, mined for "frequently bought" suggestions on the
/// add/edit bazar dialog. `autoDispose` so it re-queries fresh each time the
/// dialog opens, rather than caching a one-shot result for the app's whole
/// lifetime and missing entries added since.
final recentBazarListsProvider = FutureProvider.autoDispose.family<List<String>, String>((
  ref,
  messId,
) {
  return ref.watch(expenseRepositoryProvider).recentBazarLists(messId);
});
