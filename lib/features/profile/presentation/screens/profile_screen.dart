// ─── Profile Screen ──────────────────────────────────────────────────
// User profile with travel stats, badges, preferences, and account actions.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animations/animated_counter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final name = user?.name ?? 'Traveler';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'T';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover gradient
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: AppColors.auroraGradient,
                  ),
                ),
                // Avatar
                Positioned(
                  bottom: -44,
                  left: 24,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.bgDark, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.toUpperCase(),
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ).animate().scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.elasticOut),
                ),
                // Premium badge
                Positioned(
                  top: 56,
                  right: 24,
                  child: GestureDetector(
                    onTap: () => context.push(RouteNames.paywall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                            color: AppColors.accentWarm.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: AppColors.accentWarm, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Upgrade to Pro',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.accentWarm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 56)),

          // ── Name & Email ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  Text(
                    email,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Travel Stats ──
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatBox(label: 'Trips', value: 12),
                  SizedBox(width: 12),
                  _StatBox(label: 'Countries', value: 8),
                  SizedBox(width: 12),
                  _StatBox(label: 'Days', value: 64),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Badges ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Travel Badges',
                      style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      _Badge(emoji: '✈️', label: 'First Trip'),
                      SizedBox(width: 10),
                      _Badge(emoji: '🌍', label: '5 Countries'),
                      SizedBox(width: 10),
                      _Badge(emoji: '🎒', label: 'Solo Traveler'),
                      SizedBox(width: 10),
                      _Badge(emoji: '💰', label: 'Budget Pro'),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Menu Items ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push(RouteNames.settings),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Upgrade to Premium',
                    valueColor: AppColors.accentWarm,
                    onTap: () => context.push(RouteNames.paywall),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.star_outline_rounded,
                    label: 'Rate the App',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    valueColor: AppColors.error,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.surfaceDark,
                          title: const Text('Sign Out',
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              'Are you sure you want to sign out?',
                              style: TextStyle(color: AppColors.textMutedDark)),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Sign Out',
                                    style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        ref.read(logoutProvider);
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                ].asMap().entries.map((e) =>
                  e.value.animate(delay: Duration(milliseconds: 450 + (e.key * 50)))
                    .fadeIn(duration: 300.ms)
                ).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final double value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            AnimatedCounter(
              value: value,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textMutedDark)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String emoji;
  final String label;

  const _Badge({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary, fontSize: 9)),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? valueColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? AppColors.textPrimaryDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: AppTypography.titleSmall.copyWith(color: color))),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedDark, size: 20),
          ],
        ),
      ),
    );
  }
}
