import 'package:drift/drift.dart';

import 'member_table.dart';
import 'mess_table.dart';

/// One member's meal record for one calendar day. [date] is stored at
/// midnight UTC-naive (see `DateUtils.dateOnly` usage at the call sites) so
/// the unique key below reliably catches duplicates regardless of the time
/// of day the entry was created.
@DataClassName('MealEntryRow')
class MealEntries extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  TextColumn get memberId => text().references(Members, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get breakfast => boolean().withDefault(const Constant(false))();
  BoolColumn get lunch => boolean().withDefault(const Constant(false))();
  BoolColumn get dinner => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  // A member can have only one meal record for a given date.
  @override
  List<Set<Column>> get uniqueKeys => [
    {messId, memberId, date},
  ];
}
