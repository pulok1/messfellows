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
  // A meal count rather than a plain yes/no so a slot can hold 2+ when an
  // extra/guest meal is recorded under this member.
  IntColumn get breakfast => integer().withDefault(const Constant(0))();
  IntColumn get lunch => integer().withDefault(const Constant(0))();
  IntColumn get dinner => integer().withDefault(const Constant(0))();
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
