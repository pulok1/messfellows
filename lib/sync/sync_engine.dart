import 'dart:async';

import 'local_sync_store.dart';
import 'remote_sync_api.dart';

enum SyncPhase {
  /// Signed in, working out whether this device's data and the account's
  /// cloud copy need reconciling.
  starting,

  /// Both this device and the account already hold a mess. Nothing syncs
  /// until the user picks one with [SyncEngine.resolve].
  needsChoice,
  syncing,
  idle,

  /// The last attempt couldn't reach the server; it retries by itself.
  offline,

  /// The server rejected the last attempt; [SyncStatus.error] says why.
  error,
}

/// Which copy wins on a device's first sign-in, when both have data.
enum LinkChoice { keepCloud, keepDevice }

class SyncStatus {
  final SyncPhase phase;
  final DateTime? lastSyncedAt;

  /// Local changes not yet uploaded.
  final int pending;
  final Object? error;

  const SyncStatus(
    this.phase, {
    this.lastSyncedAt,
    this.pending = 0,
    this.error,
  });
}

/// Keeps the local database and one account's cloud copy in step.
///
/// The local database stays the source of truth for the UI; this only ever
/// runs in the background. A cycle pushes everything queued in the outbox,
/// then pulls whatever changed in the cloud since the last pull. When two
/// devices edit the same row, the one that syncs last wins.
///
/// Cycles run on [start], shortly after local writes ([localChanges]), when
/// another device writes ([RemoteSyncApi.changes]), every [interval] as a
/// fallback, and on [syncNow]. Failures retry with backoff.
class SyncEngine {
  final LocalSyncStore _store;
  final RemoteSyncApi _remote;
  final String _userId;
  final Stream<void> _localChanges;
  final Duration interval;

  SyncEngine({
    required this._store,
    required this._remote,
    required this._userId,
    this._localChanges = const Stream.empty(),
    this.interval = const Duration(minutes: 5),
  });

  /// Re-pulled on every cycle in case a write committed out of timestamp
  /// order on the server; re-applying an unchanged row is a no-op.
  static const pullOverlap = Duration(seconds: 30);
  static const _lastSyncedKey = 'last_synced_at';
  static const _backoff = [10, 30, 60, 120, 300];

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus(SyncPhase.starting);
  final _subscriptions = <StreamSubscription<void>>[];
  Timer? _timer;
  Timer? _periodic;
  Future<void>? _running;
  bool _rerun = false;
  bool _linked = false;
  bool _disposed = false;
  int _failures = 0;

  SyncStatus get status => _status;
  Stream<SyncStatus> get statusStream => _statusController.stream;

  Future<void> start() async {
    final last = await _store.readMeta(_lastSyncedKey);
    _emit(
      SyncStatus(
        SyncPhase.starting,
        lastSyncedAt: last == null ? null : DateTime.tryParse(last),
        pending: await _store.pendingCount(),
      ),
    );
    _subscriptions
      ..add(
        _localChanges.listen(
          (_) => _schedule(const Duration(seconds: 2), onlyIfPending: true),
        ),
      )
      ..add(
        _remote.changes().listen((_) => _schedule(const Duration(seconds: 1))),
      );
    _periodic = Timer.periodic(interval, (_) => _schedule(Duration.zero));
    await syncNow();
  }

  /// Runs a cycle now (or right after the one in progress) and completes
  /// when it's done. Never throws — the outcome is in [status].
  Future<void> syncNow() async {
    if (_disposed) return;
    _timer?.cancel();
    if (_running != null) {
      _rerun = true;
      return _running;
    }
    final run = _runCycles();
    _running = run;
    try {
      await run;
    } finally {
      _running = null;
    }
  }

