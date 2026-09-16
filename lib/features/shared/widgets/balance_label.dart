import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/balance_status.dart';
import '../../../models/member_balance.dart';

/// Renders a member's balance the same way everywhere it appears
/// (dashboard, report, member detail): status spelled out in words plus an
/// amount, never color alone (section 32).
class BalanceLabel extends StatelessWidget {
  final MemberBalance balance;
  final TextStyle? style;

  const BalanceLabel({super.key, required this.balance, this.style});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (balance.status) {
      BalanceStatus.willReceive => (
        'Will receive ${balance.balanceMagnitude.format()}',
        AppBalanceColors.willReceive,
      ),
      BalanceStatus.needsToPay => (
        'Needs to pay ${balance.balanceMagnitude.format()}',
        AppBalanceColors.needsToPay,
      ),
      BalanceStatus.settled => ('Settled', AppBalanceColors.settled),
    };

    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
