import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messfellows/core/theme/app_theme.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/features/activity_log/activity_log_screen.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/providers/database_provider.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  late AppDatabase db;
  late Mess mess;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final rahim = await LocalMemberRepository(
      db,
    ).addMember(messId: mess.id, name: 'Rahim');
    // "Now" is the 25th, so the 24th is a past day and gets logged.
    await LocalMealRepository(db, clock: () => DateTime(2026, 9, 25, 9)).setMeal(
      messId: mess.id,
      memberId: rahim.id,
      date: DateTime(2026, 9, 24),
      lunch: 1,
      reason: 'Forgot to mark',
    );
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('late meal changes are listed under the Meals filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: ActivityLogScreen(messId: mess.id),
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(ChoiceChip, 'Meals'));
    await tester.pumpAndSettle();

    expect(find.text('Meal changed later'), findsOneWidget);
    expect(
      find.textContaining('Rahim · 24 Sep 2026 · Lunch: 0 → 1 · Forgot to mark'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(Duration.zero);
  });
}
