import 'package:drift/drift.dart';

import 'member_table.dart';
import 'mess_table.dart';

/// A member's contribution of money into the mess (distinct from an
/// [Expenses] record, which is money spent on food).
@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get memberId => text().references(Members, #id)();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Soft-delete: set when the payment is removed so it can sit in the
  // Recycle Bin instead of disappearing outright. Null means active.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
