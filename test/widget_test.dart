// Smoke test for the app shell. Overrides currentMessProvider instead of
// letting AppDatabase touch a real file/platform channel, which isn't
// available in the widget-test environment.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:messfellows/main.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/providers/mess_provider.dart';

void main() {
  testWidgets('shows onboarding when no mess exists yet', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentMessProvider.overrideWith((ref) => Stream<Mess?>.value(null))],
        child: const MessFellowsApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome to Mess Fellows'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create Mess'), findsOneWidget);
  });
}
