import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/member_balance.dart';
import '../../shared/widgets/balance_label.dart';
import '../../shared/widgets/member_avatar.dart';

/// One member's row within the dashboard's settlement summary. A bare row
/// rather than its own card: the dashboard groups every member into one
/// card with dividers between rows, which reads as a single list.
class SettlementTile extends StatelessWidget {
  final MemberBalance balance;
  final VoidCallback? onTap;

  const SettlementTile({super.key, required this.balance, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: MemberAvatar(
        memberId: balance.memberId,
        name: balance.memberName,
      ),
      title: Text(
        balance.memberName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        AppLocalizations.of(context)
            .mealsCountPaid(balance.mealCount, balance.paidAmount.format()),
      ),
      trailing: BalanceLabel(balance: balance),
    );
  }
}
