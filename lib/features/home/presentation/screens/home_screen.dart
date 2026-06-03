// ─── Home Screen ────────────────────────────────────────────────────
// Premium home dashboard with animated hero, quick actions, and trip cards.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.auroraGradient,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMutedDark,
                              ),
                            ),
                            Text(
                              (user?.name ?? 'Traveler').toUpperCase(),
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.notifications_outlined,
                          onTap: () => context.push(RouteNames.notifications),
                          badge: true,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.profile),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                (user?.name ?? 'T')[0].toUpperCase(),
                                style: AppTypography.titleSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
            ),

            // ── Hero Section with Animated Gradient Glow ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated hero title
                    Stack(
                      children: [
                        // Glow behind text
                        Positioned(
                          top: 10,
                          left: 0,
                          child: Container(
                            width: 120,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        const ScreenHeader(
                          line1: 'WHERE TO',
                          line2: 'NEXT?',
                          subtitle: 'Plan your perfect trip with AI',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Main CTA with gradient border
                    GlassCard(
                      onTap: () => context.push(RouteNames.planTrip),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.auroraGradient,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLG),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 26)
                                .animate(
                                    onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.1, 1.1),
                                  duration: 2000.ms,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI TRIP PLANNER',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.textPrimaryDark,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Generate a personalized itinerary',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMD),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: AppColors.primary, size: 18),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.15, end: 0),
                  ],
                ),
              ),
            ),

            // ── Quick Actions Grid ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUICK ACTIONS',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textMutedDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.chat_bubble_outline,
                            label: 'AI Chat',
                            subtitle: 'Travel Copilot',
                            gradient: AppColors.auroraGradient,
                            onTap: () => context.push(RouteNames.aiChat),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.map_outlined,
                            label: 'Explore',
                            subtitle: 'Map View',
                            gradient: AppColors.secondaryGradient,
                            onTap: () => context.push(RouteNames.map),
                          ),
                        ),
                      ],
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Budget',
                            subtitle: 'Track Spending',
                            gradient: AppColors.sunsetGradient,
                            onTap: () =>
                                context.push(RouteNames.budgetOverview),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.cloud_outlined,
                            label: 'Weather',
                            subtitle: 'Forecast',
                            gradient: AppColors.oceanGradient,
                            onTap: () => context.push(RouteNames.weather),
                          ),
                        ),
                      ],
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ),

            // ── Recent Trips ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT TRIPS',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textMutedDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.dashboard),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          'VIEW ALL',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
                child: GlassCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.explore_outlined,
                                color: AppColors.textMutedDark, size: 30)
                            .animate(
                                onPlay: (c) => c.repeat(reverse: true))
                            .rotate(
                              begin: -0.05,
                              end: 0.05,
                              duration: 3000.ms,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trips yet',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start planning your first adventure!',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Plan a Trip',
                        icon: Icons.add,
                        onTap: () => context.push(RouteNames.planTrip),
                        fullWidth: false,
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(
                    begin: 0.1,
                    end: 0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAltDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Icon(icon, color: AppColors.textSecondaryDark, size: 20),
          ),
          if (badge)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: AppTheme.radiusXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
