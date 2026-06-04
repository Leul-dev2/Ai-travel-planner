// ─── Discover Screen ─────────────────────────────────────────────────
// Premium destination discovery with masonry grid, hero carousels, and glassmorphism.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/destination_card.dart';

class DestinationData {
  final String name;
  final String country;
  final String imageUrl;
  final double rating;
  final String priceRange;
  final String tag;
  final Color tagColor;
  final String category;

  const DestinationData({
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.rating,
    required this.priceRange,
    required this.tag,
    required this.tagColor,
    required this.category,
  });
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  static const _categories = [
    'All', 'Beach', 'Mountain', 'City', 'Culture', 'Adventure', 'Nature', 'Food'
  ];

  static final _allDestinations = [
    const DestinationData(
      name: 'Santorini', country: 'Greece',
      imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=600',
      rating: 4.9, priceRange: '\$\$\$', tag: 'Trending', tagColor: AppColors.accent, category: 'City',
    ),
    const DestinationData(
      name: 'Bali', country: 'Indonesia',
      imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600',
      rating: 4.8, priceRange: '\$\$', tag: 'Popular', tagColor: AppColors.warning, category: 'Beach',
    ),
    const DestinationData(
      name: 'Kyoto', country: 'Japan',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600',
      rating: 4.9, priceRange: '\$\$\$', tag: 'Culture', tagColor: AppColors.catCulture, category: 'Culture',
    ),
    const DestinationData(
      name: 'Maldives', country: 'Indian Ocean',
      imageUrl: 'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=600',
      rating: 5.0, priceRange: '\$\$\$\$', tag: 'Luxury', tagColor: AppColors.secondary, category: 'Beach',
    ),
    const DestinationData(
      name: 'Patagonia', country: 'Argentina',
      imageUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=600',
      rating: 4.8, priceRange: '\$\$', tag: 'Wild', tagColor: AppColors.catNature, category: 'Adventure',
    ),
    const DestinationData(
      name: 'Tokyo', country: 'Japan',
      imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600',
      rating: 4.9, priceRange: '\$\$\$', tag: 'Vibrant', tagColor: AppColors.primary, category: 'City',
    ),
    const DestinationData(
      name: 'Amalfi Coast', country: 'Italy',
      imageUrl: 'https://images.unsplash.com/photo-1534308143481-c55f00be8bd7?w=600',
      rating: 4.9, priceRange: '\$\$\$', tag: 'Scenic', tagColor: AppColors.catCity, category: 'City',
    ),
    const DestinationData(
      name: 'Banff', country: 'Canada',
      imageUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=600',
      rating: 4.8, priceRange: '\$\$', tag: 'Nature', tagColor: AppColors.catNature, category: 'Mountain',
    ),
    const DestinationData(
      name: 'Marrakech', country: 'Morocco',
      imageUrl: 'https://images.unsplash.com/photo-1539020140153-e479b8bbe32d?w=600',
      rating: 4.7, priceRange: '\$\$', tag: 'Exotic', tagColor: AppColors.catFood, category: 'Culture',
    ),
    const DestinationData(
      name: 'Queenstown', country: 'New Zealand',
      imageUrl: 'https://images.unsplash.com/photo-1469521669194-babb45599def?w=600',
      rating: 4.9, priceRange: '\$\$\$', tag: 'Thrills', tagColor: AppColors.catAdventure, category: 'Adventure',
    ),
    const DestinationData(
      name: 'Barcelona', country: 'Spain',
      imageUrl: 'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=600',
      rating: 4.8, priceRange: '\$\$\$', tag: 'Art', tagColor: AppColors.catCulture, category: 'City',
    ),
    const DestinationData(
      name: 'Phi Phi Islands', country: 'Thailand',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=600',
      rating: 4.7, priceRange: '\$', tag: 'Paradise', tagColor: AppColors.catBeach, category: 'Beach',
    ),
  ];

