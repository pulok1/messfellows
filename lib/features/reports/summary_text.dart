import '../../models/member_balance.dart';
import '../../models/month_calculation_result.dart';

/// Builds the concise, copy/share-friendly monthly summary from section 21
/// — short enough to paste straight into Messenger/WhatsApp/Telegram.
String buildMonthlySummary({
  required String messName,
  required int year,
  required int month,
  required MonthCalculationResult result,
}) {
  final buffer = StringBuffer()
    ..writeln('🍚 $messName')
    ..writeln('${_monthName(month)} $year')
    ..writeln()
    ..writeln('Total Bazar: ${result.totalExpense.format()}')
    ..writeln('Total Meals: ${result.totalMeals}')
    ..writeln(
      'Meal Rate: ${result.hasNoMeals ? "N/A" : result.mealRate.format()}',
    );

  for (final balance in result.memberBalances) {
    buffer
      ..writeln()
      ..writeln(balance.memberName)
      ..writeln('${balance.mealCount} meals')
      ..writeln('Paid: ${balance.paidAmount.format()}')
      ..writeln(_balanceLine(balance));
  }

  return buffer.toString().trimRight();
}

String _balanceLine(MemberBalance balance) {
  if (balance.balance.isPositive) return 'Will receive: ${balance.balanceMagnitude.format()}';
  if (balance.balance.isNegative) return 'Needs to pay: ${balance.balanceMagnitude.format()}';
  return 'Settled';
}

String _monthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return months[month - 1];
}
