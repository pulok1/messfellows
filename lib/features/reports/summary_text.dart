import 'package:flutter/widgets.dart';

import '../../core/utils/localized_date.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/activity_log_entry.dart';
import '../../models/member_balance.dart';
import '../../models/month_calculation_result.dart';
import '../meals/meal_slot_ui.dart';

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
  List<ActivityLogEntry> lateMealChanges = const [],
  Map<String, String> memberNames = const {},
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

  // Always disclosed — including when there were none — so members never
  // have to wonder whether a past day was quietly changed.
  buffer.writeln();
  if (lateMealChanges.isEmpty) {
    buffer.writeln(l10n.summaryNoLateChanges);
  } else {
    buffer.writeln(l10n.summaryLateChangesHeader(lateMealChanges.length));
    for (final change in lateMealChanges) {
      buffer.writeln(describeLateMealChange(context, change, memberNames));
    }
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

/// "• 24 Sep · Rahim · Lunch: 0 → 1 — Forgot to mark"
String describeLateMealChange(
  BuildContext context,
  ActivityLogEntry change,
  Map<String, String> memberNames,
) {
  final l10n = AppLocalizations.of(context);
  final parts = [
    formatDayMonth(context, change.mealDate!),
    ?memberNames[change.memberId],
    l10n.mealChangeLine(
      mealSlotLabel(l10n, change.mealSlot!),
      change.previousCount ?? 0,
      change.count ?? 0,
    ),
  ];
  final reason = change.detail;
  return '• ${parts.join(' · ')}'
      '${reason == null || reason.isEmpty ? '' : ' — $reason'}';
}
