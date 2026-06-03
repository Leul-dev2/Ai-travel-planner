// ─── Skeleton Card Loaders ───────────────────────────────────────────
// Content-matched skeleton screens for smooth perceived performance.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../loaders/shimmer_loading.dart';

/// Skeleton for a destination card (tall image card).
class DestinationCardSkeleton extends StatelessWidget {
  final double height;
  final double? width;

  const DestinationCardSkeleton({super.key, this.height = 200, this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
      child: ShimmerLoading(height: height, width: width ?? double.infinity),
    );
  }
}

/// Skeleton for a trip card (horizontal layout).
class TripCardSkeleton extends StatelessWidget {
  const TripCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
      ),
      child: const Row(
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(AppTheme.radiusXXL),
            ),
            child: ShimmerLoading(width: 100, height: double.infinity),
          ),
          // Text placeholders
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerLoading(height: 16, width: 140),
                  ShimmerLoading(height: 12, width: 80),
                  ShimmerLoading(height: 12, width: 120),
                  ShimmerLoading(height: 6, width: double.infinity,
                      radius: AppTheme.radiusFull),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the home hero section.
class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
      child: const ShimmerLoading(height: 240, width: double.infinity),
    );
  }
}

/// Skeleton for a section with title + horizontal list.
class SectionSkeleton extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;
  final int itemCount;

  const SectionSkeleton({
    super.key,
    this.cardWidth = 160,
    this.cardHeight = 180,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title placeholder
        const ShimmerLoading(height: 16, width: 120),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
              child: ShimmerLoading(
                  height: cardHeight, width: cardWidth),
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton for a chat message bubble.
class ChatBubbleSkeleton extends StatelessWidget {
  final bool isUser;
  const ChatBubbleSkeleton({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(height: 12, width: double.infinity),
            SizedBox(height: 6),
            ShimmerLoading(height: 12, width: 180),
            SizedBox(height: 6),
            ShimmerLoading(height: 12, width: 120),
          ],
        ),
      ),
    );
  }
}

/// Generic list item skeleton (icon + two lines of text).
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ShimmerLoading(width: 48, height: 48, radius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(height: 14),
                SizedBox(height: 6),
                ShimmerLoading(height: 12, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-page skeleton combining multiple sections.
class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Header row
          Row(
            children: [
              ShimmerLoading(width: 40, height: 40, radius: 20),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(height: 10, width: 80),
                  SizedBox(height: 4),
                  ShimmerLoading(height: 14, width: 120),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          // Search bar
          ShimmerLoading(height: 52, radius: AppTheme.radiusFull),
          SizedBox(height: 24),
          // Hero
          HeroSkeleton(),
          SizedBox(height: 28),
          // Trending section
          SectionSkeleton(cardWidth: 150, cardHeight: 180, itemCount: 4),
          SizedBox(height: 28),
          // Trips section
          ShimmerLoading(height: 16, width: 120),
          SizedBox(height: 12),
          TripCardSkeleton(),
          SizedBox(height: 12),
          TripCardSkeleton(),
        ],
      ),
    );
  }
}
