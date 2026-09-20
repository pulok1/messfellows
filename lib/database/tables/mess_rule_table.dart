import 'package:drift/drift.dart';

import '../../models/rule_category.dart';
import 'mess_table.dart';

/// A house rule the manager has set for the mess.
@DataClassName('MessRuleRow')
class MessRules extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get details => text().nullable()();
  TextColumn get category => textEnum<RuleCategory>().withDefault(
    Constant(RuleCategory.other.name),
  )();
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
