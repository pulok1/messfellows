import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/theme/app_theme.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/features/dashboard/widgets/insights_card.dart';
import 'package:messfellows/l10n/gen/app_localizations.dart';
import 'package:messfellows/models/insight.dart';
import 'package:messfellows/providers/insight_providers.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    List<Insight> insights, {
    Locale locale = const Locale('en'),
    double textScale = 1.0,
    Size size = const Size(360, 720),
    VoidCallback? onOpenMeals,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardInsightsProvider.overrideWith((ref, _) => insights),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: InsightsCard(
                messId: 'm',
                currencySymbol: '৳',
                onOpenMeals: onOpenMeals,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final all = <Insight>[
    const MealsNotMarkedToday(),
    const NoRecentBazar(4),
    MealRateChange(percent: -12, previousRate: Money.fromMajor(62.5)),
    const MembersWithoutBazar(['Rahul', 'Prottoy', 'Pulok', 'Nabil']),
    BazarProjection(Money.fromMajor(18200)),
  ];

  testWidgets('renders nothing when there are no insights', (tester) async {
    await pumpCard(tester, const []);
    expect(find.text('Insights'), findsNothing);
  });

  testWidgets('shows the top three insights in plain words', (tester) async {
    var openedMeals = false;
    await pumpCard(tester, all, onOpenMeals: () => openedMeals = true);

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text("Today's meals aren't marked yet"), findsOneWidget);
    expect(find.text('No bazar logged in the last 4 days'), findsOneWidget);
    expect(
      find.text('Meal rate is 12% lower than last month (৳62.50)'),
      findsOneWidget,
    );
    // Only the three most useful are shown.
    expect(find.textContaining('bazar run'), findsNothing);

    await tester.tap(find.text('Mark'));
    expect(openedMeals, isTrue);
  });

  testWidgets('summarizes long member lists', (tester) async {
    await pumpCard(tester, [all[3], all[4]]);
    expect(
      find.text("Rahul, Prottoy, 2 others haven't done a bazar run this month"),
      findsOneWidget,
    );
    expect(
      find.text('At this pace, bazar will reach about ৳18,200 this month'),
      findsOneWidget,
    );
  });

  testWidgets('does not overflow on a small phone with large text, in Bangla', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = errors.add;

    await pumpCard(
      tester,
      all,
      locale: const Locale('bn'),
      textScale: 1.6,
      size: const Size(320, 568),
      onOpenMeals: () {},
    );

    FlutterError.onError = originalOnError;
    expect(errors, isEmpty);
    expect(find.text('এক নজরে'), findsOneWidget);
  });
}
