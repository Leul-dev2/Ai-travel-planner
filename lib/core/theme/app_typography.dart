// ─── App Typography ─────────────────────────────────────────────────
// Premium type system with dual font families: Inter for UI, Playfair for display.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // ── Display (Hero Headlines — Playfair Display for luxury feel) ──
  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static TextStyle displaySmall = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // ── Headings (Inter — clean and modern) ──
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ── Titles ──
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // ── Body ──
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels (Buttons, Chips, Tags) ──
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.3,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // ── Mono (GPS, data, technical readouts) ──
  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.4,
  );

  // ── Button ──
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // ── Input ──
  static TextStyle input = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // ── Caption (new — for small supporting text) ──
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Price (new — for monetary values) ──
  static TextStyle price = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// Build Material 3 TextTheme for dark mode
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge:
            headlineLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium:
            headlineMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall:
            headlineSmall.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textSecondaryDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textMutedDark),
        labelLarge: labelLarge.copyWith(color: AppColors.textSecondaryDark),
        labelMedium: labelMedium.copyWith(color: AppColors.textMutedDark),
        labelSmall: labelSmall.copyWith(color: AppColors.textMutedDark),
      );

  /// Build Material 3 TextTheme for light mode
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryLight),
        displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryLight),
        headlineLarge:
            headlineLarge.copyWith(color: AppColors.textPrimaryLight),
        headlineMedium:
            headlineMedium.copyWith(color: AppColors.textPrimaryLight),
        headlineSmall:
            headlineSmall.copyWith(color: AppColors.textPrimaryLight),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryLight),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryLight),
        titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textSecondaryLight),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        bodySmall: bodySmall.copyWith(color: AppColors.textMutedLight),
        labelLarge: labelLarge.copyWith(color: AppColors.textSecondaryLight),
        labelMedium: labelMedium.copyWith(color: AppColors.textMutedLight),
        labelSmall: labelSmall.copyWith(color: AppColors.textMutedLight),
      );
}
