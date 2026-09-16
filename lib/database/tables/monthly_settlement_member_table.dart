import 'package:drift/drift.dart';

import 'member_table.dart';
import 'monthly_settlement_table.dart';

/// One member's frozen result within a [MonthlySettlements] snapshot.
@DataClassName('MonthlySettlementMemberRow')
class MonthlySettlementMembers extends Table {
  TextColumn get id => text()();
  TextColumn get settlementId => text().references(MonthlySettlements, #id)();
  TextColumn get memberId => text().references(Members, #id)();
  IntColumn get mealCount => integer()();
  IntColumn get mealCostMinorUnits => integer()();
  IntColumn get paidAmountMinorUnits => integer()();
  IntColumn get balanceMinorUnits => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {settlementId, memberId},
  ];
}
