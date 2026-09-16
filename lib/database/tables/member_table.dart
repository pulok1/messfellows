import 'package:drift/drift.dart';

import 'mess_table.dart';

/// A person tracked within a mess. Members are never hard-deleted —
/// [isActive]/[leftAt] mark them archived instead — so historical meal,
/// expense and settlement records they're referenced by stay valid.
@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get joinedAt => dateTime()();
  DateTimeColumn get leftAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
