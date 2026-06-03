// ─── Error State Widget ──────────────────────────────────────────────
// User-friendly error display — never shows raw exception strings.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

enum ErrorStateType { network, server, notFound, permission, generic }

class ErrorStateWidget extends StatelessWidget {
  final ErrorStateType type;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorStateWidget({
    super.key,
    this.type = ErrorStateType.generic,
    this.title,
    this.message,
    this.onRetry,
    this.onGoHome,
  });

  /// Factory from raw exception — sanitizes message for display.
  factory ErrorStateWidget.fromException({
    required Object error,
    ErrorStateType? type,
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    ErrorStateType detectedType = ErrorStateType.generic;
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout')) {
      detectedType = ErrorStateType.network;
    } else if (errorStr.contains('404') || errorStr.contains('not found')) {
      detectedType = ErrorStateType.notFound;
    } else if (errorStr.contains('permission') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('403')) {
      detectedType = ErrorStateType.permission;
    } else if (errorStr.contains('500') || errorStr.contains('server')) {
      detectedType = ErrorStateType.server;
    }
    return ErrorStateWidget(
      type: type ?? detectedType,
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _configForType;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Error Icon ──
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.color.withValues(alpha: 0.12),
                border: Border.all(
                  color: config.color.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(config.icon, size: 44, color: config.color),
            )
                .animate()
                .shake(
                  duration: 600.ms,
                  hz: 3,
                  offset: const Offset(3, 0),
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacingLG),

            Text(
              title ?? config.title,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacingSM),

            Text(
              message ?? config.message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMutedDark,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacingXL),

            if (onRetry != null)
              PrimaryButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onTap: onRetry,
                fullWidth: false,
              ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

            if (onGoHome != null) ...[
              const SizedBox(height: AppTheme.spacingMD),
              PrimaryButton(
                label: 'Go Home',
                icon: Icons.home_outlined,
                variant: ButtonVariant.ghost,
                onTap: onGoHome,
                fullWidth: false,
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorConfig get _configForType {
    switch (type) {
      case ErrorStateType.network:
        return const _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          color: AppColors.warning,
          title: 'No internet connection',
          message:
              'Please check your connection and try again. Cached data is still available.',
        );
      case ErrorStateType.server:
        return const _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          color: AppColors.error,
          title: 'Server issue',
          message: 'Our servers are temporarily unavailable. Please try again in a moment.',
        );
      case ErrorStateType.notFound:
        return const _ErrorConfig(
          icon: Icons.search_off_rounded,
          color: AppColors.secondary,
          title: 'Not found',
          message: "We couldn't find what you're looking for. It may have been moved or deleted.",
        );
      case ErrorStateType.permission:
        return const _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          color: AppColors.warning,
          title: 'Access denied',
          message: "You don't have permission to view this content. Please sign in or contact support.",
        );
      case ErrorStateType.generic:
        return const _ErrorConfig(
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
          title: 'Something went wrong',
          message:
              'An unexpected error occurred. Please try again or contact support if the issue persists.',
        );
    }
  }
}

class _ErrorConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  const _ErrorConfig(
      {required this.icon,
      required this.color,
      required this.title,
      required this.message});
}
