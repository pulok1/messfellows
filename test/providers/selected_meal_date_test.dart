import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/utils/date_utils.dart';
import 'package:messfellows/providers/selection_providers.dart';

void main() {
  test('addDays steps whole calendar days across month and year ends', () {
    expect(addDays(DateTime(2026, 9, 30), 1), DateTime(2026, 10, 1));
    expect(addDays(DateTime(2027, 1, 1), -1), DateTime(2026, 12, 31));
    expect(addDays(DateTime(2028, 2, 28, 23, 30), 1), DateTime(2028, 2, 29));
  });

  test('the meal date can step back freely but not past tomorrow', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(selectedMealDateProvider.notifier);
    final today = dateOnly(DateTime.now());

    notifier.goToPreviousDay();
    expect(container.read(selectedMealDateProvider), addDays(today, -1));

    notifier
      ..goToToday()
      ..goToNextDay()
      ..goToNextDay()
      ..goToNextDay();
    expect(container.read(selectedMealDateProvider), addDays(today, 1));
  });
}
