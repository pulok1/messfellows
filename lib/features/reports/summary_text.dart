import 'package:flutter/widgets.dart';

import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/member_balance.dart';
import '../../models/month_calculation_result.dart';

/// Builds the concise, copy/share-friendly monthly summary from section 21
/// — short enough to paste straight into Messenger/WhatsApp/Telegram.
/// Localized to whatever language the app is currently showing, since this
/// text is meant to be sent to other mess members.
String buildMonthlySummary({
  required BuildContext context,
  required String messName,
  required int year,
  required int month,
  required MonthCalculationResult result,
}) {
  final l10n = AppLocalizations.of(context);
  final buffer = StringBuffer()
    ..writeln('🍚 $messName')
    ..writeln(formatMonthYear(context, year, month))
    ..writeln()
    ..writeln(l10n.totalBazarLine(result.totalExpense.format()))
    ..writeln(l10n.totalMealsLine('${result.totalMeals}'))
    ..writeln(
      l10n.mealRateLine(result.hasNoMeals ? l10n.notApplicable : result.mealRate.format()),
    );

  for (final balance in result.memberBalances) {
    buffer
      ..writeln()
      ..writeln(balance.memberName)
      ..writeln(l10n.mealsCount(balance.mealCount))
      ..writeln(l10n.paidLine(balance.paidAmount.format()))
      ..writeln(_balanceLine(l10n, balance));
  }

  return buffer.toString().trimRight();
}

String _balanceLine(AppLocalizations l10n, MemberBalance balance) {
  if (balance.balance.isPositive) {
    return l10n.willReceiveLine(balance.balanceMagnitude.format());
  }
  if (balance.balance.isNegative) {
    return l10n.needsToPayLine(balance.balanceMagnitude.format());
  }
  return l10n.settled;
}
