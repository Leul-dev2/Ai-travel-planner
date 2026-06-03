// ─── App Color Palette ──────────────────────────────────────────────
// Production-grade color system for Wanderlust AI brand.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Primary ──
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42DB);
  static const Color primaryContainer = Color(0xFF1A1640);

  // ── Brand Secondary ──
  static const Color secondary = Color(0xFF00D4AA);
  static const Color secondaryLight = Color(0xFF33DDBB);
  static const Color secondaryDark = Color(0xFF00A888);

  // ── Brand Accent (Warm) ──
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  static const Color accentWarm = Color(0xFFFFB347);

  // ── Success / Error / Warning / Info ──
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successBg = Color(0xFF0A2E20);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorBg = Color(0xFF2E0A0A);
  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningBg = Color(0xFF2E1A0A);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // ── Dark Theme Surfaces ──
  static const Color bgDark = Color(0xFF0B0D17);
  static const Color surfaceDark = Color(0xFF12142A);
  static const Color surfaceAltDark = Color(0xFF1A1D36);
  static const Color surfaceElevatedDark = Color(0xFF232745);
  static const Color borderDark = Color(0xFF2A2E4A);
  static const Color borderSubtleDark = Color(0xFF1F2240);

  // ── Text Colors (Dark Theme) ──
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF556380);
  static const Color textDisabledDark = Color(0xFF334155);

  // ── Light Theme Surfaces ──
  static const Color bgLight = Color(0xFFF5F7FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF0F2F8);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFEEF0F6);

  // ── Text Colors (Light Theme) ──
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // ── Glass Effect ──
  static const Color glassLight = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x0AFFFFFF);

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
  static const Color categoryHotel = Color(0xFF6366F1);
  static const Color categoryFood = Color(0xFFF97316);
  static const Color categoryTransport = Color(0xFF14B8A6);
  static const Color categoryActivity = Color(0xFFEC4899);
  static const Color categoryOther = Color(0xFF8B5CF6);
  static const Color categoryShopping = Color(0xFFF59E0B);

  // ── Premium Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFB347), Color(0xFFFFC371)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4AA), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xDD0B0D17)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlayStrong = LinearGradient(
    colors: [Color(0x000B0D17), Color(0xEE0B0D17)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient shimmer = LinearGradient(
    colors: [
      Color(0xFF1A1D36),
      Color(0xFF232745),
      Color(0xFF1A1D36),
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

  // ── Accent Gradient ── (kept for backward compat)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
