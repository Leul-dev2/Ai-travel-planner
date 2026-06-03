// ─── Shimmer Loading ────────────────────────────────────────────────
// Skeleton shimmer effect for loading placeholders.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double? radius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.radius ?? AppTheme.radiusMD,
            ),
            gradient: LinearGradient(
              colors: const [
                AppColors.surfaceAltDark,
                AppColors.surfaceElevatedDark,
                AppColors.surfaceAltDark,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.5 + (3 * _ctrl.value), 0),
              end: Alignment(1.5 + (3 * _ctrl.value), 0),
            ),
          ),
        );
      },
    );
  }
}

/// A column of shimmer lines for text-like loading placeholders.
class ShimmerLines extends StatelessWidget {
  final int lines;
  final double spacing;

  const ShimmerLines({super.key, this.lines = 3, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines * 2 - 1, (index) {
        if (index.isOdd) return SizedBox(height: spacing);
        final lineIndex = index ~/ 2;
        return ShimmerLoading(
          height: 14,
          width: lineIndex == lines - 1 ? 120 : double.infinity,
        );
      }),
    );
  }
}
