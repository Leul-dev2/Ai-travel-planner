// ─── Glass Card ─────────────────────────────────────────────────────
// Premium glassmorphism-style container card used throughout the app.

import 'dart:ui';
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
  final bool enableBlur;

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
    final borderRadius =
        BorderRadius.circular(widget.radius ?? AppTheme.radiusXXL);

    Widget cardContent = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingLG),
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.surfaceDark,
          borderRadius: borderRadius,
          border: widget.hasBorder
              ? Border.all(color: Colors.white.withValues(alpha: 0.07))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (widget.enableBlur) {
      cardContent = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: cardContent,
        ),
      );
    }

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
