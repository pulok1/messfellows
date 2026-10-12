import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/database/app_database.dart';
import 'package:messfellows/models/mess.dart';
import 'package:messfellows/repositories/local/local_member_repository.dart';
import 'package:messfellows/repositories/local/local_mess_repository.dart';
import 'package:messfellows/sync/local_sync_store.dart';
import 'package:messfellows/sync/remote_sync_api.dart';
import 'package:messfellows/sync/sync_engine.dart';
import 'package:messfellows/sync/sync_record.dart';

/// In-memory stand-in for the `sync_records` table, with the server's
/// clock stamping every write like the real trigger does.
class FakeRemote implements RemoteSyncApi {
  final rows = <(String, String), SyncRecord>{};
  var _clock = DateTime.utc(2026, 10, 1);
  bool offline = false;
  final _changes = StreamController<void>.broadcast();

  DateTime _tick() => _clock = _clock.add(const Duration(seconds: 1));

  void _check() {
    if (offline) throw const SyncOfflineException('no network');
  }

  @override
  Future<void> push(List<SyncRecord> records) async {
    _check();
    for (final r in records) {
      rows[(r.table, r.rowId)] = SyncRecord(
        table: r.table,
        rowId: r.rowId,
        data: r.data,
        deleted: r.deleted,
        updatedAt: _tick(),
      );
    }
    _changes.add(null);
  }

  @override
  Future<List<SyncRecord>> pullSince(DateTime? since) async {
    _check();
    return rows.values
        .where((r) => since == null || r.updatedAt!.isAfter(since))
        .toList()
      ..sort((a, b) => a.updatedAt!.compareTo(b.updatedAt!));
  }

  @override
  Future<bool> hasData() async {
    _check();
    return rows.values.any((r) => !r.deleted);
  }

  @override
  Future<void> tombstoneAll() async {
    _check();
    for (final key in rows.keys.toList()) {
      if (!rows[key]!.deleted) {
        rows[key] = SyncRecord.tombstone(key.$1, key.$2, updatedAt: _tick());
      }
    }
  }

  @override
  Stream<void> changes() => const Stream.empty();
}

class Device {
  final AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());
  late final store = LocalSyncStore(db);
  late final messes = LocalMessRepository(db);
  late final members = LocalMemberRepository(db);
  SyncEngine? engine;

  Future<SyncEngine> signIn(FakeRemote remote, {String userId = 'user-1'}) async {
    engine?.dispose();
    final e = engine = SyncEngine(
      store: store,
      remote: remote,
      userId: userId,
      interval: const Duration(hours: 1),
    );
    await e.start();
    return e;
  }

  Future<Mess?> mess() => messes.watchMess().first;

  Future<List<String>> memberNames() async {
    final m = await mess();
    if (m == null) return [];
    return [for (final x in await members.watchAllMembers(m.id).first) x.name]..sort();
  }

  Future<void> close() async {
    engine?.dispose();
    await db.close();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FakeRemote remote;
  late Device phone;
  late Device tablet;

  setUp(() {
    remote = FakeRemote();
    phone = Device();
    tablet = Device();
  });
  tearDown(() async {
    await phone.close();
    await tablet.close();
  });

  Future<Mess> createMess(Device d, List<String> names) async {
    final mess = await d.messes.createMess(
      name: 'Mess',
      currencyCode: 'BDT',
      currencySymbol: '৳',
    );
    for (final n in names) {
      await d.members.addMember(messId: mess.id, name: n);
    }
    return mess;
  }

  test('a second device signing in gets the first one\'s data, and edits flow both ways', () async {
    final mess = await createMess(phone, ['Alice', 'Bob']);
    final phoneSync = await phone.signIn(remote);
    expect(phoneSync.status.phase, SyncPhase.idle);
    expect(phoneSync.status.pending, 0);

    final tabletSync = await tablet.signIn(remote);
    expect(tabletSync.status.phase, SyncPhase.idle);
    expect((await tablet.mess())!.id, mess.id);
    expect(await tablet.memberNames(), ['Alice', 'Bob']);

    await tablet.members.addMember(messId: mess.id, name: 'Carol');
    await tablet.messes.updateMess((await tablet.mess())!.copyWith(name: 'Renamed'));
    await tabletSync.syncNow();
    await phoneSync.syncNow();
    expect(await phone.memberNames(), ['Alice', 'Bob', 'Carol']);
    expect((await phone.mess())!.name, 'Renamed');
  });

  test('a device with its own data waits for a choice — keep cloud', () async {
    await createMess(phone, ['Alice']);
    await phone.signIn(remote);
    await createMess(tablet, ['Zed']);

    final tabletSync = await tablet.signIn(remote);
    expect(tabletSync.status.phase, SyncPhase.needsChoice);
    expect(remote.rows.values.where((r) => r.table == 'members'), hasLength(1));

    await tabletSync.resolve(LinkChoice.keepCloud);
    expect(tabletSync.status.phase, SyncPhase.idle);
    expect(await tablet.memberNames(), ['Alice']);
  });

  test('a device with its own data waits for a choice — keep device', () async {
    await createMess(phone, ['Alice']);
    final phoneSync = await phone.signIn(remote);
    await createMess(tablet, ['Zed']);

    final tabletSync = await tablet.signIn(remote);
    await tabletSync.resolve(LinkChoice.keepDevice);
    expect(await tablet.memberNames(), ['Zed']);

    await phoneSync.syncNow();
    expect(await phone.memberNames(), ['Zed']);
  });

  test('offline changes stay queued and go up once back online', () async {
    final mess = await createMess(phone, ['Alice']);
    final phoneSync = await phone.signIn(remote);
    remote.offline = true;

    await phone.members.addMember(messId: mess.id, name: 'Bob');
    await phoneSync.syncNow();
    expect(phoneSync.status.phase, SyncPhase.offline);
    expect(await phone.store.pendingCount(), greaterThan(0));

    remote.offline = false;
    await phoneSync.syncNow();
    expect(phoneSync.status.phase, SyncPhase.idle);
    expect(phoneSync.status.pending, 0);
    final tabletSync = await tablet.signIn(remote);
    expect(tabletSync.status.phase, SyncPhase.idle);
    expect(await tablet.memberNames(), ['Alice', 'Bob']);
  });

  test('deleting all data on one device clears it on the others', () async {
    await createMess(phone, ['Alice']);
    final phoneSync = await phone.signIn(remote);
    final tabletSync = await tablet.signIn(remote);
    expect(await tablet.mess(), isNotNull);

    await phone.messes.deleteAllData();
    await phoneSync.syncNow();
    await tabletSync.syncNow();
    expect(await tablet.mess(), isNull);
  });

  test('signing back in to the same account resumes without asking', () async {
    final mess = await createMess(phone, ['Alice']);
    await phone.signIn(remote);
    phone.engine!.dispose();
    phone.engine = null;

    // Edited while signed out.
    await phone.members.addMember(messId: mess.id, name: 'Bob');
    final again = await phone.signIn(remote);
    expect(again.status.phase, SyncPhase.idle);
    expect(
      remote.rows.values.where((r) => r.table == 'members' && !r.deleted),
      hasLength(2),
    );
  });
}
