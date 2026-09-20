import '../models/rule.dart';
import '../models/rule_category.dart';

/// What's needed to create a rule; used for batch-adding starter templates.
typedef NewRule = ({
  String title,
  String? details,
  RuleCategory category,
  bool isImportant,
});

abstract interface class RuleRepository {
  /// Rules for the mess, grouped by category (enum order), important ones
  /// first within a category, then oldest first.
  Stream<List<Rule>> watchRules(String messId);

  Future<Rule> addRule({
    required String messId,
    required String title,
    String? details,
    required RuleCategory category,
    bool isImportant = false,
  });

  /// Adds every rule in one transaction (so a failure adds none of them).
  Future<void> addRules(String messId, List<NewRule> rules);

  Future<void> updateRule(Rule rule);

  Future<void> deleteRule(String id);
}
