// ─── GoRouter Configuration ─────────────────────────────────────────
// ShellRoute with persistent bottom nav, auth guards, deep linking.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/ai_chat/presentation/screens/chat_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/maps/presentation/screens/map_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payments/presentation/screens/paywall_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/trip_planner/domain/entities/trip_entity.dart';
import '../../features/trip_planner/presentation/screens/itinerary_screen.dart';
import '../../features/trip_planner/presentation/screens/plan_screen.dart';
import '../../features/weather/presentation/screens/weather_screen.dart';
import '../constants/route_names.dart';
import '../widgets/navigation/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: authState,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final loc = state.matchedLocation;

      final publicRoutes = [
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
      ];
      final isPublicRoute = publicRoutes.contains(loc);

      if (!isLoggedIn && !isPublicRoute) return RouteNames.login;
      if (isLoggedIn && isPublicRoute && loc != RouteNames.splash) {
        return RouteNames.home;
      }
      return null;
    },
    routes: [
      // ── Auth / Onboarding (no shell) ──
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (_, s) => _fadeTransition(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (_, s) => _fadeTransition(s, const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (_, s) => _slideUp(s, const RegisterScreen()),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (_, s) => _slideUp(s, const ForgotPasswordScreen()),
      ),

      // ── Full-screen routes outside shell ──
      GoRoute(
        path: RouteNames.map,
        pageBuilder: (_, s) => _fadeTransition(s, const MapScreen()),
      ),
      GoRoute(
        path: RouteNames.planTrip,
        pageBuilder: (_, s) => _slideUp(s, const PlanScreen()),
      ),
      GoRoute(
        path: '/itinerary/:tripId',
        pageBuilder: (context, s) {
          final tripId = s.pathParameters['tripId'] ?? '';
          final trip = s.extra as TripEntity?;
          return _slideTransition(s, ItineraryScreen(tripId: tripId, trip: trip));
        },
      ),
      GoRoute(
        path: RouteNames.paywall,
        pageBuilder: (_, s) => _slideUp(s, const PaywallScreen()),
      ),
      GoRoute(
        path: RouteNames.admin,
        pageBuilder: (_, s) => _slideTransition(s, const AdminDashboardScreen()),
      ),

      // ── Main Shell (persistent bottom nav) ──
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (_, s) => _noTransition(s, const HomeScreen()),
          ),
          GoRoute(
            path: RouteNames.discover,
            pageBuilder: (_, s) => _noTransition(s, const DiscoverScreen()),
          ),
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (_, s) => _noTransition(s, const DashboardScreen()),
          ),
          GoRoute(
            path: RouteNames.aiChat,
            pageBuilder: (_, s) => _noTransition(s, const ChatScreen()),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (_, s) => _noTransition(s, const ProfileScreen()),
          ),
          // Sub-routes accessible from shell
          GoRoute(
            path: RouteNames.budgetOverview,
            pageBuilder: (_, s) => _slideTransition(s, const BudgetScreen()),
          ),
          GoRoute(
            path: RouteNames.weather,
            pageBuilder: (_, s) => _slideTransition(s, const WeatherScreen()),
          ),
          GoRoute(
            path: RouteNames.settings,
            pageBuilder: (_, s) => _slideTransition(s, const SettingsScreen()),
          ),
          GoRoute(
            path: RouteNames.notifications,
            pageBuilder: (_, s) => _slideTransition(s, const NotificationsScreen()),
          ),
          GoRoute(
            path: RouteNames.budgetRejected,
            pageBuilder: (context, s) => _slideTransition(
              s,
              Scaffold(
                backgroundColor: const Color(0xFF0B0D17),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 64, color: Color(0xFFF97316)),
                      const SizedBox(height: 16),
                      const Text('Budget Too Low',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Please increase your budget for this destination.',
                          style: TextStyle(color: Colors.white60),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go(RouteNames.planTrip),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _NotFoundScreen(location: state.matchedLocation),
  );
});

// ── Transitions ──
CustomTransitionPage<void> _fadeTransition(GoRouterState s, Widget child) =>
    CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 350),
    );

CustomTransitionPage<void> _slideTransition(GoRouterState s, Widget child) =>
    CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: a.drive(tween), child: c);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );

CustomTransitionPage<void> _slideUp(GoRouterState s, Widget child) =>
    CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) {
        final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: a.drive(tween), child: c);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );

CustomTransitionPage<void> _noTransition(GoRouterState s, Widget child) =>
    CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, __, ___, c) => c,
      transitionDuration: Duration.zero,
    );

class _NotFoundScreen extends StatelessWidget {
  final String location;
  const _NotFoundScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off_rounded, size: 72, color: Color(0xFF6C63FF)),
            const SizedBox(height: 24),
            const Text('Page not found',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(location, style: const TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
