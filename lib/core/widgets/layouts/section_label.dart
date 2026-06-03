// ─── Section Label ──────────────────────────────────────────────────
// Uppercase label text used for form sections and data categories.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.labelMedium.copyWith(
        color: color ?? AppColors.textMutedDark,
      ),
    );
  }
}
