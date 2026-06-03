// ─── Discover Screen ─────────────────────────────────────────────────
// Destination discovery with categories, search, and infinite scroll grid.

import 'package:flutter/material.dart';
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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discover',
                      style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w800))
                      .animate().fadeIn(duration: 400.ms),
                  Text('Find your next adventure',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedDark))
                      .animate(delay: 100.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAltDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
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
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

            // ── Category Chips ──
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
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
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: AppTheme.durationMedium,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceAltDark,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderDark,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Grid ──
            Expanded(
              child: filtered.isEmpty
                  ? Center(
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
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final d = filtered[i];
                        return DestinationCard(
                          name: d.name,
                          country: d.country,
                          imageUrl: d.imageUrl,
                          rating: d.rating,
                          priceRange: d.priceRange,
                          tag: d.tag,
                          tagColor: d.tagColor,
                          height: double.infinity,
                        )
                            .animate(delay: Duration(milliseconds: i * 60))
                            .fadeIn(duration: 350.ms)
                            .scale(begin: const Offset(0.95, 0.95));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
