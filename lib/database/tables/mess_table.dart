import 'package:drift/drift.dart';

/// A single mess (household/group). The MVP supports exactly one, but the
/// schema doesn't assume that — a manager could in principle run several.
///
/// Named `MessRow` (rather than the default `Mess`) so the generated row
/// class doesn't collide with the domain model `Mess` in lib/models — both
/// are imported together in the repository layer that maps one to the
/// other.
@DataClassName('MessRow')
class Messes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get currencyCode => text().withDefault(const Constant('BDT'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('৳'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
