// ─── Onboarding Screen ───────────────────────────────────────────────
// Premium 4-page parallax onboarding for first-time users.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      gradient: AppColors.oceanGradient,
      icon: Icons.public_rounded,
      title: 'Discover Dream\nDestinations',
      body:
          'Explore thousands of breathtaking places curated by local experts and AI-powered recommendations.',
      accentColor: AppColors.primary,
    ),
    _OnboardingPage(
      gradient: AppColors.auroraGradient,
      icon: Icons.auto_awesome_rounded,
      title: 'AI Plans Your\nPerfect Trip',
      body:
          'Tell Wander AI where you want to go. It crafts a personalized day-by-day itinerary in seconds.',
      accentColor: AppColors.secondary,
    ),
    _OnboardingPage(
      gradient: AppColors.sunsetGradient,
      icon: Icons.analytics_outlined,
      title: 'Smart Budget\n& Weather',
      body:
          'Real-time spending analytics and 7-day forecasts keep your trip on track no matter what.',
      accentColor: AppColors.accentWarm,
    ),
    _OnboardingPage(
      gradient: LinearGradient(
        colors: [Color(0xFF9B5DE5), Color(0xFF6C63FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.people_alt_outlined,
      title: 'Travel Together,\nAnywhere',
      body:
          'Invite friends, vote on activities, and co-plan your adventures with real-time collaboration.',
      accentColor: AppColors.primary,
    ),
  ];

  Future<void> _markOnboardingDone() async {
    if (!Hive.isBoxOpen('app_prefs')) {
      await Hive.openBox('app_prefs');
    }
    final box = Hive.box('app_prefs');
    await box.put('onboarding_done', true);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      HapticFeedback.selectionClick();
      _ctrl.nextPage(
        duration: AppTheme.durationSlow,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    HapticFeedback.mediumImpact();
    await _markOnboardingDone();
    if (mounted) context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Pages ──
          PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPageView(page: _pages[i]),
          ),

          // ── Skip ──
          Positioned(
            top: 56,
            right: 24,
            child: GestureDetector(
              onTap: _finish,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Skip',
                  style: AppTypography.labelMedium.copyWith(color: Colors.white),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ),

          // ── Bottom Controls ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: AppTheme.durationMedium,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentPage == i ? 28 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.bgDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: AppTypography.button.copyWith(
                            color: AppColors.bgDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Gradient background ──
        DecoratedBox(decoration: BoxDecoration(gradient: page.gradient)),

        // ── Subtle pattern overlay ──
        Opacity(
          opacity: 0.04,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemBuilder: (_, __) => const Icon(
              Icons.circle,
              size: 4,
              color: Colors.white,
            ),
          ),
        ),

        // ── Dark bottom overlay for text legibility ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),
        ),

        // ── Content ──
        Positioned(
          left: 0,
          right: 0,
          bottom: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(page.icon, size: 40, color: Colors.white),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // Title
                Text(
                  page.title,
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 100.ms),

                const SizedBox(height: 16),

                // Body
                Text(
                  page.body,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String body;
  final Color accentColor;

  const _OnboardingPage({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.body,
    required this.accentColor,
  });
}
