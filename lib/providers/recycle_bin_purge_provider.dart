import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import 'repository_providers.dart';

/// Purges bazar entries/payments that have sat in the Recycle Bin longer
/// than [AppConstants.recycleBinRetentionDays]. Watched once from
/// [HomeShell] so it runs a single time per app session — a background
/// cleanup rather than something the user has to trigger.
final recycleBinPurgeProvider = FutureProvider.family<void, String>((
  ref,
  messId,
) async {
  const retention = Duration(days: AppConstants.recycleBinRetentionDays);
  await ref.read(expenseRepositoryProvider).purgeExpiredExpenses(messId, retention);
  await ref.read(paymentRepositoryProvider).purgeExpiredPayments(messId, retention);
});
