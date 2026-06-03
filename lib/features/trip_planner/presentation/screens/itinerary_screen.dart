// ─── Itinerary Screen ────────────────────────────────────────────────
// Premium timeline-style itinerary with day cards, activity rows, images.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/trip_entity.dart';

class ItineraryScreen extends StatefulWidget {
  final String tripId;
  final TripEntity? trip;

  const ItineraryScreen({super.key, required this.tripId, this.trip});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _expandedDay = 0;

  static const _categoryIcons = {
    'hotel': Icons.hotel_rounded,
    'restaurant': Icons.restaurant_rounded,
    'attraction': Icons.photo_camera_rounded,
    'transport': Icons.directions_car_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'nature': Icons.park_rounded,
    'activity': Icons.sports_rounded,
    'museum': Icons.museum_rounded,
  };

  static const _categoryColors = {
    'hotel': AppColors.categoryHotel,
    'restaurant': AppColors.categoryFood,
    'attraction': AppColors.primary,
    'transport': AppColors.categoryTransport,
    'shopping': AppColors.secondary,
    'nature': AppColors.catNature,
    'activity': AppColors.catAdventure,
    'museum': AppColors.catCulture,
  };

  @override
  Widget build(BuildContext context) {
    if (widget.trip == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: AppLoader(label: 'Loading itinerary...')),
      );
    }

    final trip = widget.trip!;
    final totalActivities =
        trip.itinerary.fold<int>(0, (sum, d) => sum + d.activities.length);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero SliverAppBar ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.bgDark,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Trip saved to My Trips!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  decoration: BoxDecoration(
                    gradient: AppColors.auroraGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_add_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('Save',
                          style: AppTypography.labelMedium
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1a1040), Color(0xFF0d1b2a)],
                      ),
                    ),
                  ),
                  // Glow orb
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                                border: Border.all(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${trip.duration} DAYS',
                                style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                '$totalActivities ACTIVITIES',
                                style: AppTypography.labelSmall
                                    .copyWith(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trip.destination.city.toUpperCase(),
                          style: AppTypography.displaySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${trip.destination.country} • ${trip.budget.category}',
                          style: AppTypography.bodyMedium
                              .copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Timeline ──
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final day = trip.itinerary[index];
                final isExpanded = _expandedDay == index;
                return _DayCard(
                  day: day,
                  isExpanded: isExpanded,
                  isLast: index == trip.itinerary.length - 1,
                  categoryIcons: _categoryIcons,
                  categoryColors: _categoryColors,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() =>
                        _expandedDay = isExpanded ? -1 : index);
                  },
                )
                    .animate(delay: Duration(milliseconds: 100 + index * 80))
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.06, end: 0);
              },
              childCount: trip.itinerary.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final ItineraryDayEntity day;
  final bool isExpanded;
  final bool isLast;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final VoidCallback onTap;

  const _DayCard({
    required this.day,
    required this.isExpanded,
    required this.isLast,
    required this.categoryIcons,
    required this.categoryColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              // Day number badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isExpanded
                      ? AppColors.auroraGradient
                      : const LinearGradient(colors: [
                          AppColors.surfaceElevatedDark,
                          AppColors.surfaceElevatedDark,
                        ]),
                  shape: BoxShape.circle,
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${day.dayNumber}',
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // Line
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 2,
                  height: isExpanded
                      ? 20 + (day.activities.length * 76.0)
                      : 32,
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.borderDark,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Day card
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                  border: Border.all(
                    color: isExpanded
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.glassBorder,
                    width: isExpanded ? 1.5 : 1,
                  ),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Day ${day.dayNumber}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  day.title,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.textPrimaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  '${day.activities.length} acts',
                                  style: AppTypography.labelSmall
                                      .copyWith(color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMutedDark,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Activities (collapsible)
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          const Divider(
                              color: AppColors.glassBorder, height: 1),
                          ...day.activities.asMap().entries.map((e) {
                            final i = e.key;
                            final activity = e.value;
                            final cat =
                                activity.category.toLowerCase();
                            final icon = categoryIcons[cat] ??
                                Icons.place_rounded;
                            final color = categoryColors[cat] ??
                                AppColors.primary;
                            return _ActivityRow(
                              activity: activity,
                              icon: icon,
                              color: color,
                              isLast: i == day.activities.length - 1,
                            );
                          }),
                        ],
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
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

class _ActivityRow extends StatelessWidget {
  final ActivityEntity activity;
  final IconData icon;
  final Color color;
  final bool isLast;

  const _ActivityRow({
    required this.activity,
    required this.icon,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(
                    color: AppColors.glassBorder.withValues(alpha: 0.5)))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 48,
            child: Text(
              activity.time ?? '--:--',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMutedDark,
                fontSize: 11,
              ),
            ),
          ),
          // Icon
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (activity.description != null &&
                    activity.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (activity.durationMinutes != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: AppColors.textMutedDark),
                      const SizedBox(width: 3),
                      Text(
                        '${activity.durationMinutes} min',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMutedDark,
                          fontSize: 10,
                        ),
                      ),
                      if (activity.estimatedCost != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.attach_money_rounded,
                            size: 11, color: AppColors.success),
                        Text(
                          activity.estimatedCost!.toStringAsFixed(0),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