  List<DestinationData> get _filtered {
    return _allDestinations.where((d) {
      final matchesCat = _selectedCategory == 'All' ||
          d.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.country.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final trending = _allDestinations.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Main Content ──
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70), // Space for glass app bar
                      
                      // Hero title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Where to\nnext?',
                            style: AppTypography.displayMedium.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w900,
                                height: 1.1))
                            .animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                      ),
                      
                      const SizedBox(height: 24),

                      // Horizontal Trending Carousel
                      if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Trending Now',
                                  style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.textPrimaryDark,
                                      fontWeight: FontWeight.w800)),
                              Text('See all',
                                  style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ).animate(delay: 100.ms).fadeIn(),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: trending.length,
                            itemBuilder: (context, index) {
                              final d = trending[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: DestinationCard(
                                  name: d.name,
                                  country: d.country,
                                  imageUrl: d.imageUrl,
                                  rating: d.rating,
                                  priceRange: d.priceRange,
                                  tag: d.tag,
                                  tagColor: d.tagColor,
                                  width: 200,
                                  height: 280,
                                ),
                              ).animate(delay: Duration(milliseconds: 150 + index * 100)).fadeIn().slideX(begin: 0.1);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),

                // ── Sticky Category Header ──
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryHeaderDelegate(
                    child: Container(
                      color: AppColors.bgDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                             Padding(
                               padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                               child: Text('Explore',
                                  style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.textPrimaryDark,
                                      fontWeight: FontWeight.w800)),
                             ),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _categories.length,
                              itemBuilder: (_, i) {
                                final cat = _categories[i];
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedCategory = cat);
                                    },
                                    child: AnimatedContainer(
                                      duration: AppTheme.durationMedium,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? AppColors.auroraGradient
                                            : null,
                                        color: isSelected
                                            ? null
                                            : AppColors.surfaceAltDark,
                                        borderRadius:
                                            BorderRadius.circular(AppTheme.radiusFull),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : AppColors.borderDark,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        cat,
                                        style: AppTypography.labelMedium.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textSecondaryDark,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    height: (_searchQuery.isNotEmpty || _selectedCategory != 'All') ? 80 : 64,
                  ),
                ),

                // ── Masonry Grid ──
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 64, color: AppColors.textMutedDark),
                          const SizedBox(height: 12),
                          Text('No destinations found',
                              style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textSecondaryDark)),
                        ],
                      ),
                    ).animate().fadeIn(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // padding for bottom nav
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: _buildMasonryColumn(filtered, 0),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: _buildMasonryColumn(filtered, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── Floating Glass App Bar / Search ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isScrolled
                          ? AppColors.surfaceDark.withValues(alpha: 0.8)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: _isScrolled
                              ? AppColors.borderDark.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAltDark.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search_rounded,
                              color: AppColors.textMutedDark, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimaryDark),
                              decoration: InputDecoration(
                                hintText: 'Search destinations...',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textMutedDark),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _searchQuery = v),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.close_rounded,
                                    color: AppColors.textMutedDark, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMasonryColumn(List<DestinationData> items, int columnIndex) {
    final List<Widget> columnItems = [];
    for (int i = 0; i < items.length; i++) {
      if (i % 2 == columnIndex) {
        // Create an alternating height effect for masonry
        final double height = (i % 3 == 0) ? 280 : 220;
        final d = items[i];
        
        columnItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DestinationCard(
              name: d.name,
              country: d.country,
              imageUrl: d.imageUrl,
              rating: d.rating,
              priceRange: d.priceRange,
              tag: d.tag,
              tagColor: d.tagColor,
              height: height,
            ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().scale(begin: const Offset(0.95, 0.95)),
          ),
        );
      }
    }
    // Add top padding to the second column to create the masonry staggered look
    if (columnIndex == 1 && columnItems.isNotEmpty) {
      columnItems.insert(0, const SizedBox(height: 32));
    }
    return columnItems;
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _CategoryHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
