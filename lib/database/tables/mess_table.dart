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

  // Not every mess serves all three meals (many only do lunch & dinner) —
  // these decide which slots the meal tracker shows. Default true so
  // existing messes keep seeing all three exactly as before.
  BoolColumn get trackBreakfast => boolean().withDefault(const Constant(true))();
  BoolColumn get trackLunch => boolean().withDefault(const Constant(true))();
  BoolColumn get trackDinner => boolean().withDefault(const Constant(true))();

  // When the mess rules last changed (added/edited/deleted) — shown as
  // "Last updated" on the Rules screen. Null until a rule is first saved.
  DateTimeColumn get rulesUpdatedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