  /// Settles a [SyncPhase.needsChoice]: [LinkChoice.keepCloud] replaces
  /// this device's data with the account's; [LinkChoice.keepDevice]
  /// replaces the account's with this device's.
  Future<void> resolve(LinkChoice choice) async {
    switch (choice) {
      case LinkChoice.keepCloud:
        await _store.wipeLocalData();
      case LinkChoice.keepDevice:
        await _remote.tombstoneAll();
        await _store.queueEverything();
    }
    await _link();
    await syncNow();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _periodic?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    _statusController.close();
  }

  // ---------------------------------------------------------------------

  Future<void> _runCycles() async {
    do {
      _rerun = false;
      try {
        await _cycle();
        _failures = 0;
      } catch (e) {
        if (_disposed) return;
        _emit(
          _copy(
            e is SyncOfflineException ? SyncPhase.offline : SyncPhase.error,
            error: e,
          ),
        );
        final seconds = _backoff[_failures.clamp(0, _backoff.length - 1)];
        _failures++;
        _schedule(Duration(seconds: seconds));
        return;
      }
    } while (_rerun && !_disposed);
  }

  Future<void> _cycle() async {
    if (!await _ensureLinked()) return;
    _emit(_copy(SyncPhase.syncing));

    while (true) {
      final batch = await _store.pendingChanges();
      if (batch.isEmpty || _disposed) break;
      await _remote.push([for (final c in batch) c.record]);
      await _store.markPushed(batch.map((c) => c.seq));
    }

    final cursor = await _store.readMeta(LocalSyncStore.pullCursorKey);
    final since = cursor == null
        ? null
        : DateTime.parse(cursor).subtract(pullOverlap);
    final records = await _remote.pullSince(since);
    if (_disposed) return;
    if (records.isNotEmpty) {
      await _store.applyRemote(records);
      final newest = records
          .map((r) => r.updatedAt)
          .nonNulls
          .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
      if (newest != null &&
          (cursor == null || newest.isAfter(DateTime.parse(cursor)))) {
        await _store.writeMeta(
          LocalSyncStore.pullCursorKey,
          newest.toUtc().toIso8601String(),
        );
      }
    }

    final now = DateTime.now();
    await _store.writeMeta(_lastSyncedKey, now.toIso8601String());
    final pending = await _store.pendingCount();
    // Applying may have queued tombstones (a lost duplicate, an orphan).
    if (pending > 0) _rerun = true;
    _emit(SyncStatus(SyncPhase.idle, lastSyncedAt: now, pending: pending));
  }

  /// On the first sync for this account on this device, decides whose data
  /// becomes the shared copy. Returns false while waiting on the user.
  Future<bool> _ensureLinked() async {
    if (_linked) return true;
    if (await _store.readMeta(LocalSyncStore.linkedUserKey) == _userId) {
      return _linked = true;
    }
    if (!await _store.hasLocalData()) {
      // Nothing here to lose: adopt the cloud copy (if any).
      await _store.wipeLocalData();
    } else if (!await _remote.hasData()) {
      // A fresh account: this device's data becomes the cloud copy.
      await _store.queueEverything();
    } else {
      _emit(_copy(SyncPhase.needsChoice));
      return false;
    }
    await _link();
    return true;
  }

  Future<void> _link() async {
    await _store.writeMeta(LocalSyncStore.pullCursorKey, null);
    await _store.writeMeta(LocalSyncStore.linkedUserKey, _userId);
    _linked = true;
  }

  void _schedule(Duration delay, {bool onlyIfPending = false}) {
    if (_disposed || _status.phase == SyncPhase.needsChoice) return;
    _timer?.cancel();
    _timer = Timer(delay, () async {
      if (onlyIfPending && await _store.pendingCount() == 0) return;
      await syncNow();
    });
  }

  SyncStatus _copy(SyncPhase phase, {Object? error}) => SyncStatus(
    phase,
    lastSyncedAt: _status.lastSyncedAt,
    pending: _status.pending,
    error: error,
  );

  void _emit(SyncStatus status) {
    if (_disposed) return;
    _status = status;
    _statusController.add(status);
  }
}
