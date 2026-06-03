// ─── Screen Header ──────────────────────────────────────────────────
// Reusable screen title component with accent bar and two-line styling.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'accent_bar.dart';

class ScreenHeader extends StatelessWidget {
  final String line1;
  final String line2;
  final String? subtitle;

  const ScreenHeader({
    super.key,
    required this.line1,
    required this.line2,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AccentBar(),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            children: [
              TextSpan(text: '$line1\n'),
              TextSpan(
                text: line2,
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMutedDark,
            ),
          ),
        ],
      ],
    );
  }
}
