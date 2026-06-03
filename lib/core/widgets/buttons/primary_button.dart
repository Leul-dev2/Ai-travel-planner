// ─── Primary Button ─────────────────────────────────────────────────
// Main CTA button with loading state, icon support, and variants.

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

enum ButtonVariant { filled, outlined, ghost }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final bool fullWidth;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.fullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.button.copyWith(
                  color: variant == ButtonVariant.filled
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 16,
                  color: variant == ButtonVariant.filled
                      ? Colors.white
                      : AppColors.primary,
                ),
              ],
            ],
          );

    final ButtonStyle style;
    switch (variant) {
      case ButtonVariant.filled:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 18,
            horizontal: 24,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
        );
        break;
      case ButtonVariant.outlined:
        style = ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 18,
            horizontal: 24,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            side: const BorderSide(color: AppColors.primary),
          ),
        );
        break;
      case ButtonVariant.ghost:
        style = ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 18,
            horizontal: 24,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
        );
        break;
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: style,
      child: buttonChild,
    );
  }
}
