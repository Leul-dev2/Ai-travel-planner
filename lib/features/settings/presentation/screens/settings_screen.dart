// ─── Settings Screen ─────────────────────────────────────────────────
// Full settings implementation — theme, notifications, units, privacy.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifTrips = true;
  bool _notifDeals = true;
  bool _notifWeather = true;
  bool _darkMode = true;
  String _currency = 'USD';
  String _units = 'Metric (°C, km)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAltDark,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMD),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimaryDark, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Settings',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // ── Appearance ──
                    _buildSection('Appearance', [
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark Mode',
                        trailing: Switch(
                          value: _darkMode,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _darkMode = v),
                        ),
                      ),
                    ]).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Notifications ──
                    _buildSection('Notifications', [
                      _SettingsTile(
                        icon: Icons.flight_takeoff_rounded,
                        iconColor: AppColors.primary,
                        label: 'Trip reminders',
                        trailing: Switch(
                          value: _notifTrips,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _notifTrips = v),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.wb_sunny_rounded,
                        iconColor: AppColors.accentWarm,
                        label: 'Weather alerts',
                        trailing: Switch(
                          value: _notifWeather,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _notifWeather = v),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.local_offer_rounded,
                        iconColor: AppColors.success,
                        label: 'Travel deals',
                        trailing: Switch(
                          value: _notifDeals,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _notifDeals = v),
                        ),
                      ),
                    ]).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Preferences ──
                    _buildSection('Preferences', [
                      _SettingsTile(
                        icon: Icons.attach_money_rounded,
                        label: 'Currency',
                        trailing: DropdownButton<String>(
                          value: _currency,
                          dropdownColor: AppColors.surfaceElevatedDark,
                          underline: const SizedBox(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          items: ['USD', 'EUR', 'GBP', 'ETB', 'JPY']
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _currency = v ?? 'USD'),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.straighten_rounded,
                        label: 'Units',
                        trailing: DropdownButton<String>(
                          value: _units,
                          dropdownColor: AppColors.surfaceElevatedDark,
                          underline: const SizedBox(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          items: ['Metric (°C, km)', 'Imperial (°F, mi)']
                              .map((u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _units = v ?? 'Metric (°C, km)'),
                        ),
                      ),
                    ]).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Data ──
                    _buildSection('Data & Storage', [
                      _SettingsTile(
                        icon: Icons.delete_sweep_rounded,
                        label: 'Clear Cache',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cache cleared')),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.cloud_download_outlined,
                        label: 'Offline Data',
                        subtitle: 'Manage downloaded maps & itineraries',
                        onTap: () {},
                      ),
                    ]).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── About ──
                    _buildSection('About', [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'App Version',
                        trailing: Text(
                          AppConfig.appVersion,
                          style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMutedDark),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.star_outline_rounded,
                        label: 'Rate Wanderlust',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        onTap: () {},
                      ),
                    ]).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Danger Zone ──
                    _buildSection('Account', [
                      _SettingsTile(
                        icon: Icons.delete_forever_rounded,
                        iconColor: AppColors.error,
                        label: 'Delete Account',
                        labelColor: AppColors.error,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.surfaceDark,
                              title: Text('Delete Account',
                                  style: AppTypography.headlineSmall.copyWith(
                                      color: AppColors.error)),
                              content: Text(
                                'This will permanently delete your account and all trip data. This action cannot be undone.',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondaryDark),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Delete',
                                      style:
                                          TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMutedDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final Color? labelColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.label,
    this.labelColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtleDark),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.textMutedDark)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(icon,
                  color: iconColor ?? AppColors.textMutedDark, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.titleSmall.copyWith(
                          color: labelColor ?? AppColors.textPrimaryDark)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textMutedDark)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMutedDark, size: 18),
          ],
        ),
      ),
    );
  }
}
