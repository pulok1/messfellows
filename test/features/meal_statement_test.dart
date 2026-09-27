import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messfellows/features/meals/meal_statement_text.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/activity_log_entry.dart';
import 'package:messfellows/models/activity_type.dart';
import 'package:messfellows/models/meal_entry.dart';
import 'package:messfellows/models/meal_slot.dart';

MealEntry _meal(DateTime date, {int breakfast = 0, int lunch = 0, int dinner = 0}) {
  return MealEntry(
    id: date.toIso8601String(),
    messId: 'mess-1',
    memberId: 'm1',
    date: date,
    breakfast: breakfast,
    lunch: lunch,
    dinner: dinner,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  Future<String> statement(WidgetTester tester, {required DateTime today}) async {
    late String text;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            text = buildMealStatement(
              context: context,
              messName: 'Test Mess',
              memberName: 'Rahim',
              year: 2026,
              month: 9,
              memberMeals: [
                _meal(DateTime(2026, 9, 1), lunch: 1, dinner: 1),
                _meal(DateTime(2026, 9, 3), breakfast: 1, lunch: 2),
              ],
              memberLateChanges: [
                ActivityLogEntry(
                  id: 'a',
                  messId: 'mess-1',
                  type: ActivityType.mealChangedLater,
                  memberId: 'm1',
                  mealDate: DateTime(2026, 9, 3),
                  mealSlot: MealSlot.lunch,
                  previousCount: 1,
                  count: 2,
                  detail: 'Guest meal',
                  createdAt: DateTime(2026, 9, 4, 9),
                ),
              ],
              today: today,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return text;
  }

  testWidgets('lists every day so far, marks late changes and totals up', (
    tester,
  ) async {
    final text = await statement(tester, today: DateTime(2026, 9, 4));

    expect(
      text,
      '🍚 Test Mess\n'
      'Rahim · Meal statement\n'
      'September 2026\n'
      '\n'
      '1 Sep: Lunch, Dinner (2)\n'
      '2 Sep: —\n'
      '3 Sep: Breakfast, Lunch ×2 (3) ✏️\n'
      '4 Sep: —\n'
      '\n'
      'Total Meals: 5\n'
      '\n'
      '✏️ = changed after the day:\n'
      '• 3 Sep · Lunch: 1 → 2 — Guest meal',
    );
  });

  testWidgets('a past month runs to its last day', (tester) async {
    final text = await statement(tester, today: DateTime(2026, 11, 2));
    expect(text, contains('30 Sep: —'));
    expect(text, isNot(contains('1 Oct')));
  });
}
