import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextgen/app/theme/color_theme.dart';

/// BuildContext extension providing named TextStyle shortcuts.
/// Uses GoogleFonts.outfit() so no local TTF files are needed.
extension AppTheme on BuildContext {
  // ── Titles ─────────────────────────────────────────────────────────────────
  TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 32,
        color: ColorTheme.primary400,
        fontWeight: FontWeight.w700,
      );

  TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 24,
        color: ColorTheme.primary800,
        fontWeight: FontWeight.w600,
      );

  TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 20,
        color: ColorTheme.primary800,
        fontWeight: FontWeight.w600,
      );

  // ── Subtitles ──────────────────────────────────────────────────────────────
  TextStyle get subtitle => GoogleFonts.outfit(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      );

  TextStyle get subtitleLarge => GoogleFonts.outfit(
        fontSize: 16,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );

  TextStyle get subtitleMedium => GoogleFonts.outfit(
        fontSize: 14,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );

  TextStyle get subtitleSmall => GoogleFonts.outfit(
        fontSize: 12,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );

  TextStyle get subtitleSoSmall => GoogleFonts.outfit(
        fontSize: 10,
        color: ColorTheme.neutral400,
        fontWeight: FontWeight.w400,
      );
}

/// Global MaterialTheme configuration for the app.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    // Apply Outfit as the default text theme app-wide
    textTheme: GoogleFonts.outfitTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorTheme.primary400,
      surface: ColorTheme.screenBg,
    ),
    scaffoldBackgroundColor: ColorTheme.screenBg,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ColorTheme.neutral800,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
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
      labelStyle: GoogleFonts.outfit(fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  );
}
