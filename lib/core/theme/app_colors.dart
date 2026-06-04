// ─── App Color Palette ──────────────────────────────────────────────
// Apple / Airbnb inspired premium color system for Wanderlust AI.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Primary (Vibrant Airbnb/Apple Hybrid Coral/Rose) ──
  static const Color primary = Color(0xFFFF385C); // Premium Coral
  static const Color primaryLight = Color(0xFFFF5A78);
  static const Color primaryDark = Color(0xFFD90B38);
  static const Color primaryContainer = Color(0xFFFFF0F2);

  // ── Brand Secondary (Deep Ocean Blue) ──
  static const Color secondary = Color(0xFF003580); // Booking.com premium blue
  static const Color secondaryLight = Color(0xFF1E5BB5);
  static const Color secondaryDark = Color(0xFF002255);

  // ── Brand Accent (Warm / Gold) ──
  static const Color accent = Color(0xFFFFB347);
  static const Color accentLight = Color(0xFFFFCC7A);
  static const Color accentWarm = Color(0xFFF5A623);

  // ── Success / Error / Warning / Info ──
  static const Color success = Color(0xFF34C759); // Apple Green
  static const Color successLight = Color(0xFFE8F8EE);
  static const Color error = Color(0xFFFF3B30); // Apple Red
  static const Color errorLight = Color(0xFFFFEAEB);
  static const Color warning = Color(0xFFFF9500); // Apple Orange
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color info = Color(0xFF007AFF); // Apple Blue
  static const Color infoLight = Color(0xFFE5F1FF);

  // ── Dark Theme Surfaces (Pure Black / OLED aesthetic) ──
  static const Color bgDark = Color(0xFF000000); // Pure Black
  static const Color surfaceDark = Color(0xFF121212); // Elevated Dark
  static const Color surfaceAltDark = Color(0xFF1C1C1E); // Apple Dark Gray
  static const Color surfaceElevatedDark = Color(0xFF2C2C2E);
  static const Color borderDark = Color(0xFF38383A);
  static const Color borderSubtleDark = Color(0xFF2C2C2E);

  // ── Text Colors (Dark Theme) ──
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textMutedDark = Color(0xFF8E8E93);
  static const Color textDisabledDark = Color(0xFF636366);

  // ── Light Theme Surfaces (Pure White / Clean aesthetic) ──
  static const Color bgLight = Color(0xFFF2F2F7); // Apple Light Gray background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White cards
  static const Color surfaceAltLight = Color(0xFFF9F9FB);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E5EA);
  static const Color borderSubtleLight = Color(0xFFF2F2F7);

  // ── Text Colors (Light Theme) ──
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textMutedLight = Color(0xFF8E8E93);
  static const Color textDisabledLight = Color(0xFFC7C7CC);

  // ── Glass Effect ──
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x33000000);

  // ── Destination Category Colors ──
  static const Color catBeach = Color(0xFF00B4D8);
  static const Color catMountain = Color(0xFF2D6A4F);
  static const Color catCity = Color(0xFFE76F51);
  static const Color catCulture = Color(0xFFF4A261);
  static const Color catAdventure = Color(0xFFE63946);
  static const Color catFood = Color(0xFFFF9F1C);
  static const Color catNature = Color(0xFF52B788);
  static const Color catNightlife = Color(0xFF9B5DE5);

  // ── Budget Category Colors ──
  static const Color categoryHotel = Color(0xFF003580);
  static const Color categoryFood = Color(0xFFFF9500);
  static const Color categoryTransport = Color(0xFF34C759);
  static const Color categoryActivity = Color(0xFFFF385C);
  static const Color categoryOther = Color(0xFF8E8E93);
  static const Color categoryShopping = Color(0xFFA2845E);

  // ── Premium Gradients (More subtle, Apple-esque) ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF385C), Color(0xFFFF5A78)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF003580), Color(0xFF1E5BB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFFD194)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF34C759)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFFFF385C), Color(0xFF007AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xDD000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlayStrong = LinearGradient(
    colors: [Color(0x00000000), Color(0xEE000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient shimmer = LinearGradient(
    colors: [
      Color(0xFF1C1C1E),
      Color(0xFF2C2C2E),
      Color(0xFF1C1C1E),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.5, 0),
    end: Alignment(1.5, 0),
  );

  // ── Radial Glows (for hero sections) ──
  static RadialGradient primaryGlow = RadialGradient(
    colors: [
      primary.withValues(alpha: 0.15),
      primary.withValues(alpha: 0.0),
    ],
    radius: 0.8,
  );

  static RadialGradient secondaryGlow = RadialGradient(
    colors: [
      secondary.withValues(alpha: 0.10),
      secondary.withValues(alpha: 0.0),
    ],
    radius: 0.8,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
