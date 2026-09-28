import 'package:drift/drift.dart';

import '../../models/activity_type.dart';
import '../../models/meal_slot.dart';
import 'member_table.dart';
import 'mess_table.dart';

/// A permanent record of meaningful changes (added/edited/deleted/restored
/// bazar entries and payments, member lifecycle, rules, month close/reopen)
/// — the Activity Log's source. Unlike the Recycle Bin this never
/// auto-purges; it's meant to be a lasting history, not an undo buffer.
@DataClassName('ActivityLogRow')
class ActivityLogs extends Table {
  TextColumn get id => text()();
  TextColumn get messId => text().references(Messes, #id)();
  TextColumn get type => textEnum<ActivityType>()();

  // The member the event is about (payer/payee/the member added or
  // archived) — never "who tapped the button", since this app has no
  // login/current-user concept to attribute that to.
  TextColumn get memberId => text().nullable().references(Members, #id)();

  IntColumn get amountMinorUnits => integer().nullable()();

  // Free-text that never needs translation: a bazar list, a payment note,
  // or a rule title.
  TextColumn get detail => text().nullable()();

  // Only set for monthClosed/monthReopened, so the month name renders in
  // whatever language is active when the log is *read*, not frozen into
  // English at write time.
  IntColumn get year => integer().nullable()();
  IntColumn get month => integer().nullable()();

  // Only set for rulesBulkAdded (starter templates), so it can read as
  // "5 starter rules added" instead of 5 separate identical-looking rows.
  // Also the new meal count for mealChangedLater, whose reason is [detail].
  IntColumn get count => integer().nullable()();

  // Only set for mealChangedLater: the day and slot that changed, and the
  // count it had before, so the entry reads "Lunch 0 → 1 on 24 Sep".
  DateTimeColumn get mealDate => dateTime().nullable()();
  TextColumn get mealSlot => textEnum<MealSlot>().nullable()();
  IntColumn get previousCount => integer().nullable()();

  // Set on bazarEdited/paymentEdited/ruleUpdated when the amount or the
  // free-text (bazar list / note / rule title) actually changed, so the
  // entry can show "was X, now Y" instead of only the new value. Null
  // when that particular field didn't change in this edit.
  IntColumn get previousAmountMinorUnits => integer().nullable()();
  TextColumn get previousDetail => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
