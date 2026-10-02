import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Balance state colors, used consistently across dashboard, reports and
/// member detail so "will receive" / "needs to pay" always look the same.
/// Financial state is still spelled out in text everywhere it's shown — see
/// section 32 of the product spec — these colors are a secondary cue only.
///
/// Each state has a light- and dark-mode variant: the light-mode shades are
/// too low-contrast to read on a dark surface, so [of] picks the right one
/// for the current [Brightness] instead of using one fixed color everywhere.
class AppBalanceColors {
  AppBalanceColors._();

  static const Color _willReceiveLight = Color(0xFF15803D);
  static const Color _willReceiveDark = Color(0xFF4ADE80);
  static const Color _needsToPayLight = Color(0xFFDC2626);
  static const Color _needsToPayDark = Color(0xFFF87171);
  static const Color _settledLight = Color(0xFF64748B);
  static const Color _settledDark = Color(0xFF94A3B8);

  static Color willReceive(BuildContext context) =>
      _of(context, _willReceiveLight, _willReceiveDark);

  static Color needsToPay(BuildContext context) =>
      _of(context, _needsToPayLight, _needsToPayDark);

  static Color settled(BuildContext context) =>
      _of(context, _settledLight, _settledDark);

  static Color _of(BuildContext context, Color light, Color dark) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Centralized Material 3 theme. Keep every screen on this rather than
/// hardcoding colors/text styles so the app reads as one consistent product.
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF0E9F6E);

  static ThemeData light() => _themeFrom(Brightness.light);

  /// Background for top/bottom chrome (header bars, bottom app bar): the
  /// plain surface tone, near-white in light mode and just above the body
  /// in dark mode.
  static Color chromeColor(ColorScheme colorScheme) => colorScheme.surface;

  static ThemeData dark() => _themeFrom(Brightness.dark);

  static ThemeData _themeFrom(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      // The default tonalSpot variant desaturates the seed into a muted
      // grey-green; fidelity keeps primary close to the brand emerald so
      // buttons, selected states and accents actually look green.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Light mode: a soft off-white body with pure white cards lifted off
      // it by a hairline outline. Dark mode: the darkest tone for the body
      // with lighter cards. Chrome (header, bottom bar) uses [chromeColor]
      // and is separated from content by a divider rather than a tint, so
      // the screen doesn't read as one wash of grey-green.
      scaffoldBackgroundColor: isDark
          ? colorScheme.surfaceContainerLowest
          : colorScheme.surfaceContainerLow,
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: chromeColor(colorScheme),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.4 : 0.6,
            ),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: colorScheme.surfaceTint,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        side: BorderSide.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
        ),
      ),
    );
  }
}
