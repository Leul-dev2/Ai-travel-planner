// ─── Icon Action Button ─────────────────────────────────────────────
// Small icon-based action button for toolbars and compact UI.

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? backgroundColor;

  const IconActionButton({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color ?? AppColors.primary,
            ),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: color ?? AppColors.textSecondaryDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
