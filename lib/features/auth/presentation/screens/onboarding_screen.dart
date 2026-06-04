// ─── Onboarding Screen ───────────────────────────────────────────────
// Premium Apple/Airbnb style onboarding with fullscreen photography.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

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
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=1000',
      title: 'Discover Dream\nDestinations',
      body: 'Explore thousands of breathtaking places curated by local experts and AI recommendations.',
    ),
    _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?q=80&w=1000',
      title: 'AI Plans Your\nPerfect Trip',
      body: 'Tell Wander AI where you want to go. It crafts a personalized day-by-day itinerary in seconds.',
    ),
    _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1000',
      title: 'Smart Budget\n& Weather',
      body: 'Real-time spending analytics and 7-day forecasts keep your trip on track no matter what.',
    ),
    _OnboardingPage(
      imageUrl: 'https://images.unsplash.com/photo-1526772662000-3f88f10405ff?q=80&w=1000',
      title: 'Travel Together,\nAnywhere',
      body: 'Invite friends, vote on activities, and co-plan your adventures with real-time collaboration.',
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
      backgroundColor: Colors.black, // Always dark for photo bleed
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
                  color: Colors.black.withValues(alpha: 0.3),
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
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
                        width: _currentPage == i ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  PrimaryButton(
                    label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                    onTap: _next,
                    variant: ButtonVariant.filled,
                  ),
                ],
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
        // ── Fullscreen Image ──
        CachedNetworkImage(
          imageUrl: page.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.surfaceAltDark),
          errorWidget: (_, __, ___) => Container(color: AppColors.surfaceAltDark),
        ),

        // ── Gradient Overlay ──
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000), // Slight top dim for status bar / skip button
                Colors.transparent,
                Colors.transparent,
                Color(0xCC000000), // Heavy bottom dim for text legibility
                Color(0xFA000000),
              ],
              stops: [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
          ),
        ),

        // ── Content ──
        Positioned(
          left: 32,
          right: 32,
          bottom: 160, // Above controls
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.title,
                style: AppTypography.displayMedium.copyWith(
                  color: Colors.white,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              Text(
                page.body,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final String imageUrl;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.imageUrl,
    required this.title,
    required this.body,
  });
}
