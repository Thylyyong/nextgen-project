import 'package:flutter/material.dart';
import 'package:nextgen/app/theme/color_theme.dart';

/// BuildContext extension providing named TextStyle shortcuts.
/// Mirrors storex_customer's AppTheme extension so widgets look identical.
extension AppTheme on BuildContext {
  // ── Titles ─────────────────────────────────────────────────────────────────
  TextStyle get titleLarge => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 32,
        color: ColorTheme.primary400,
        fontWeight: FontWeight.w700,
      );

  TextStyle get titleMedium => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 24,
        color: ColorTheme.primary800,
        fontWeight: FontWeight.w600,
      );

  TextStyle get titleSmall => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 20,
        color: ColorTheme.primary800,
        fontWeight: FontWeight.w600,
      );

  // ── Subtitles ──────────────────────────────────────────────────────────────
  TextStyle get subtitle => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      );

  TextStyle get subtitleLarge => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );

  TextStyle get subtitleMedium => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );

  TextStyle get subtitleSmall => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 12,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );

  TextStyle get subtitleSoSmall => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 10,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );
}

/// Global MaterialTheme configuration for the app.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Outfit',
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorTheme.primary400,
      surface: ColorTheme.screenBg,
    ),
    scaffoldBackgroundColor: ColorTheme.screenBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ColorTheme.neutral800,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ColorTheme.neutral800,
      ),
    ),
    cardTheme: CardThemeData(
      color: ColorTheme.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: ColorTheme.primary400,
      labelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  );
}
