import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:messfellows/core/theme/app_theme.dart';
import 'package:messfellows/core/utils/date_utils.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/features/meals/meals_screen.dart';
import 'package:messfellows/features/meals/widgets/meal_toggle_button.dart';
import 'package:messfellows/features/meals/widgets/monthly_meals_sheet.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/providers/database_provider.dart';
import 'package:messfellows/providers/selection_providers.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/repositories/local/local_settlement_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  late AppDatabase db;
  late Mess mess;
  late Member rahim;
  late Member karim;
  final today = dateOnly(DateTime.now());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Widget? home,
    DateTime? date,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          if (date != null)
            selectedMealDateProvider.overrideWith(() => _FixedMealDate(date)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: home ?? MealsScreen(mess: mess),
        ),
      ),
    );
    await settle(tester);
  }

  // Unmounts the screen after the body so Drift's zero-duration stream
  // cleanup timers fire before the framework's "no pending timers" check.
  void screenTest(
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(Duration.zero);
    });
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final memberRepo = LocalMemberRepository(db);
    rahim = await memberRepo.addMember(messId: mess.id, name: 'Rahim');
    karim = await memberRepo.addMember(messId: mess.id, name: 'Karim');
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> totalMealsOn(WidgetTester tester, DateTime date) async {
    final meals = await tester.runAsync(
      () => LocalMealRepository(db).watchMealsForDate(mess.id, date).first,
    );
    return meals!.fold<int>(0, (sum, m) => sum + m.totalMeals);
  }

  screenTest('tapping a meal toggle records it', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(MealToggleButton).first);
    await settle(tester);

    expect(await totalMealsOn(tester, today), 1);
  });

  screenTest('shows the day total with extras and each member\'s month count', (
    tester,
  ) async {
    // Pick a day in the same month as today so both land in one month.
    final earlier = today.day > 1 ? addDays(today, -1) : today;
    await tester.runAsync(() async {
      final repo = LocalMealRepository(db);
      await repo.setMeal(messId: mess.id, memberId: rahim.id, date: today, lunch: 2, dinner: 1);
      if (earlier != today) {
        await repo.setMeal(messId: mess.id, memberId: rahim.id, date: earlier, lunch: 1);
      }
    });
    await pumpScreen(tester);

    expect(find.text('3 meals this day · 1 extra'), findsOneWidget);
    expect(
      find.text(earlier != today ? '4 meals this month' : '3 meals this month'),
      findsOneWidget,
    );
    expect(find.text('0 meals this month'), findsOneWidget); // Karim
  });

  screenTest('a member\'s whole day can be marked, turned off and undone', (
    tester,
  ) async {
    await pumpScreen(tester);

    // Karim sorts first; both rows offer "Mark all meals".
    await tester.tap(find.byTooltip('Mark all meals').first);
    await settle(tester);
    expect(find.text('All meals marked for Karim'), findsOneWidget);
    expect(await totalMealsOn(tester, today), 3);

    await tester.tap(find.byTooltip('Turn off all meals'));
    await settle(tester);
    expect(find.text("Karim's meals turned off"), findsOneWidget);
    expect(await totalMealsOn(tester, today), 0);

    // Let the first snackbar finish sliding away so only the latest Undo
    // — the one for turning the day off — is on screen.
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(await totalMealsOn(tester, today), 3);
  });

  screenTest('marking a whole slot can be undone in one tap', (tester) async {
    await pumpScreen(tester);

    // Breakfast is the first progress chip; nobody has had it yet.
    await tester.tap(find.text('0/2').first);
    await settle(tester);
    expect(await totalMealsOn(tester, today), 2);
    expect(find.text('Breakfast marked for 2 members'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(await totalMealsOn(tester, today), 0);
  });

  screenTest('clearing a slot for everyone restores guest meals on undo', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final repo = LocalMealRepository(db);
      await repo.setMeal(messId: mess.id, memberId: rahim.id, date: today, breakfast: 2);
      await repo.setMeal(messId: mess.id, memberId: karim.id, date: today, breakfast: 1);
    });
    await pumpScreen(tester);

    await tester.tap(find.text('2/2'));
    await settle(tester);
    expect(await totalMealsOn(tester, today), 0);
    expect(find.text('Breakfast cleared for everyone'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await settle(tester);
    final entry = await tester.runAsync(
      () => LocalMealRepository(db).getMealEntry(mess.id, rahim.id, today),
    );
    expect(entry!.breakfast, 2);
    expect(await totalMealsOn(tester, today), 3);
  });

  screenTest('an archived member stays visible on days they ate', (tester) async {
    final yesterday = addDays(today, -1);
    await tester.runAsync(() async {
      await LocalMealRepository(
        db,
      ).setMeal(messId: mess.id, memberId: karim.id, date: yesterday, lunch: 1);
      await LocalMemberRepository(db).archiveMember(karim.id);
    });
    await pumpScreen(tester);

    // Today: Karim ate nothing, so only the active member is listed.
    expect(find.text('Karim'), findsNothing);
    expect(find.text('0/1'), findsWidgets);

    await tester.tap(find.byTooltip('Previous day'));
    await settle(tester);

    expect(find.text('Karim'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
    // Progress still counts only the active mess.
    expect(find.text('0/1'), findsWidgets);
  });

  screenTest('the monthly sheet breaks counts down and jumps to missed days', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final repo = LocalMealRepository(db);
      await repo.setMeal(messId: mess.id, memberId: rahim.id, date: DateTime(2026, 2, 26), breakfast: 1, lunch: 1);
      await repo.setMeal(messId: mess.id, memberId: rahim.id, date: DateTime(2026, 2, 28), lunch: 1);
    });
    DateTime? jumpedTo;
    await pumpScreen(
      tester,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showMonthlyMealsSheet(
              context,
              mess: mess,
              year: 2026,
              month: 2,
              onJumpToDay: (day) => jumpedTo = day,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);

    expect(find.text('Total Meals: 3'), findsOneWidget);
    expect(find.text('Breakfast 1 · Lunch 2 · Dinner 0'), findsOneWidget);
    expect(find.text('1 day has no meals recorded'), findsOneWidget);

    await tester.tap(find.text('27 Feb'));
    await tester.pumpAndSettle();
    expect(jumpedTo, DateTime(2026, 2, 27));
    expect(find.byType(MonthlyMealsSheet), findsNothing);
  });

  screenTest('the monthly button is badged with the count of missed days', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final repo = LocalMealRepository(db);
      await repo.setMeal(messId: mess.id, memberId: rahim.id, date: DateTime(2026, 2, 25), lunch: 1);
      await repo.setMeal(messId: mess.id, memberId: rahim.id, date: DateTime(2026, 2, 28), lunch: 1);
    });
    await pumpScreen(tester, date: DateTime(2026, 2, 28));

    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('2')),
      findsOneWidget,
    );
  });

  screenTest('swiping sideways changes the day, but not past tomorrow', (
    tester,
  ) async {
    await pumpScreen(tester);
    String dayLabel(DateTime d) => DateFormat('d MMMM y', 'en').format(d);
    Future<void> fling(double dx) async {
      await tester.fling(find.text('Rahim'), Offset(dx, 0), 1000);
      await settle(tester);
    }

    await fling(300);
    expect(find.text(dayLabel(addDays(today, -1))), findsOneWidget);

    await fling(-300);
    await fling(-300);
    await fling(-300);
    expect(find.text(dayLabel(addDays(today, 1))), findsOneWidget);
  });

  screenTest('a closed month is shown read-only with a way forward', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await LocalMealRepository(
        db,
      ).setMeal(messId: mess.id, memberId: rahim.id, date: today, lunch: 1);
      await LocalSettlementRepository(db).closeMonth(
        messId: mess.id,
        year: today.year,
        month: today.month,
        totalExpense: const Money(0),
        totalMeals: 1,
        mealRate: const Money(0),
        balances: const [],
      );
    });
    await pumpScreen(tester);

    expect(find.textContaining('is closed, so its meals are locked'), findsOneWidget);

    await tester.tap(find.byType(MealToggleButton).first);
    await settle(tester);

    expect(await totalMealsOn(tester, today), 1);
    // Karim is listed too, so the lock isn't hiding anyone.
    expect(find.text(karim.name), findsOneWidget);
  });
}

/// Lets Drift's real async I/O finish and the resulting stream emissions
/// rebuild the screen.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 500));
}

class _FixedMealDate extends SelectedMealDate {
  final DateTime date;

  _FixedMealDate(this.date);

  @override
  DateTime build() => date;
}
