// ─── App Loader ─────────────────────────────────────────────────────
// Animated spinning loader with optional label.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppLoader extends StatefulWidget {
  final String? label;
  final double size;

  const AppLoader({super.key, this.label, this.size = 48});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _ctrl,
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: widget.size,
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 20),
          Text(
            widget.label!.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMutedDark,
            ),
          ),
        ],
      ],
    );
  }
}
