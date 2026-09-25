import 'package:drift/drift.dart';

import 'member_table.dart';
import 'mess_table.dart';

/// Money spent buying food (bazar) or other mess supplies. Distinct from a
/// [Payments] record: an expense is money going out for the group, a
/// payment is a member's contribution coming in.
@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get paidByMemberId => text().references(Members, #id)();
  TextColumn get bazarList => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Soft-delete: set when the entry is removed so it can sit in the
  // Recycle Bin instead of disappearing outright. Null means active.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
