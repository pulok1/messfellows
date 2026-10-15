import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_root.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/sync_providers.dart';
import 'providers/theme_mode_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The bundled UI font's licence, so it's listed on the Licenses page.
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Plus Jakarta Sans'], text);
  });
  // Both supported locales' date symbols (month/weekday names) must be
  // loaded before any DateFormat call — see core/utils/localized_date.dart.
  await Future.wait([
    initializeDateFormatting('en'),
    initializeDateFormatting('bn'),
  ]);
  // Optional cloud sync. Restores a saved session from disk without needing
  // the network, so an offline launch is as fast as before.
  final supabase = SupabaseConfig.isConfigured
      ? (await Supabase.initialize(
          url: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
        )).client
      : null;
  final savedLocale = await loadSavedLocale();
  final savedThemeMode = await loadSavedThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        if (supabase != null)
          supabaseClientProvider.overrideWithValue(supabase),
        if (savedLocale != null)
          localeProvider.overrideWith(() => LocaleNotifier(savedLocale)),
        if (savedThemeMode != null)
          themeModeProvider.overrideWith(
            () => AppThemeModeNotifier(savedThemeMode),
          ),
      ],
      child: const MessFellowsApp(),
    ),
  );
}

class MessFellowsApp extends ConsumerWidget {
  const MessFellowsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AppRoot(),
    );
  }
}
