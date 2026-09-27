import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messfellows/core/theme/app_theme.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/features/reports/report_screen.dart';
import 'package:messfellows/features/reports/summary_text.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/activity_log_entry.dart';
import 'package:messfellows/models/activity_type.dart';
import 'package:messfellows/models/meal_slot.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/models/month_calculation_result.dart';
import 'package:messfellows/providers/database_provider.dart';
import 'package:messfellows/providers/selection_providers.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  Widget localized(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );

  Future<String> summaryWith(
    WidgetTester tester,
    List<ActivityLogEntry> changes,
  ) async {
    late String text;
    await tester.pumpWidget(
      localized(
        Builder(
          builder: (context) {
            text = buildMonthlySummary(
              context: context,
              messName: 'Test Mess',
              year: 2026,
              month: 9,
              result: const MonthCalculationResult(
                totalExpense: Money(0),
                totalMeals: 0,
                mealRate: Money(0),
                memberBalances: [],
              ),
              lateMealChanges: changes,
              memberNames: const {'m1': 'Rahim'},
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return text;
  }

  testWidgets('the shared summary says so when nothing was changed later', (
    tester,
  ) async {
    final text = await summaryWith(tester, const []);
    expect(text, endsWith('✅ No meals were changed after their day.'));
  });

  testWidgets('the shared summary lists every late change with its reason', (
    tester,
  ) async {
    final text = await summaryWith(tester, [
      ActivityLogEntry(
        id: 'a',
        messId: 'mess-1',
        type: ActivityType.mealChangedLater,
        memberId: 'm1',
        mealDate: DateTime(2026, 9, 24),
        mealSlot: MealSlot.lunch,
        previousCount: 0,
        count: 1,
        detail: 'Forgot to mark',
        createdAt: DateTime(2026, 9, 25, 10),
      ),
    ]);

    expect(text, contains('✏️ Meals changed after their day (1)'));
    expect(text, contains('• 24 Sep · Rahim · Lunch: 0 → 1 — Forgot to mark'));
  });

  group('report card', () {
    late AppDatabase db;
    late Mess mess;
    late Member rahim;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mess = await LocalMessRepository(
        db,
      ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
      rahim = await LocalMemberRepository(
        db,
      ).addMember(messId: mess.id, name: 'Rahim');
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpReport(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            selectedMonthProvider.overrideWith(_September.new),
          ],
          child: localized(ReportScreen(mess: mess)),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
    }

    Future<void> unmount(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(Duration.zero);
    }

    testWidgets('reassures when no meal was changed later', (tester) async {
      await pumpReport(tester);
      expect(find.text('No meals were changed after their day'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('counts late changes and lists them on tap', (tester) async {
      await tester.runAsync(
        () => LocalMealRepository(db, clock: () => DateTime(2026, 9, 25, 9))
            .setMeal(
              messId: mess.id,
              memberId: rahim.id,
              date: DateTime(2026, 9, 24),
              lunch: 1,
              reason: 'Forgot to mark',
            ),
      );
      await pumpReport(tester);

      expect(find.text('1 meal changed after its day'), findsOneWidget);
      await tester.tap(find.text('1 meal changed after its day'));
      await tester.pumpAndSettle();
      expect(find.text('24 Sep · Rahim · Lunch: 0 → 1'), findsOneWidget);
      await unmount(tester);
    });
  });
}

class _September extends SelectedMonthNotifier {
  @override
  SelectedMonth build() => (year: 2026, month: 9);
}
