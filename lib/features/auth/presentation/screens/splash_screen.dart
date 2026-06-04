// ─── Splash Screen ───────────────────────────────────────────────────
// Minimalist, premium brand animation — checks auth & routes to onboarding or home.

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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Brief delay for brand impression
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check auth
    try {
      await ref.read(checkAuthProvider.future);
      if (!mounted) return;
      final isLoggedIn = ref.read(authStateProvider).isAuthenticated;
      if (isLoggedIn) {
        context.go(RouteNames.home);
      } else {
        // Ensure Hive box is open
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Apple-style minimalist logo reveal
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: isDark ? Colors.black : Colors.white,
                size: 48,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 1000.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(duration: 800.ms),

            const SizedBox(height: 32),

            // Typography
            Text(
              'WANDERLUST',
              style: AppTypography.displayMedium.copyWith(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                fontSize: 24,
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 8),

            Text(
              'INTELLIGENT TRAVEL',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
