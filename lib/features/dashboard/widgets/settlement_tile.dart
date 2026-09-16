import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/member_balance.dart';
import '../../shared/widgets/balance_label.dart';

/// One member's row within the dashboard's settlement summary.
class SettlementTile extends StatelessWidget {
  final MemberBalance balance;
  final VoidCallback? onTap;

  const SettlementTile({super.key, required this.balance, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          balance.memberName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${balance.mealCount} meals · Paid ${balance.paidAmount.format()}',
        ),
        trailing: BalanceLabel(balance: balance),
      ),
    );
  }
}
