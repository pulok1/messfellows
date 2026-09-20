import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messfellows/core/theme/app_theme.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/features/rules/rule_templates_sheet.dart';
import 'package:messfellows/features/rules/rules_screen.dart';
import 'package:messfellows/features/rules/rules_summary_card.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/models/rule_category.dart';
import 'package:messfellows/providers/database_provider.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/repositories/local/local_rule_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  late AppDatabase db;
  late Mess mess;

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1.0,
    Size size = const Size(360, 720),
    Widget? home,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: home ?? RulesScreen(messId: mess.id),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
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
    mess = await LocalMessRepository(db).createMess(
      name: 'Test Mess',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
  });

  tearDown(() async {
    await db.close();
  });

  screenTest('shows the empty state when there are no rules', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Rules & Regulations'), findsOneWidget);
    expect(find.text('No rules yet'), findsOneWidget);
    expect(find.text('Add rule'), findsOneWidget); // the FAB
    expect(find.textContaining('Last updated'), findsNothing);
  });

  screenTest('groups rules by category, numbers them and flags important ones', (
    tester,
  ) async {
    final repo = LocalRuleRepository(db);
    await tester.runAsync(() async {
      await repo.addRule(
        messId: mess.id,
        title: 'Keep quiet at night',
        category: RuleCategory.quietHours,
      );
      await repo.addRule(
        messId: mess.id,
        title: 'Pay by the 5th',
        details: 'Late payments hold up the settlement.',
        category: RuleCategory.payments,
        isImportant: true,
      );
    });
    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Quiet hours'), findsOneWidget);
    expect(find.text('Pay by the 5th'), findsOneWidget);
    expect(find.text('Late payments hold up the settlement.'), findsOneWidget);
    expect(find.text('Important'), findsOneWidget);
    // Payments is declared before quiet hours, so it is rule 1.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
  });

  screenTest('adds a rule through the dialog', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();
    expect(find.text('Mark as important'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'No shoes indoors');
    await tester.tap(find.text('Cleanliness'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('No shoes indoors'), findsOneWidget);
    expect(find.text('Cleanliness'), findsOneWidget);
  });

  screenTest('rejects an empty title in the dialog', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Enter the rule'), findsOneWidget);
  });

  screenTest('the dashboard card prompts to set rules up when there are none', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      home: Scaffold(body: RulesSummaryCard(messId: mess.id)),
    );

    expect(find.text('Set your mess rules'), findsOneWidget);
    expect(find.textContaining('rules'), findsWidgets);

    await tester.tap(find.byType(RulesSummaryCard));
    await tester.pumpAndSettle();
    expect(find.byType(RulesScreen), findsOneWidget);
    expect(find.text('No rules yet'), findsOneWidget);
  });

  screenTest('the dashboard card summarises the rules and when they changed', (
    tester,
  ) async {
    final repo = LocalRuleRepository(db);
    await tester.runAsync(() async {
      await repo.addRule(
        messId: mess.id,
        title: 'Pay by the 5th',
        category: RuleCategory.payments,
        isImportant: true,
      );
      await repo.addRule(
        messId: mess.id,
        title: 'Quiet at night',
        category: RuleCategory.quietHours,
      );
    });
    await pumpScreen(
      tester,
      home: Scaffold(body: RulesSummaryCard(messId: mess.id)),
    );
    await tester.pump();

    expect(find.text('Rules & Regulations'), findsOneWidget);
    expect(find.text('2 rules · 1 important'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
  });

  screenTest('adds suggested rules from the templates sheet', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Start from suggested rules'));
    await tester.pumpAndSettle();
    expect(find.text('Suggested rules'), findsOneWidget);
    expect(find.text('Tell the manager before skipping a meal'), findsOneWidget);

    // Nothing is preselected, so the add button starts disabled.
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Add 0 rules')).onPressed,
      isNull,
    );

    await tester.tap(find.text('Tell the manager before skipping a meal'));
    // The list is lazy, so scroll the later template into view first.
    await tester.scrollUntilVisible(
      find.text('Pay your monthly share by the 5th'),
      100,
      scrollable: find.descendant(
        of: find.byType(RuleTemplatesSheet),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(find.text('Pay your monthly share by the 5th'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay your monthly share by the 5th'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add 2 rules'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('2 rules added'), findsOneWidget); // snackbar
    // The important templates arrive flagged, grouped under their category.
    expect(find.text('Important'), findsNWidgets(2));
    expect(find.text('Meals'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
  });

  screenTest('hides suggestions that were already added and offers select-all', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await LocalRuleRepository(db).addRule(
        messId: mess.id,
        title: '  Keep quiet from 11 PM to 6 AM ',
        category: RuleCategory.quietHours,
      );
    });
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pumpAndSettle();

    // Scoped to the sheet: the rule itself is (correctly) still on the
    // screen behind it.
    expect(
      find.descendant(
        of: find.byType(RuleTemplatesSheet),
        matching: find.text('Keep quiet from 11 PM to 6 AM'),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Select all'));
    await tester.pump();
    expect(find.text('Clear'), findsOneWidget);
    // 11 templates minus the one that's already a rule.
    expect(find.widgetWithText(FilledButton, 'Add 10 rules'), findsOneWidget);
  });

  screenTest('does not overflow on a small phone with large text, in Bangla', (
    tester,
  ) async {
    final repo = LocalRuleRepository(db);
    await tester.runAsync(() async {
      await repo.addRule(
        messId: mess.id,
        title:
            'রান্না ও খাওয়ার পর নিজের থালা ধুয়ে রাখুন এবং কাউন্টার ও চুলা মুছে দিন সবসময়',
        details:
            'বিল সবাই মিলে ভাগ হয়, তাই অপচয় এড়িয়ে চলুন। ' * 6,
        category: RuleCategory.cleanliness,
        isImportant: true,
      );
    });
    // Collect the full error details (not just the message) so a failure
    // names the widget that overflowed.
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = errors.add;

    await pumpScreen(
      tester,
      locale: const Locale('bn'),
      textScale: 1.6,
      size: const Size(320, 568),
    );
    await tester.pump();
    FlutterError.onError = originalOnError;

    expect(
      errors,
      isEmpty,
      reason: errors.map((e) => e.toString()).join('\n---\n'),
    );
    expect(find.text('গুরুত্বপূর্ণ'), findsOneWidget);
  });
}
