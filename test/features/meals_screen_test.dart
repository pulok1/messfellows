import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messfellows/core/theme/app_theme.dart';
import 'package:messfellows/core/utils/date_utils.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/features/meals/meals_screen.dart';
import 'package:messfellows/features/meals/widgets/meal_toggle_button.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/providers/database_provider.dart';
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

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MealsScreen(mess: mess),
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
