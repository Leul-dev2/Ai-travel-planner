// ─── App Card ─────────────────────────────────────────────────────
// Clean, Apple-style card component replacing GlassCard.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? radius;
  final Color? color;
  final VoidCallback? onTap;
  final bool hasBorder;
  final bool enableBlur; // Kept for API compatibility

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.onTap,
    this.hasBorder = true,
    this.enableBlur = false,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius =
        BorderRadius.circular(widget.radius ?? AppTheme.radiusXL);

    final cardContent = AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutQuart,
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingLG),
        decoration: BoxDecoration(
          color: widget.color ??
              (isDark ? AppColors.surfaceAltDark : AppColors.surfaceLight),
          borderRadius: borderRadius,
          border: widget.hasBorder
              ? Border.all(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderSubtleLight,
                  width: 1,
                )
              : null,
          boxShadow: [
            if (!isDark) // Apple styling: shadows in light mode, borders in dark
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: cardContent,
      );
    }
    return cardContent;
  }
}
