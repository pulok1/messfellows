import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/balance_status.dart';
import '../../../models/member_balance.dart';

/// Renders a member's balance the same way everywhere it appears
/// (dashboard, report, member detail): status spelled out in words plus an
/// amount, never color alone (section 32), on a pill tinted with the
/// status colour so it scans as a status at a glance.
class BalanceLabel extends StatelessWidget {
  final MemberBalance balance;
  final TextStyle? style;

  const BalanceLabel({super.key, required this.balance, this.style});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (text, color) = switch (balance.status) {
      BalanceStatus.willReceive => (
        l10n.willReceiveAmount(balance.balanceMagnitude.format()),
        AppBalanceColors.willReceive(context),
      ),
      BalanceStatus.needsToPay => (
        l10n.needsToPayAmount(balance.balanceMagnitude.format()),
        AppBalanceColors.needsToPay(context),
      ),
      BalanceStatus.settled => (l10n.settled, AppBalanceColors.settled(context)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.labelLarge)?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
