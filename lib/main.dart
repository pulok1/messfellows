import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_root.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Both supported locales' date symbols (month/weekday names) must be
  // loaded before any DateFormat call — see core/utils/localized_date.dart.
  await Future.wait([initializeDateFormatting('en'), initializeDateFormatting('bn')]);
  final savedLocale = await loadSavedLocale();

  runApp(
    ProviderScope(
      overrides: [
        if (savedLocale != null)
          localeProvider.overrideWith(() => LocaleNotifier(savedLocale)),
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

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AppRoot(),
    );
  }
}
