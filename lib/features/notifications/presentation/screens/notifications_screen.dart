// ─── Notifications Screen ────────────────────────────────────────────
// Notification center with categories and dismiss gestures.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = [
    _Notification(
      icon: Icons.flight_takeoff_rounded,
      iconColor: AppColors.primary,
      title: 'Trip starts in 3 days!',
      body: 'Your Bali Escape trip begins on June 5. Check your itinerary.',
      time: '2h ago',
      isUnread: true,
    ),
    _Notification(
      icon: Icons.wb_sunny_rounded,
      iconColor: AppColors.accentWarm,
      title: 'Weather alert for Kyoto',
      body: 'Rain expected on Day 3 of your trip. Pack an umbrella!',
      time: '5h ago',
      isUnread: true,
    ),
    _Notification(
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.secondary,
      title: 'Your itinerary is ready',
      body: 'Wander AI has finished planning your 7-day Tokyo adventure.',
      time: '1d ago',
      isUnread: false,
    ),
    _Notification(
      icon: Icons.people_alt_rounded,
      iconColor: AppColors.catCulture,
      title: 'Sarah joined your trip',
      body: 'Sarah Lindqvist accepted your invitation to the Paris Getaway.',
      time: '2d ago',
      isUnread: false,
    ),
    _Notification(
      icon: Icons.local_offer_rounded,
      iconColor: AppColors.success,
      title: '30% off Premium Plan',
      body: 'Upgrade now and unlock unlimited AI itineraries, offline maps, and more.',
      time: '3d ago',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimaryDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    GestureDetector(
                      onTap: () => setState(() {
                        for (final n in _notifications) {
                          n.isUnread = false;
                        }
                      }),
                      child: Text(
                        'Mark all read',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            // ── List ──
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded,
                              size: 64, color: AppColors.textMutedDark),
                          SizedBox(height: 12),
                          Text('All caught up!',
                              style: TextStyle(color: AppColors.textMutedDark)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _notifications.length,
                      itemBuilder: (_, i) {
                        final n = _notifications[i];
                        return Dismissible(
                          key: Key(n.title),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              setState(() => _notifications.removeAt(i)),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: AppColors.error,
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white),
                          ),
                          child: _NotificationTile(
                            notification: n,
                            onTap: () => setState(() => n.isUnread = false),
                          ).animate(delay: Duration(milliseconds: i * 60))
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.05, end: 0),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notification {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool isUnread;

  _Notification({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });
}

class _NotificationTile extends StatelessWidget {
  final _Notification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationMedium,
        color: notification.isUnread
            ? AppColors.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notification.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(notification.icon,
                  color: notification.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: notification.isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (notification.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.time,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
