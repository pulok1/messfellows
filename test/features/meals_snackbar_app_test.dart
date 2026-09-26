import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/main.dart';
import 'package:messfellows/providers/database_provider.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';

/// Runs the Meals tab inside the real app shell — its IndexedStack of
/// tabs, each with its own Scaffold — rather than on its own.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Test Mess', currencyCode: 'BDT', currencySymbol: '৳');
    await LocalMemberRepository(db).addMember(messId: mess.id, name: 'Rahim');
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('the meals confirmation dismisses itself in the real app', (
    tester,
  ) async {
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MessFellowsApp(),
      ),
    );
    await settle();
    await tester.tap(find.text('Meals').last);
    await settle();

    await tester.tap(find.byTooltip('Mark all meals'));
    await settle();
    expect(find.text('All meals marked for Rahim'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('All meals marked for Rahim'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(Duration.zero);
  });
}
