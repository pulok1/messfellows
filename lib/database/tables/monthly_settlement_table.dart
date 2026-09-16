import 'package:drift/drift.dart';

import '../../models/settlement_status.dart';
import 'mess_table.dart';

/// A frozen snapshot of one calendar month's totals, produced when the
/// manager closes the month. Per-member results live in
/// [MonthlySettlementMembers].
@DataClassName('MonthlySettlementRow')
class MonthlySettlements extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  IntColumn get month => integer()(); // 1-12
  IntColumn get year => integer()();
  IntColumn get totalExpenseMinorUnits => integer()();
  IntColumn get totalMeals => integer()();
  IntColumn get mealRateMinorUnits => integer()();
  TextColumn get status =>
      textEnum<SettlementStatus>().withDefault(Constant(SettlementStatus.open.name))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  // One settlement per mess per calendar month.
  @override
  List<Set<Column>> get uniqueKeys => [
    {messId, month, year},
  ];
}
