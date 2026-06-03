// ─── Paywall Screen ──────────────────────────────────────────────────
// Premium subscription paywall with 3 tiers, feature comparison, and CTA.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlan = 1; // Pro by default

  static const _plans = [
    _Plan(
      name: 'Free',
      price: '\$0',
      period: 'forever',
      color: AppColors.textMutedDark,
      features: [
        '3 AI itineraries / month',
        'Basic destination search',
        'Manual budget tracking',
        'Standard support',
      ],
      locked: ['Offline maps', 'Unlimited AI chat', 'Collaboration', 'Priority support'],
    ),
    _Plan(
      name: 'Pro',
      price: '\$9.99',
      period: 'per month',
      color: AppColors.primary,
      badge: '🔥 Most Popular',
      features: [
        'Unlimited AI itineraries',
        'Advanced destination search',
        'Smart budget analytics',
        'Offline map downloads',
        'Collaborate with 5 people',
        'Priority AI responses',
      ],
      locked: [],
    ),
    _Plan(
      name: 'Ultimate',
      price: '\$19.99',
      period: 'per month',
      color: AppColors.secondary,
      badge: '💎 Best Value',
      features: [
        'Everything in Pro',
        'Unlimited collaborators',
        'White-glove trip concierge',
        'Real-time flight alerts',
        'Hotel price monitoring',
        'Dedicated support',
      ],
      locked: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_selectedPlan];
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Gradient background ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    plan.color.withValues(alpha: 0.12),
                    AppColors.bgDark,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Close ──
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceAltDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondaryDark, size: 18),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // ── Header ──
                        const Icon(Icons.workspace_premium_rounded,
                                color: AppColors.accentWarm, size: 56)
                            .animate()
                            .scale(
                                begin: const Offset(0.5, 0.5),
                                duration: 600.ms,
                                curve: Curves.elasticOut),

                        const SizedBox(height: 16),

                        Text(
                          'Unlock Wanderlust\nPremium',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.textPrimaryDark,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 8),

                        Text(
                          'Join 50,000+ travelers who plan smarter',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMutedDark,
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 400.ms),

                        const SizedBox(height: 32),

                        // ── Plan Selector ──
                        Row(
                          children: _plans.asMap().entries.map((e) {
                            final i = e.key;
                            final p = e.value;
                            final isSelected = i == _selectedPlan;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedPlan = i),
                                child: AnimatedContainer(
                                  duration: AppTheme.durationMedium,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? p.color.withValues(alpha: 0.15)
                                        : AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusXXL),
                                    border: Border.all(
                                      color: isSelected
                                          ? p.color
                                          : AppColors.borderDark,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      if (p.badge != null)
                                        Text(p.badge!,
                                            style:
                                                AppTypography.labelSmall.copyWith(
                                                    fontSize: 9)),
                                      Text(p.name,
                                          style: AppTypography.titleSmall
                                              .copyWith(
                                                  color: isSelected
                                                      ? p.color
                                                      : AppColors
                                                          .textPrimaryDark)),
                                      Text(p.price,
                                          style: AppTypography.headlineSmall
                                              .copyWith(
                                                  color: isSelected
                                                      ? p.color
                                                      : AppColors
                                                          .textPrimaryDark,
                                                  fontWeight:
                                                      FontWeight.w800)),
                                      Text(p.period,
                                          style: AppTypography.caption
                                              .copyWith(
                                                  color: AppColors
                                                      .textMutedDark)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: 28),

                        // ── Features ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusXXL),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What\'s included',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ...plan.features.map((f) => _FeatureRow(
                                    feature: f,
                                    included: true,
                                    color: plan.color,
                                  )),
                              ...plan.locked.map((f) => _FeatureRow(
                                    feature: f,
                                    included: false,
                                    color: plan.color,
                                  )),
                            ],
                          ),
                        ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // ── CTA ──
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${plan.name} plan — payment integration coming soon!'),
                                backgroundColor: AppColors.surfaceElevatedDark,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan.color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                          ),
                          child: Text(
                            _selectedPlan == 0
                                ? 'Continue with Free'
                                : 'Start 7-Day Free Trial',
                            style: AppTypography.button,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No commitment · Cancel anytime · Secure payment',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String feature;
  final bool included;
  final Color color;

  const _FeatureRow(
      {required this.feature, required this.included, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            color: included ? color : AppColors.textMutedDark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            feature,
            style: AppTypography.bodySmall.copyWith(
              color: included
                  ? AppColors.textSecondaryDark
                  : AppColors.textMutedDark,
              decoration:
                  included ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

class _Plan {
  final String name;
  final String price;
  final String period;
  final Color color;
  final String? badge;
  final List<String> features;
  final List<String> locked;

  const _Plan({
    required this.name,
    required this.price,
    required this.period,
    required this.color,
    this.badge,
    required this.features,
    required this.locked,
  });
}
