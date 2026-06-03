// ─── Data Point ─────────────────────────────────────────────────────
// Label + value display for review screens and detail views.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class DataPoint extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const DataPoint({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.textMutedDark),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMutedDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value.toUpperCase(),
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
