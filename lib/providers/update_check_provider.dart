import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/app_updater.dart';
import '../core/services/update_checker_service.dart';
import '../models/app_update_info.dart';

/// "Later" hides a build's prompt for this long (per device, across
/// restarts) — it comes back, rather than being silenced for good.
const updateSnooze = Duration(days: 1);

/// Coming back to the app re-checks, but not more often than this (GitHub
/// allows 60 unauthenticated API calls an hour).
const _recheckEvery = Duration(minutes: 30);

const _snoozedBuildKey = 'updateCheck.snoozedBuild';
const _snoozedAtKey = 'updateCheck.snoozedAt';

final updateCheckerServiceProvider = Provider((ref) => UpdateCheckerService());
final appUpdaterProvider = Provider((ref) => const AppUpdater());

/// Whether [build] is still inside a "Later" snooze.
@visibleForTesting
bool isSnoozed({
  required int build,
  required int? snoozedBuild,
  required DateTime? snoozedAt,
  required DateTime now,
}) =>
    snoozedBuild == build &&
    snoozedAt != null &&
    now.difference(snoozedAt) < updateSnooze;

/// The newer build to offer, or null — drives the update popup and banner
/// on the Home screen. Checks at launch and again when the app returns to
/// the foreground, so an update pushed while the app sat in the background
/// still shows up.
class UpdateAvailableNotifier extends AsyncNotifier<AppUpdateInfo?> {
  DateTime? _lastCheck;

  @override
  Future<AppUpdateInfo?> build() async {
    final lifecycle = AppLifecycleListener(onResume: _recheckIfStale);
    ref.onDispose(lifecycle.dispose);
    return _check();
  }

  Future<AppUpdateInfo?> _check() async {
    _lastCheck = DateTime.now();
    final info = await ref.read(updateCheckerServiceProvider).checkForUpdate();
    if (info == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final snoozedAt = prefs.getInt(_snoozedAtKey);
    return isSnoozed(
          build: info.buildNumber,
          snoozedBuild: prefs.getInt(_snoozedBuildKey),
          snoozedAt: snoozedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(snoozedAt),
          now: DateTime.now(),
        )
        ? null
        : info;
  }

  Future<void> _recheckIfStale() async {
    final last = _lastCheck;
    if (last != null && DateTime.now().difference(last) < _recheckEvery) {
      return;
    }
    final info = await _check();
    // Keep showing what's already found if this check came back empty
    // (offline) — only replace it with something newer.
    if (info != null && info.buildNumber != state.value?.buildNumber) {
      state = AsyncData(info);
    }
  }

  /// "Later": hide this build for [updateSnooze].
  Future<void> snooze() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncData(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_snoozedBuildKey, current.buildNumber);
    await prefs.setInt(_snoozedAtKey, DateTime.now().millisecondsSinceEpoch);
  }
}

final updateAvailableProvider =
    AsyncNotifierProvider<UpdateAvailableNotifier, AppUpdateInfo?>(
      UpdateAvailableNotifier.new,
    );
