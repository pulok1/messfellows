import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/utils/money.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/member.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/repositories/local/local_meal_repository.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/repositories/local/local_payment_repository.dart';
import 'package:messfellows/sync/local_sync_store.dart';
import 'package:messfellows/sync/sync_record.dart';

void main() {
  // Some tests stand up a second in-memory database as "the other phone".
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late LocalSyncStore store;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = LocalSyncStore(db);
  });
  tearDown(() => db.close());

  Future<(Mess, Member)> seed(AppDatabase db) async {
    final mess = await LocalMessRepository(
      db,
    ).createMess(name: 'Mess', currencyCode: 'BDT', currencySymbol: '৳');
    final member = await LocalMemberRepository(
      db,
    ).addMember(messId: mess.id, name: 'Alice');
    return (mess, member);
  }

  Future<List<SyncRecord>> drain(LocalSyncStore store) async {
    final changes = await store.pendingChanges();
    await store.markPushed(changes.map((c) => c.seq));
    return [for (final c in changes) c.record];
  }

  test('local writes are queued once per row, deletes as tombstones', () async {
    final (mess, member) = await seed(db);
    final payments = LocalPaymentRepository(db);
    final payment = await payments.addPayment(
      messId: mess.id,
      date: DateTime(2026, 10, 1),
      memberId: member.id,
      amount: Money.fromMajor(500),
    );
    await payments.updatePayment(payment.copyWith(note: 'cash'));

    var queued = await store.pendingChanges();
    final paymentChange = queued.singleWhere(
      (c) => c.record.table == 'payments',
    );
    expect(paymentChange.record.data!['note'], 'cash');
    expect(queued.map((c) => c.record.table), contains('messes'));

    await payments.permanentlyDeletePayment(payment.id);
    queued = await store.pendingChanges();
    final tombstone = queued.singleWhere((c) => c.record.table == 'payments');
    expect(tombstone.record.deleted, isTrue);
    expect(tombstone.record.rowId, payment.id);
  });

  test('only the pushed outbox entries are cleared', () async {
    final (mess, _) = await seed(db);
    final changes = await store.pendingChanges();
    // The mess is edited again while its first version is being uploaded.
    await LocalMessRepository(db).updateMess(mess.copyWith(name: 'Renamed'));
    await store.markPushed(changes.map((c) => c.seq));

    final left = await store.pendingChanges();
    expect(left.single.record.table, 'messes');
    expect(left.single.record.data!['name'], 'Renamed');
  });

  test('rows pulled from the cloud land locally without being re-queued', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    final (mess, member) = await seed(source);
    await LocalMealRepository(source, clock: () => DateTime(2000)).setMeal(
      messId: mess.id,
      memberId: member.id,
      date: DateTime(2026, 10, 5),
      lunch: 1,
    );
    final records = await drain(LocalSyncStore(source));

    final messStream = LocalMessRepository(db).watchMess();
    expect(await messStream.first, isNull);

    expect(await store.applyRemote(records), records.length);
    expect((await LocalMessRepository(db).watchMess().first)?.name, 'Mess');
    expect(
      await LocalMealRepository(db).getMealEntry(
        mess.id,
        member.id,
        DateTime(2026, 10, 5),
      ),
      isNotNull,
    );
    expect(await store.pendingCount(), 0);

    // Applying the same rows again is a no-op.
    expect(await store.applyRemote(records), 0);
  });

  test('a row with an unpushed local edit is not overwritten', () async {
    final (mess, _) = await seed(db);
    await drain(store);
    await LocalMessRepository(db).updateMess(mess.copyWith(name: 'Local'));

    final remoteRow = (await LocalMessRepository(db).watchMess().first)!;
    await store.applyRemote([
      SyncRecord(
        table: 'messes',
        rowId: mess.id,
        data: {
          'id': mess.id,
          'name': 'Remote',
          'updated_at': remoteRow.updatedAt.millisecondsSinceEpoch ~/ 1000,
        },
        deleted: false,
      ),
    ]);
    expect((await LocalMessRepository(db).watchMess().first)!.name, 'Local');
  });

  test('two meal rows for the same member and day keep the smaller id', () async {
    final (mess, member) = await seed(db);
    final meals = LocalMealRepository(db, clock: () => DateTime(2000));
    await meals.setMeal(
      messId: mess.id,
      memberId: member.id,
      date: DateTime(2026, 10, 5),
      lunch: 1,
    );
    final local = (await drain(store)).singleWhere(
      (r) => r.table == 'meal_entries',
    );

    // Another phone recorded the same day under a different id.
    Future<List<SyncRecord>> pending() async =>
        [for (final c in await store.pendingChanges()) c.record];
    // v4 UUIDs never sort below/above these, whatever the local one is.
    const smaller = '00000000-0000-4000-8000-000000000000';
    const larger = 'ffffffff-ffff-4fff-bfff-ffffffffffff';

    await store.applyRemote([
      SyncRecord(
        table: 'meal_entries',
        rowId: larger,
        data: {...local.data!, 'id': larger, 'lunch': 2},
        deleted: false,
      ),
    ]);
    var entry = await meals.getMealEntry(mess.id, member.id, DateTime(2026, 10, 5));
    expect(entry!.id, local.rowId, reason: 'local id is smaller, so it stays');
    expect((await pending()).single.rowId, larger);
    expect((await pending()).single.deleted, isTrue);

    await store.applyRemote([
      SyncRecord(
        table: 'meal_entries',
        rowId: smaller,
        data: {...local.data!, 'id': smaller, 'lunch': 3},
        deleted: false,
      ),
    ]);
    entry = await meals.getMealEntry(mess.id, member.id, DateTime(2026, 10, 5));
    expect(entry!.id, smaller);
    expect(entry.lunch, 3);
    expect(
      (await pending()).where((r) => r.deleted).map((r) => r.rowId),
      containsAll([larger, local.rowId]),
    );
  });

  test('rows left without a parent by a remote delete are removed', () async {
    final (mess, member) = await seed(db);
    await drain(store);
    // Recorded on this phone while another phone wiped all data.
    final payment = await LocalPaymentRepository(db).addPayment(
      messId: mess.id,
      date: DateTime(2026, 10, 1),
      memberId: member.id,
      amount: Money.fromMajor(100),
    );
    await drain(store);

    await store.applyRemote([
      SyncRecord.tombstone('members', member.id),
      SyncRecord.tombstone('messes', mess.id),
    ]);

    expect(await store.hasLocalData(), isFalse);
    // The payment (and the activity log entry it wrote) can't outlive the
    // mess, so they're removed here and in the cloud.
    final queued = [for (final c in await store.pendingChanges()) c.record];
    expect(queued.every((r) => r.deleted), isTrue);
    expect(queued.map((r) => r.rowId), contains(payment.id));
    expect(queued.map((r) => r.table).toSet(), {'payments', 'activity_logs'});
  });

  test('wipe and queue-everything do what a first sign-in needs', () async {
    await seed(db);
    await drain(store);
    await store.queueEverything();
    expect(
      (await store.pendingChanges()).map((c) => c.record.table).toSet(),
      containsAll(['messes', 'members']),
    );

    await store.wipeLocalData();
    expect(await store.hasLocalData(), isFalse);
    expect(await store.pendingCount(), 0);
  });
}
