import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used in [SharedPreferences] for the persisted theme choice. Kept as a
/// per-device UI preference alongside [localeProvider], not mess data.
const _themeModePrefsKey = 'themeMode';

const _themeModeValues = {
  'light': ThemeMode.light,
  'dark': ThemeMode.dark,
  'system': ThemeMode.system,
};

/// Holds the app's current light/dark/system choice, seeded from the
/// persisted preference at startup (see `main.dart`) so there's no flash of
/// the wrong theme before the saved choice loads.
class AppThemeModeNotifier extends Notifier<ThemeMode> {
  final ThemeMode _initial;

  AppThemeModeNotifier([this._initial = ThemeMode.system]);

  @override
  ThemeMode build() => _initial;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeModePrefsKey,
      _themeModeValues.entries.firstWhere((e) => e.value == mode).key,
    );
  }
}

final themeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);

/// Reads the persisted theme choice, if any. Called once from `main()`
/// before `runApp` so the very first frame already renders in the right
/// theme.
Future<ThemeMode?> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_themeModePrefsKey);
  return value == null ? null : _themeModeValues[value];
}
