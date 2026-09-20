import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/id_generator.dart';
import '../../database/app_database.dart';
import '../../models/rule.dart';
import '../../models/rule_category.dart';
import '../rule_repository.dart';

class LocalRuleRepository implements RuleRepository {
  final AppDatabase _db;

  LocalRuleRepository(this._db);

  Rule _toModel(MessRuleRow row) => Rule(
    id: row.id,
    messId: row.messId,
    title: row.title,
    details: row.details,
    category: row.category,
    isImportant: row.isImportant,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  String _cleanTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('A rule needs a title.');
    }
    return trimmed;
  }

  String? _cleanDetails(String? details) {
    final trimmed = details?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Stamps the mess with "rules last changed now". Always called inside
  /// the same transaction as the rule write it belongs to.
  Future<void> _touchRules(String messId, DateTime now) {
    return (_db.update(_db.messes)..where((t) => t.id.equals(messId))).write(
      MessesCompanion(rulesUpdatedAt: Value(now)),
    );
  }

  @override
  Stream<List<Rule>> watchRules(String messId) {
    // Insertion order (rowid) is the tie-break: DateTime columns are stored
    // at whole-second precision, so createdAt can't order rules that were
    // added together (e.g. a batch of starter templates).
    final query = _db.select(_db.messRules)
      ..where((t) => t.messId.equals(messId))
      ..orderBy([(t) => OrderingTerm.asc(CustomExpression<int>('rowid'))]);
    return query.watch().map((rows) {
      final indexed = [
        for (final (i, row) in rows.indexed) (i, _toModel(row)),
      ];
      // List.sort isn't stable, so the original position is the final key.
      indexed.sort((a, b) {
        final byCategory = a.$2.category.index.compareTo(b.$2.category.index);
        if (byCategory != 0) return byCategory;
        if (a.$2.isImportant != b.$2.isImportant) {
          return a.$2.isImportant ? -1 : 1;
        }
        return a.$1.compareTo(b.$1);
      });
      return [for (final entry in indexed) entry.$2];
    });
  }

  @override
  Future<Rule> addRule({
    required String messId,
    required String title,
    String? details,
    required RuleCategory category,
    bool isImportant = false,
  }) async {
    final cleanTitle = _cleanTitle(title);
    final cleanDetails = _cleanDetails(details);
    final now = DateTime.now();
    final id = IdGenerator.generate();

    await _db.transaction(() async {
      await _db
          .into(_db.messRules)
          .insert(
            MessRulesCompanion.insert(
              id: id,
              messId: messId,
              title: cleanTitle,
              details: Value(cleanDetails),
              category: Value(category),
              isImportant: Value(isImportant),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _touchRules(messId, now);
    });

    return Rule(
      id: id,
      messId: messId,
      title: cleanTitle,
      details: cleanDetails,
      category: category,
      isImportant: isImportant,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> addRules(String messId, List<NewRule> rules) async {
    if (rules.isEmpty) return;
    final cleaned = [for (final rule in rules) (rule, _cleanTitle(rule.title))];
    final now = DateTime.now();

    await _db.transaction(() async {
      for (final (rule, title) in cleaned) {
        await _db
            .into(_db.messRules)
            .insert(
              MessRulesCompanion.insert(
                id: IdGenerator.generate(),
                messId: messId,
                title: title,
                details: Value(_cleanDetails(rule.details)),
                category: Value(rule.category),
                isImportant: Value(rule.isImportant),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      await _touchRules(messId, now);
    });
  }

  @override
  Future<void> updateRule(Rule rule) async {
    final title = _cleanTitle(rule.title);
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.messRules)..where((t) => t.id.equals(rule.id)))
          .write(
            MessRulesCompanion(
              title: Value(title),
              details: Value(_cleanDetails(rule.details)),
              category: Value(rule.category),
              isImportant: Value(rule.isImportant),
              updatedAt: Value(now),
            ),
          );
      await _touchRules(rule.messId, now);
    });
  }

  @override
  Future<void> deleteRule(String id) async {
    await _db.transaction(() async {
      final row = await (_db.select(
        _db.messRules,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (_db.delete(_db.messRules)..where((t) => t.id.equals(id))).go();
      await _touchRules(row.messId, DateTime.now());
    });
  }
}
