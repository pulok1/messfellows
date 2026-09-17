import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used in [SharedPreferences] for the persisted language choice. This
/// is a per-device UI preference, not mess data — it's deliberately kept
/// out of the Drift database so a future cloud sync of the mess never
/// pushes one member's language choice onto another member's device.
const _languagePrefsKey = 'languageCode';

/// Holds the app's current display language, seeded from the persisted
/// preference at startup (see `main.dart`) so there's no flash of the
/// wrong language before the saved choice loads.
class LocaleNotifier extends Notifier<Locale> {
  final Locale _initial;

  LocaleNotifier([this._initial = const Locale('en')]);

  @override
  Locale build() => _initial;

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefsKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Reads the persisted language choice, if any. Called once from `main()`
/// before `runApp` so the very first frame already renders in the right
/// language.
Future<Locale?> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_languagePrefsKey);
  return code == null ? null : Locale(code);
}
