// ─── App Shell & Bottom Navigation ──────────────────────────────────
// ShellRoute scaffold with animated bottom nav and 5 persistent tabs.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

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
      path: '/home',
    ),
    _TabItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      path: '/discover',
    ),
    _TabItem(
      label: 'Trips',
      icon: Icons.flight_takeoff_outlined,
      activeIcon: Icons.flight_takeoff_rounded,
      path: '/dashboard',
    ),
    _TabItem(
      label: 'Wander AI',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      path: '/ai-chat',
    ),
    _TabItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      path: '/profile',
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

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: widget.child,
      bottomNavigationBar: _AppBottomNav(
        tabs: _tabs,
        currentIndex: activeIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDark.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = index == currentIndex;
              // Center tab is the AI copilot — make it a FAB
              if (index == 3) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: Center(
                      child: AnimatedContainer(
                        duration: AppTheme.durationMedium,
                        curve: Curves.easeOutCubic,
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? AppColors.auroraGradient
                              : const LinearGradient(
                                  colors: [
                                    AppColors.surfaceElevatedDark,
                                    AppColors.surfaceElevatedDark
                                  ],
                                ),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLG),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                          .animate(target: isActive ? 1 : 0)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 200.ms,
                          ),
                    ),
                  ),
                );
              }
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => onTap(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: AppTheme.durationMedium,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              isActive ? tab.activeIcon : tab.icon,
              color: isActive ? AppColors.primary : AppColors.textMutedDark,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: AppTheme.durationFast,
            style: AppTypography.labelSmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.textMutedDark,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(tab.label),
          ),
        ],
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
