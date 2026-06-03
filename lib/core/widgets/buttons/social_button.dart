// ─── Social Login Button ────────────────────────────────────────────
// Branded social sign-in buttons (Google, Apple).

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

enum SocialProvider { google, apple }

class SocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onTap;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.provider,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _providerConfig;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceAltDark,
          foregroundColor: AppColors.textPrimaryDark,
          side: const BorderSide(color: AppColors.borderDark),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(config.icon, size: 20, color: config.iconColor),
                  const SizedBox(width: 12),
                  Text(
                    'CONTINUE WITH ${config.label.toUpperCase()}',
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _SocialConfig get _providerConfig {
    switch (provider) {
      case SocialProvider.google:
        return const _SocialConfig(
          label: 'Google',
          icon: Icons.g_mobiledata_rounded,
          iconColor: Color(0xFFEA4335),
        );
      case SocialProvider.apple:
        return const _SocialConfig(
          label: 'Apple',
          icon: Icons.apple,
          iconColor: Colors.white,
        );
    }
  }
}

class _SocialConfig {
  final String label;
  final IconData icon;
  final Color iconColor;

  const _SocialConfig({
    required this.label,
    required this.icon,
    required this.iconColor,
  });
}
