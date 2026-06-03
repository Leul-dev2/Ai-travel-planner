// ─── Stat Card ──────────────────────────────────────────────────────
// Compact card for displaying a label + value (used in dashboards).

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD + 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: valueColor ?? AppColors.primary,
              fontSize: 28,
            ),
          ),
          if (unit != null)
            Text(
              unit!.toUpperCase(),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
        ],
      ),
    );
  }
}
