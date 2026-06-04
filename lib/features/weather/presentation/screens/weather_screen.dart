// ─── Weather Screen ───────────────────────────────────────────────────
// Premium weather with animated gradient cards, packing suggestions, 5-day feel.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/weather_api_service.dart';
import '../../domain/entities/weather_entity.dart';

final weatherApiServiceProvider = Provider((ref) => const WeatherApiService());

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen>
    with TickerProviderStateMixin {
  final _cityCtrl = TextEditingController();
  WeatherForecast? _forecast;
  String? _error;
  bool _loading = false;
  late AnimationController _iconCtrl;

  static const _quickCities = [
    'Tokyo',
    'Paris',
    'Dubai',
    'Bali',
    'New York',
    'Barcelona',
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch([String? city]) async {
    final q = city ?? _cityCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _error = 'Please enter a city name');
      return;
    }
    if (city != null) _cityCtrl.text = city;
    HapticFeedback.selectionClick();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final forecast =
          await ref.read(weatherApiServiceProvider).fetchCurrent(city: q);
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load weather. Check your API key or try again.';
        _loading = false;
      });
    }
  }

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
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimaryDark, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weather',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w800,
                            )),
                        Text('Check before you go',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textMutedDark)),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Search Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAltDark,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: TextField(
                          controller: _cityCtrl,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textPrimaryDark),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _fetch(),
                          decoration: InputDecoration(
                            hintText: 'Enter city (e.g. Tokyo)',
                            hintStyle: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textMutedDark),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 18),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.textMutedDark, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _loading ? null : () => _fetch(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _loading ? null : AppColors.auroraGradient,
                          color: _loading ? AppColors.surfaceAltDark : null,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          boxShadow: _loading
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: _loading
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.wb_sunny_rounded,
                                color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            ),

            // ── Quick city chips ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _quickCities.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _fetch(_quickCities[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          _quickCities[i],
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.textSecondaryDark),
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ),

            // ── Error ──
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_error!,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
              ),

            // ── Weather Result ──
            if (_forecast != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _gradientForCondition(_forecast!.description),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                      boxShadow: [
                        BoxShadow(
                          color: _gradientForCondition(_forecast!.description)
                              .colors
                              .first
                              .withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -10,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _forecast!.city,
                                        style: AppTypography.headlineSmall
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        _forecast!.country,
                                        style: AppTypography.bodyMedium
                                            .copyWith(color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                  // Weather icon
                                  RotationTransition(
                                    turns: _iconCtrl,
                                    child: Text(
                                      _emojiForCondition(
                                          _forecast!.description),
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _forecast!.tempDisplay(),
                                    style: AppTypography.displayLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      _forecast!.description.toUpperCase(),
                                      style: AppTypography.labelMedium.copyWith(
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Stats row
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusLG),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _WeatherStat(
                                      icon: Icons.thermostat_outlined,
                                      label: 'Feels Like',
                                      value:
                                          '${_forecast!.feelsLike.round()}°C',
                                    ),
                                    _Divider(),
                                    _WeatherStat(
                                      icon: Icons.water_drop_outlined,
                                      label: 'Humidity',
                                      value: '${_forecast!.humidity}%',
                                    ),
                                    _Divider(),
                                    _WeatherStat(
                                      icon: Icons.air_rounded,
                                      label: 'Wind',
                                      value:
                                          '${_forecast!.windSpeed.round()} m/s',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
              ),

              // ── Packing Suggestions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accentWarm.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMD),
                              ),
                              child: const Icon(Icons.luggage_rounded,
                                  color: AppColors.accentWarm, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Packing Suggestions',
                                style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.textPrimaryDark,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ..._packingSuggestions(_forecast!).asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.check_rounded,
                                          color: AppColors.success, size: 13),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(e.value,
                                        style: AppTypography.bodySmall.copyWith(
                                            color:
                                                AppColors.textSecondaryDark)),
                                  ],
                                ),
                              )
                                  .animate(
                                      delay: Duration(
                                          milliseconds: 300 + e.key * 60))
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: 0.05, end: 0),
                            ),
                      ],
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              ),
            ],

            // ── Empty state ──
            if (_forecast == null && _error == null && !_loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⛅', style: TextStyle(fontSize: 72))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                            duration: 2000.ms,
                          ),
                      const SizedBox(height: 16),
                      Text('Check the Weather',
                          style: AppTypography.titleMedium
                              .copyWith(color: AppColors.textSecondaryDark)),
                      const SizedBox(height: 6),
                      Text('Enter a city or tap a quick shortcut above',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMutedDark)),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String _emojiForCondition(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('thunder')) return '⛈️';
    if (d.contains('rain') || d.contains('drizzle')) return '🌧️';
    if (d.contains('snow')) return '❄️';
    if (d.contains('cloud')) return '☁️';
    if (d.contains('fog') || d.contains('mist')) return '🌫️';
    return '☀️';
  }

  LinearGradient _gradientForCondition(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('thunder')) {
      return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4A235A)]);
    }
    if (d.contains('rain') || d.contains('drizzle')) {
      return const LinearGradient(
          colors: [Color(0xFF2E4482), Color(0xFF1A2B5A)]);
    }
    if (d.contains('cloud')) {
      return const LinearGradient(
          colors: [Color(0xFF4A5568), Color(0xFF2D3748)]);
    }
    if (d.contains('snow')) {
      return const LinearGradient(
          colors: [Color(0xFF4299E1), Color(0xFF2B6CB0)]);
    }
    // Sunny
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE17055), Color(0xFFF39C12)],
    );
  }

  List<String> _packingSuggestions(WeatherForecast f) {
    final temp = f.temp;
    final suggestions = <String>[
      'Passport & travel documents',
      'Travel insurance'
    ];
    if (temp > 28) {
      suggestions.addAll([
        'Sunscreen SPF 50+',
        'Sunglasses & hat',
        'Light breathable clothing',
        'Flip flops or sandals',
      ]);
    } else if (temp > 18) {
      suggestions.addAll([
        'Light jacket for evenings',
        'Comfortable walking shoes',
        'Layered clothing',
      ]);
    } else if (temp > 8) {
      suggestions.addAll([
        'Medium weight jacket',
        'Warm layers',
        'Comfortable boots',
      ]);
    } else {
      suggestions.addAll([
        'Heavy winter coat',
        'Thermal layers',
        'Gloves, scarf & beanie',
        'Waterproof boots',
      ]);
    }
    if (f.humidity > 70) suggestions.add('Umbrella or rain jacket');
    if (f.windSpeed > 8) suggestions.add('Windproof outer layer');
    return suggestions;
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.titleSmall
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        Text(label,
            style: AppTypography.caption.copyWith(color: Colors.white54)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.15),
      );
}
