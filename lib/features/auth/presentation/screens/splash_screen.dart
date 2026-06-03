// ─── Splash Screen ───────────────────────────────────────────────────
// Branded animated splash — checks auth & routes to onboarding or home.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initApp();
  }

  Future<void> _initApp() async {
    // Brief delay for brand impression
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Check auth
    try {
      await ref.read(checkAuthProvider.future);
      if (!mounted) return;
      final isLoggedIn = ref.read(authStateProvider).isAuthenticated;
      if (isLoggedIn) {
        context.go(RouteNames.home);
      } else {
        // Ensure Hive box is open (web can lose it between navigations)
        if (!Hive.isBoxOpen('app_prefs')) {
          await Hive.openBox('app_prefs');
        }
        final box = Hive.box('app_prefs');
        final onboardingDone =
            box.get('onboarding_done', defaultValue: false) as bool;
        if (onboardingDone) {
          if (mounted) context.go(RouteNames.login);
        } else {
          if (mounted) context.go(RouteNames.onboarding);
        }
      }
    } catch (_) {
      if (mounted) context.go(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Radial glow background ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.primary.withValues(
                          alpha: 0.12 + (_glowCtrl.value * 0.06)),
                      AppColors.bgDark,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Center logo ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.auroraGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // App name
                Text(
                  'Wanderlust',
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms),

                Text(
                  'AI Travel Planner',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textMutedDark,
                    letterSpacing: 2.5,
                  ),
                )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms),
              ],
            ),
          ),

          // ── Loading dots ──
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: _LoadingDots(),
            ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(
          reverse: true,
          period: Duration(milliseconds: 600 + (i * 200)),
        ),
    );
    for (int i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6 + (_ctrls[i].value * 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                  alpha: 0.4 + (_ctrls[i].value * 0.6)),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
