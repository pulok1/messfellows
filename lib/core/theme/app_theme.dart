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

  static const Color _willReceiveLight = Color(0xFF12805C);
  static const Color _willReceiveDark = Color(0xFF5CCB9B);
  static const Color _needsToPayLight = Color(0xFFC4421A);
  static const Color _needsToPayDark = Color(0xFFF28B6B);
  static const Color _settledLight = Color(0xFF66756C);
  static const Color _settledDark = Color(0xFF9AA8A0);

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

  /// The "Emerald" palette: a deep green top bar, an emerald accent for
  /// buttons and selected states, and greys with a faint green bias so the
  /// neutrals sit with the brand instead of reading as default grey.
  static const Color _emerald = Color(0xFF12805C);
  static const Color _emeraldDeep = Color(0xFF0F5A3E);
  static const Color _emeraldDarkBar = Color(0xFF123D2D);

  static ThemeData light() => _themeFrom(Brightness.light);

  /// Background for top/bottom chrome (header bars, bottom app bar): the
  /// plain surface tone, white in light mode and just above the body in
  /// dark mode.
  static Color chromeColor(ColorScheme colorScheme) => colorScheme.surface;

  /// The top bar's fill: deep emerald in light mode, and a much darker
  /// green in dark mode (full-strength green glares on a dark screen) —
  /// either way clearly distinct from the body below it.
  static Color topBarColor(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? _emeraldDarkBar
      : _emeraldDeep;

  /// Title and icon colour on [topBarColor].
  static Color onTopBarColor(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? colorScheme.onSurface
      : Colors.white;

  /// The colour for a screen's headline figure (the meal rate): the deep
  /// brand green on light surfaces, the lighter primary on dark ones.
  static Color headlineFigureColor(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? colorScheme.primary
      : _emeraldDeep;

  /// Soft amber for a neutral "worth noticing" badge, like the meal rate's
  /// month-on-month change — deliberately neither the good green nor the
  /// owed red.
  static (Color background, Color foreground) noticeColors(
    ColorScheme colorScheme,
  ) => colorScheme.brightness == Brightness.dark
      ? (const Color(0xFF3D2E12), const Color(0xFFF5C46B))
      : (const Color(0xFFFFF1DC), const Color(0xFF9A5B00));

  static ThemeData dark() => _themeFrom(Brightness.dark);

  static ThemeData _themeFrom(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // Fidelity keeps primary close to the emerald seed instead of the
    // default variant's desaturated take on it; light mode then pins the
    // exact brand tones. Surfaces are swapped for near-neutral greys with a
    // faint green bias: #F2F5F3 body and white cards in light mode, a
    // green-black body and slightly lifted cards in dark mode.
    final seeded = ColorScheme.fromSeed(
      seedColor: _emerald,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final colorScheme = isDark
        ? seeded.copyWith(
            surface: const Color(0xFF18201C),
            surfaceContainerLowest: const Color(0xFF0F1412),
            surfaceContainerLow: const Color(0xFF131A17),
            surfaceContainer: const Color(0xFF1A2320),
            surfaceContainerHigh: const Color(0xFF222C28),
            surfaceContainerHighest: const Color(0xFF2A3530),
            outlineVariant: const Color(0xFF2F3B36),
          )
        : seeded.copyWith(
            primary: _emerald,
            onPrimary: Colors.white,
            primaryContainer: const Color(0xFFDFF1E8),
            onPrimaryContainer: _emeraldDeep,
            surface: Colors.white,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: const Color(0xFFF2F5F3),
            surfaceContainer: const Color(0xFFEBF0ED),
            surfaceContainerHigh: const Color(0xFFE4EAE6),
            surfaceContainerHighest: const Color(0xFFDDE4E0),
            onSurface: const Color(0xFF15201A),
            onSurfaceVariant: const Color(0xFF5E6E65),
            outlineVariant: const Color(0xFFE1E7E3),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Light mode: a soft off-white body with pure white cards lifted off
      // it by a hairline outline. Dark mode: the darkest tone for the body
      // with lighter cards. Chrome (header, bottom bar) uses [chromeColor]
      // and is separated from content by a divider rather than a tint.
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius + 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(
            color: isDark
                ? colorScheme.outlineVariant.withValues(alpha: 0.6)
                : colorScheme.outlineVariant,
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
