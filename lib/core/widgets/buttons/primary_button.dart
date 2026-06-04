// ─── Primary Button ─────────────────────────────────────────────────
// Apple/Airbnb inspired high-end CTA button.

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.button.copyWith(
                  color: variant == ButtonVariant.filled
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2, // Apple-style tight tracking
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 18,
                  color: variant == ButtonVariant.filled
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
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
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 16,
            horizontal: 24,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
        );
        break;
      case ButtonVariant.outlined:
        style = ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 16,
            horizontal: 24,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.5,
            ),
          ),
        );
        break;
      case ButtonVariant.ghost:
        style = ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: height != null ? 0 : 16,
            horizontal: 24,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
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
