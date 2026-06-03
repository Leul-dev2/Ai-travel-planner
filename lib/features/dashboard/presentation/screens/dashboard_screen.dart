// ─── Dashboard Screen ─────────────────────────────────────────────────
// Trip management hub — upcoming, active, past, draft tabs + stats.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animations/animated_counter.dart';
import '../../../../core/widgets/cards/trip_card.dart';
import '../../../../core/widgets/empty_states/empty_state_widget.dart';
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Trips',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push(RouteNames.planTrip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('New Trip',
                        style: AppTypography.labelLarge.copyWith(
                            color: Colors.white)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ── Stats ──
            _buildStats(),

            // ── Tab Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Active'),
                  Tab(text: 'Past'),
                  Tab(text: 'Drafts'),
                ],
                labelStyle: AppTypography.labelLarge,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMutedDark,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.borderDark,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
              ),
            ),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildTripList(TripCardStatus.planned),
                  _buildTripList(TripCardStatus.active),
                  _buildTripList(TripCardStatus.completed),
                  _buildTripList(TripCardStatus.draft),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ('Trips', 12.0, '✈️'),
      ('Countries', 8.0, '🌍'),
      ('Days', 64.0, '📅'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$3, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  AnimatedCounter(
                    value: s.$2,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  Text(
                    s.$1,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ).animate(delay: const Duration(milliseconds: 100))
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripList(TripCardStatus statusFilter) {
    // Sample data
    final sampleTrips = [
      if (statusFilter == TripCardStatus.planned ||
          statusFilter == TripCardStatus.active) ...[
        _SampleTrip(
          destination: 'Bali Escape',
          country: 'Indonesia',
          imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
          start: DateTime.now().add(const Duration(days: 14)),
          end: DateTime.now().add(const Duration(days: 22)),
          duration: 8,
          status: statusFilter,
          budget: 0.42,
        ),
        _SampleTrip(
          destination: 'Tokyo Adventure',
          country: 'Japan',
          imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
          start: DateTime.now().add(const Duration(days: 45)),
          end: DateTime.now().add(const Duration(days: 55)),
          duration: 10,
          status: statusFilter,
          budget: 0.15,
        ),
      ],
      if (statusFilter == TripCardStatus.completed) ...[
        _SampleTrip(
          destination: 'Paris Getaway',
          country: 'France',
          imageUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=400',
          start: DateTime.now().subtract(const Duration(days: 60)),
          end: DateTime.now().subtract(const Duration(days: 55)),
          duration: 5,
          status: TripCardStatus.completed,
          budget: 1.0,
        ),
      ],
    ];

    if (sampleTrips.isEmpty) {
      return EmptyStateWidget(
        type: EmptyStateType.noTrips,
        actionLabel: 'Plan a Trip',
        onAction: () => context.push(RouteNames.planTrip),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: sampleTrips.length,
      itemBuilder: (_, i) {
        final t = sampleTrips[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TripCard(
            destination: t.destination,
            country: t.country,
            imageUrl: t.imageUrl,
            startDate: t.start,
            endDate: t.end,
            durationDays: t.duration,
            status: t.status,
            budgetUsedPercent: t.budget,
            onTap: () {
              context.push(
                RouteNames.itineraryPath('trip_$i'),
              );
            },
          ).animate(delay: Duration(milliseconds: i * 80))
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.1, end: 0),
        );
      },
    );
  }
}

class _SampleTrip {
  final String destination;
  final String country;
  final String? imageUrl;
  final DateTime start;
  final DateTime end;
  final int duration;
  final TripCardStatus status;
  final double? budget;

  _SampleTrip({
    required this.destination,
    required this.country,
    this.imageUrl,
    required this.start,
    required this.end,
    required this.duration,
    required this.status,
    this.budget,
  });
}
