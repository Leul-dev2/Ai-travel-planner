// ─── App Shell & Bottom Navigation ──────────────────────────────────
// Premium Apple-style fixed bottom navigation with a Floating AI Button.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../constants/route_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      path: RouteNames.home,
    ),
    _TabItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      path: RouteNames.discover,
    ),
    _TabItem(
      label: 'Trips',
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      path: RouteNames.dashboard,
    ),
    _TabItem(
      label: 'Planner',
      icon: Icons.auto_awesome_mosaic_outlined,
      activeIcon: Icons.auto_awesome_mosaic_rounded,
      path: RouteNames.planTrip,
    ),
    _TabItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      path: RouteNames.profile,
    ),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    context.go(_tabs[index].path);
  }

  int _indexFromLocation(String location) {
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _indexFromLocation(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Hide FAB if keyboard is open
    final bool hideFab = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: widget.child,
      floatingActionButton: hideFab
          ? null
          : FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(RouteNames.aiChat);
              },
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceAltDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderSubtleLight,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: activeIndex,
          onDestinationSelected: _onTabTap,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _tabs.map((tab) {
            return NavigationDestination(
              icon: Icon(
                tab.icon,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              selectedIcon: Icon(
                tab.activeIcon,
                color: AppColors.primary,
              ),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
