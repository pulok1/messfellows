import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/constants/app_constants.dart';
import 'package:messfellows/core/services/backup_service.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/rule_category.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/repositories/local/local_rule_repository.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  // Each test deliberately opens two databases (export source + import target).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('rules and the rules-updated stamp survive an export/import round trip', () async {
    final mess = await LocalMessRepository(source).createMess(
      name: 'Round Trip',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
    final rules = LocalRuleRepository(source);
    await rules.addRule(
      messId: mess.id,
      title: 'Pay by the 5th',
      details: 'Late payers settle first next month',
      category: RuleCategory.payments,
      isImportant: true,
    );
    await rules.addRule(
      messId: mess.id,
      title: 'Quiet after 11 PM',
      category: RuleCategory.quietHours,
    );
    final exportedMess = (await LocalMessRepository(source).watchMess().first)!;

    final json = await BackupService(source).exportToJson();
    expect(jsonDecode(json)['schemaVersion'], AppConstants.backupFormatVersion);

    await BackupService(target).importFromJson(json);

    final restored = await LocalRuleRepository(target).watchRules(mess.id).first;
    expect(restored.map((r) => r.title), ['Pay by the 5th', 'Quiet after 11 PM']);
    expect(restored.first.details, 'Late payers settle first next month');
    expect(restored.first.category, RuleCategory.payments);
    expect(restored.first.isImportant, isTrue);
    expect(restored.last.details, isNull);

    final restoredMess = (await LocalMessRepository(target).watchMess().first)!;
    expect(restoredMess.rulesUpdatedAt, exportedMess.rulesUpdatedAt);
  });

  test('a backup from before rules existed still imports, with no rules', () async {
    final mess = await LocalMessRepository(source).createMess(
      name: 'Old',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
    final document =
        jsonDecode(await BackupService(source).exportToJson())
            as Map<String, dynamic>;
    document
      ..['schemaVersion'] = 4
      ..remove('rules');
    (document['mess'] as Map<String, dynamic>).remove('rulesUpdatedAt');

    await BackupService(target).importFromJson(jsonEncode(document));

    expect(await LocalRuleRepository(target).watchRules(mess.id).first, isEmpty);
    final restoredMess = (await LocalMessRepository(target).watchMess().first)!;
    expect(restoredMess.rulesUpdatedAt, isNull);
  });

  test('an unknown rule category degrades to "other" instead of failing', () async {
    final mess = await LocalMessRepository(source).createMess(
      name: 'Future',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
    await LocalRuleRepository(source).addRule(
      messId: mess.id,
      title: 'From the future',
      category: RuleCategory.meals,
    );
    final document =
        jsonDecode(await BackupService(source).exportToJson())
            as Map<String, dynamic>;
    ((document['rules'] as List).single as Map<String, dynamic>)['category'] =
        'somethingNew';

    await BackupService(target).importFromJson(jsonEncode(document));

    final restored = await LocalRuleRepository(target).watchRules(mess.id).first;
    expect(restored.single.category, RuleCategory.other);
  });

  test('importing replaces rules that were already on the device', () async {
    final mess = await LocalMessRepository(source).createMess(
      name: 'Source',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
    final json = await BackupService(source).exportToJson();

    final targetMess = await LocalMessRepository(target).createMess(
      name: 'Target',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
    await LocalRuleRepository(target).addRule(
      messId: targetMess.id,
      title: 'Will be replaced',
      category: RuleCategory.other,
    );

    await BackupService(target).importFromJson(json);

    expect(await target.select(target.messRules).get(), isEmpty);
    expect((await LocalMessRepository(target).watchMess().first)!.id, mess.id);
  });
}
