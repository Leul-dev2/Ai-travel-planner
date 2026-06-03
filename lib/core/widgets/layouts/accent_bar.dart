// ─── Accent Bar ─────────────────────────────────────────────────────
// Small colored bar used as a visual section indicator.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AccentBar extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const AccentBar({
    super.key,
    this.width = 48,
    this.height = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
