// ─── Empty State Widget ──────────────────────────────────────────────
// Premium empty states with contextual icons, messaging, and CTAs.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

enum EmptyStateType {
  noTrips,
  noSaved,
  noResults,
  offline,
  noNotifications,
  noMessages,
  generic,
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? customIcon;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.generic,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    this.iconColor,
  });

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
            // ── Animated Icon ──
            _AnimatedEmptyIcon(
              icon: customIcon ?? config.icon,
              color: iconColor ?? config.color,
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),

            const SizedBox(height: AppTheme.spacingLG),

            // ── Title ──
            Text(
              title ?? config.title,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: AppTheme.spacingSM),

            // ── Message ──
            Text(
              message ?? config.message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMutedDark,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              PrimaryButton(
                label: actionLabel!,
                onTap: onAction,
                fullWidth: false,
                icon: config.actionIcon,
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig get _configForType {
    switch (type) {
      case EmptyStateType.noTrips:
        return const _EmptyStateConfig(
          icon: Icons.flight_takeoff_rounded,
          color: AppColors.primary,
          title: 'No trips yet',
          message: 'Start planning your first adventure and let AI craft the perfect itinerary for you.',
          actionIcon: Icons.add_rounded,
        );
      case EmptyStateType.noSaved:
        return const _EmptyStateConfig(
          icon: Icons.favorite_border_rounded,
          color: AppColors.accent,
          title: 'Nothing saved yet',
          message: 'Explore destinations and tap the heart icon to save places you love.',
          actionIcon: Icons.explore_rounded,
        );
      case EmptyStateType.noResults:
        return const _EmptyStateConfig(
          icon: Icons.search_off_rounded,
          color: AppColors.secondary,
          title: 'No results found',
          message: 'Try different search terms or explore trending destinations.',
          actionIcon: Icons.tune_rounded,
        );
      case EmptyStateType.offline:
        return const _EmptyStateConfig(
          icon: Icons.wifi_off_rounded,
          color: AppColors.warning,
          title: 'You\'re offline',
          message: 'Check your internet connection. Your saved trips are still available.',
          actionIcon: Icons.refresh_rounded,
        );
      case EmptyStateType.noNotifications:
        return const _EmptyStateConfig(
          icon: Icons.notifications_none_rounded,
          color: AppColors.textMutedDark,
          title: 'All caught up!',
          message: 'No new notifications. We\'ll alert you about trip updates and travel deals.',
        );
      case EmptyStateType.noMessages:
        return const _EmptyStateConfig(
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.primary,
          title: 'Start a conversation',
          message: 'Ask your AI travel copilot anything about destinations, budgets, or itineraries.',
          actionIcon: Icons.auto_awesome_rounded,
        );
      case EmptyStateType.generic:
        return const _EmptyStateConfig(
          icon: Icons.inbox_rounded,
          color: AppColors.textMutedDark,
          title: 'Nothing here yet',
          message: 'Content will appear here once available.',
        );
    }
  }
}

class _EmptyStateConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final IconData? actionIcon;

  const _EmptyStateConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.actionIcon,
  });
}

class _AnimatedEmptyIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _AnimatedEmptyIcon({required this.icon, required this.color});

  @override
  State<_AnimatedEmptyIcon> createState() => _AnimatedEmptyIconState();
}

class _AnimatedEmptyIconState extends State<_AnimatedEmptyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: child,
      ),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.12),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Icon(widget.icon, size: 48, color: widget.color),
      ),
    );
  }
}
