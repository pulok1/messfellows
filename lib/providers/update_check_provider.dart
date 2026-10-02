import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/update_checker_service.dart';
import '../models/app_update_info.dart';

/// Per-device: once a build's banner is dismissed it stays hidden, even
/// across restarts, until an even newer build ships.
const _dismissedBuildPrefsKey = 'updateCheck.dismissedBuild';

final _updateCheckerServiceProvider = Provider((ref) => UpdateCheckerService());

/// The newest build found on GitHub, if there is one and the device hasn't
/// already dismissed it — the Home screen's "update available" banner.
/// Checked once per app session (Riverpod keeps this alive for the life of
/// the provider container), not on every tab switch.
class UpdateAvailableNotifier extends AsyncNotifier<AppUpdateInfo?> {
  @override
  Future<AppUpdateInfo?> build() async {
    final info = await ref.read(_updateCheckerServiceProvider).checkForUpdate();
    if (info == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final dismissedBuild = prefs.getInt(_dismissedBuildPrefsKey);
    return info.buildNumber == dismissedBuild ? null : info;
  }

  Future<void> dismiss() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncData(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dismissedBuildPrefsKey, current.buildNumber);
  }
}

final updateAvailableProvider =
    AsyncNotifierProvider<UpdateAvailableNotifier, AppUpdateInfo?>(
      UpdateAvailableNotifier.new,
    );
