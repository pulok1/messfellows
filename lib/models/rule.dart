import 'rule_category.dart';

/// A house rule the manager has set for the mess.
class Rule {
  final String id;
  final String messId;
  final String title;
  final String? details;
  final RuleCategory category;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Rule({
    required this.id,
    required this.messId,
    required this.title,
    this.details,
    required this.category,
    this.isImportant = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Rule copyWith({
    String? title,
    String? details,
    bool clearDetails = false,
    RuleCategory? category,
    bool? isImportant,
    DateTime? updatedAt,
  }) {
    return Rule(
      id: id,
      messId: messId,
      title: title ?? this.title,
      details: clearDetails ? null : (details ?? this.details),
      category: category ?? this.category,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
