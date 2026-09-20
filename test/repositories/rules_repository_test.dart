import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/errors/app_exception.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/models/rule_category.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/repositories/local/local_rule_repository.dart';

void main() {
  late AppDatabase db;
  late LocalMessRepository messRepo;
  late LocalRuleRepository ruleRepo;
  late Mess mess;

  Future<Mess> reloadMess() async => (await messRepo.watchMess().first)!;

  // DateTime columns have whole-second precision, so "did the stamp move?"
  // is tested against a fixed old value rather than a just-written one.
  final longAgo = DateTime(2020);
  Future<void> setStampToLongAgo() => (db.update(db.messes)).write(
    MessesCompanion(rulesUpdatedAt: Value(longAgo)),
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    messRepo = LocalMessRepository(db);
    ruleRepo = LocalRuleRepository(db);
    mess = await messRepo.createMess(
      name: 'Test Mess',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('a new mess has no rules and no rules-updated stamp', () async {
    expect(await ruleRepo.watchRules(mess.id).first, isEmpty);
    expect(mess.rulesUpdatedAt, isNull);
  });

  test('addRule trims input, stores it and stamps the mess', () async {
    final rule = await ruleRepo.addRule(
      messId: mess.id,
      title: '  Pay by the 5th  ',
      details: '   ',
      category: RuleCategory.payments,
      isImportant: true,
    );

    expect(rule.title, 'Pay by the 5th');
    expect(rule.details, isNull);

    final rules = await ruleRepo.watchRules(mess.id).first;
    expect(rules.single.title, 'Pay by the 5th');
    expect(rules.single.isImportant, isTrue);
    expect((await reloadMess()).rulesUpdatedAt, isNotNull);
  });

  test('an empty title is rejected', () async {
    expect(
      () => ruleRepo.addRule(
        messId: mess.id,
        title: '   ',
        category: RuleCategory.other,
      ),
      throwsA(isA<ValidationException>()),
    );
    expect(await ruleRepo.watchRules(mess.id).first, isEmpty);
  });

  test('a rule for a non-existent mess is rejected by the foreign key', () async {
    expect(
      () => ruleRepo.addRule(
        messId: 'no-such-mess',
        title: 'Orphan',
        category: RuleCategory.other,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('rules are grouped by category, important first, then oldest first', () async {
    Future<void> add(String title, RuleCategory c, {bool important = false}) {
      return ruleRepo.addRule(
        messId: mess.id,
        title: title,
        category: c,
        isImportant: important,
      );
    }

    await add('Quiet after 11', RuleCategory.quietHours);
    await add('Guest notice', RuleCategory.guests);
    await add('Skip meal early', RuleCategory.meals);
    await add('Guest fee', RuleCategory.guests, important: true);
    await add('Log every meal', RuleCategory.meals);

    final titles = (await ruleRepo.watchRules(mess.id).first)
        .map((r) => r.title)
        .toList();

    expect(titles, [
      'Skip meal early',
      'Log every meal',
      'Guest fee',
      'Guest notice',
      'Quiet after 11',
    ]);
  });

  test('updateRule persists edits and bumps the stamp', () async {
    final rule = await ruleRepo.addRule(
      messId: mess.id,
      title: 'Old',
      category: RuleCategory.other,
    );
    await setStampToLongAgo();

    await ruleRepo.updateRule(
      rule.copyWith(
        title: 'New',
        details: 'More info',
        category: RuleCategory.cleanliness,
        isImportant: true,
      ),
    );

    final updated = (await ruleRepo.watchRules(mess.id).first).single;
    expect(updated.title, 'New');
    expect(updated.details, 'More info');
    expect(updated.category, RuleCategory.cleanliness);
    expect(updated.isImportant, isTrue);
    expect((await reloadMess()).rulesUpdatedAt!.isAfter(longAgo), isTrue);
  });

  test('deleteRule removes the rule and still bumps the stamp', () async {
    final rule = await ruleRepo.addRule(
      messId: mess.id,
      title: 'Temp',
      category: RuleCategory.other,
    );
    await setStampToLongAgo();

    await ruleRepo.deleteRule(rule.id);

    expect(await ruleRepo.watchRules(mess.id).first, isEmpty);
    expect((await reloadMess()).rulesUpdatedAt!.isAfter(longAgo), isTrue);
  });

  test('batch-added rules keep the order they were given in', () async {
    await ruleRepo.addRules(mess.id, [
      for (final t in ['One', 'Two', 'Three', 'Four'])
        (title: t, details: null, category: RuleCategory.meals, isImportant: false),
    ]);

    final titles = (await ruleRepo.watchRules(mess.id).first).map((r) => r.title);
    expect(titles, ['One', 'Two', 'Three', 'Four']);
  });

  test('addRules adds all of them, or none if one is invalid', () async {
    await ruleRepo.addRules(mess.id, [
      (title: 'A', details: null, category: RuleCategory.meals, isImportant: false),
      (title: 'B', details: 'x', category: RuleCategory.bazar, isImportant: true),
    ]);
    expect((await ruleRepo.watchRules(mess.id).first).length, 2);

    await expectLater(
      ruleRepo.addRules(mess.id, [
        (title: 'C', details: null, category: RuleCategory.meals, isImportant: false),
        (title: ' ', details: null, category: RuleCategory.meals, isImportant: false),
      ]),
      throwsA(isA<ValidationException>()),
    );
    expect((await ruleRepo.watchRules(mess.id).first).length, 2);
  });

  test('deleteAllData also clears rules', () async {
    await ruleRepo.addRule(
      messId: mess.id,
      title: 'Rule',
      category: RuleCategory.other,
    );

    await messRepo.deleteAllData();

    expect(await db.select(db.messRules).get(), isEmpty);
    expect(await db.select(db.messes).get(), isEmpty);
  });
}
