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

  static const Color _willReceiveLight = Color(0xFF2E7D32);
  static const Color _willReceiveDark = Color(0xFF81C784);
  static const Color _needsToPayLight = Color(0xFFC62828);
  static const Color _needsToPayDark = Color(0xFFEF9A9A);
  static const Color _settledLight = Color(0xFF616161);
  static const Color _settledDark = Color(0xFFBDBDBD);

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

  static const Color _seedColor = Color(0xFF2E7D67);

  static ThemeData light() => _themeFrom(Brightness.light);
  static ThemeData dark() => _themeFrom(Brightness.dark);

  static ThemeData _themeFrom(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      // Without this, BottomAppBar falls back to colorScheme.surface, i.e.
      // exactly the scaffold background — the bottom nav would be visually
      // indistinguishable from the page body. Matching PageHeaderCard's
      // surfaceContainerHigh here makes the header and bottom nav read as
      // one consistent "chrome" layer, clearly separated from content.
      bottomAppBarTheme: BottomAppBarThemeData(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
        fillColor: colorScheme.surfaceContainerHighest,
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
