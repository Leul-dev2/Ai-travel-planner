import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../trip_planner/presentation/providers/trip_provider.dart';
import '../../data/places_service.dart';
import '../providers/map_provider.dart';

const LatLng kDefaultMapCenter = LatLng(37.7749, -122.4194);

LatLng normalizeMapCenter(LatLng? center) => center ?? kDefaultMapCenter;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;
  final PlacesService _placesService = PlacesService();
  final TextEditingController _searchController = TextEditingController();

  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _showSearchResults = false;

  // Quick-access popular spots
  static const _quickPins = [
    _QuickPin(name: 'Tokyo', lat: 35.6762, lng: 139.6503, emoji: '🗼'),
    _QuickPin(name: 'Paris', lat: 48.8566, lng: 2.3522, emoji: '🗼'),
    _QuickPin(name: 'Dubai', lat: 25.2048, lng: 55.2708, emoji: '🏙️'),
    _QuickPin(name: 'NYC', lat: 40.7128, lng: -74.006, emoji: '🗽'),
    _QuickPin(name: 'Bali', lat: -8.3405, lng: 115.092, emoji: '🏝️'),
    _QuickPin(name: 'Santorini', lat: 36.3932, lng: 25.4615, emoji: '🏛️'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _safelyFetchInitialPosition());
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _safelyFetchInitialPosition() async {
    try {
      await ref.read(mapNotifierProvider.notifier).determinePosition();
      
      if (!mounted) return;
      final currentState = ref.read(mapNotifierProvider);
      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(normalizeMapCenter(currentState.center), 14.0),
        );
      }
    } catch (e) {
      debugPrint('Silently handled geolocator initialization mismatch on Web: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSearchResults = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      try {
        final results = await _placesService.getAutocomplete(query);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _isSearching = false;
          _showSearchResults = true;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _onSuggestionSelected(PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    _searchController.text = suggestion.mainText;
    setState(() {
      _suggestions = [];
      _showSearchResults = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: AppLoader(label: 'Fetching details...')),
    );

    try {
      final details = await _placesService.getPlaceDetails(suggestion.placeId);
      if (!mounted) return;
      Navigator.pop(context);
      final latLng = LatLng(details.lat, details.lng);
      ref.read(mapNotifierProvider.notifier).addMarker(Marker(
            markerId: MarkerId(details.placeId),
            position: latLng,
            infoWindow: InfoWindow(
                title: details.name, snippet: details.formattedAddress),
          ));
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15.0));
      _showPlaceDetailsSheet(details);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load place: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPlaceDetailsSheet(PlaceDetails details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.75,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textMutedDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (details.photos != null && details.photos!.isNotEmpty)
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXXL),
                        child: Image.network(
                          details.photos!.first,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      details.name,
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textMutedDark),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            details.formattedAddress,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textMutedDark),
                          ),
                        ),
                      ],
                    ),
                    if (details.rating != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                                i < details.rating!.round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Colors.amber,
                                size: 18,
                              )),
                          const SizedBox(width: 6),
                          Text(
                            details.rating!.toStringAsFixed(1),
                            style: AppTypography.labelLarge
                                .copyWith(color: AppColors.textPrimaryDark),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Add to Trip',
                      icon: Icons.add_location_alt_rounded,
                      onTap: () {
                        // Extract basic location info from formattedAddress (e.g., "Kyoto, Japan")
                        final parts = details.formattedAddress.split(',');
                        final String country = parts.last.trim();
                        String city = details.name;
                        
                        if (parts.length > 1 && parts[parts.length - 2].trim().isNotEmpty) {
                           // If address has multiple parts, use the second to last as city (heuristic)
                           // But keep details.name if it's more specific, or just use details.name directly.
                           // Actually, details.name is usually the best for City if it's a city search.
                           if (city.toLowerCase().contains('point of interest')) {
                             city = parts[parts.length - 2].trim();
                           }
                        }
                        
                        ref.read(tripFormProvider.notifier).setCity(city);
                        ref.read(tripFormProvider.notifier).setCountry(country);

                        // Jump straight to the planner wizard
                        context.go(RouteNames.planTrip);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '📍 $city, $country added to your trip!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _flyTo(double lat, double lng) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapCenter = normalizeMapCenter(mapState.center);

    ref.listen<MapState>(mapNotifierProvider, (previous, next) {
      if (_controller == null) return;
      final prev = normalizeMapCenter(previous?.center);
      final nextCenter = normalizeMapCenter(next.center);
      if (prev != nextCenter) {
        _controller!
            .animateCamera(CameraUpdate.newLatLngZoom(nextCenter, 14.0));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Google Map ──
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition:
                CameraPosition(target: mapCenter, zoom: 14.0),
            markers: mapState.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: _darkMapStyle,
          ),

          // ── Loading overlay ──
          if (mapState.isLoading)
            const Center(child: AppLoader(label: 'Finding your location...')),

          // ── FAB: My location ──
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: AppColors.surfaceDark,
              elevation: 8,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref
                      .read(mapNotifierProvider.notifier)
                      .determinePosition();
                  
                  if (!mounted) return;
                  final s = ref.read(mapNotifierProvider);
                  _controller?.animateCamera(CameraUpdate.newLatLngZoom(
                      normalizeMapCenter(s.center), 15.0));
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Location features temporarily unavailable on web browser: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location_rounded,
                  color: AppColors.primary),
            ),
          ),

          // ── Top overlay: back + search ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _MapIconBtn(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textPrimaryDark),
                            decoration: InputDecoration(
                              hintText: 'Search places, cities...',
                              hintStyle: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textMutedDark),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: AppColors.textMutedDark, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded,
                                          color: AppColors.textMutedDark,
                                          size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _suggestions = [];
                                          _showSearchResults = false;
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Autocomplete dropdown
                  if (_showSearchResults &&
                      (_suggestions.isNotEmpty || _isSearching))
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 58),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXXL),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 12)),
                        ],
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: AppLoader()))
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _suggestions.length,
                              separatorBuilder: (_, __) => Divider(
                                  color:
                                      Colors.white.withValues(alpha: 0.05),
                                  height: 1),
                              itemBuilder: (_, i) {
                                final s = _suggestions[i];
                                return Container(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.location_on,
                                          color: AppColors.primary, size: 16),
                                    ),
                                    title: Text(s.mainText,
                                        style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.textPrimaryDark)),
                                    subtitle: Text(s.secondaryText,
                                        style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.textSecondaryDark)),
                                    onTap: () => _onSuggestionSelected(s),
                                  ),
                                );
                              },
                            ),
                    )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: -0.05, end: 0),

                  // Quick-jump chips
                  if (!_showSearchResults) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickPins.map((p) {
                          return GestureDetector(
                            onTap: () => _flyTo(p.lat, p.lng),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDark.withValues(alpha: 0.9),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                                border:
                                    Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Text(
                                '${p.emoji} ${p.name}',
                                style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.textPrimaryDark),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimaryDark, size: 20),
      ),
    );
  }
}

class _QuickPin {
  final String name;
  final double lat;
  final double lng;
  final String emoji;
  const _QuickPin(
      {required this.name,
      required this.lat,
      required this.lng,
      required this.emoji});
}

const _darkMapStyle = '''
[
  { "elementType": "geometry", "stylers": [ { "color": "#1a1f2e" } ] },
  { "elementType": "labels.text.fill", "stylers": [ { "color": "#8b8fa8" } ] },
  { "elementType": "labels.text.stroke", "stylers": [ { "color": "#1a1f2e" } ] },
  { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#9b8fa8" } ] },
  { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#8b8fa8" } ] },
  { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#1e2d26" } ] },
  { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#6b9a76" } ] },
  { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#2a3042" } ] },
  { "featureType": "road", "elementType": "geometry.stroke", "stylers": [ { "color": "#1a1f2e" } ] },
  { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#6b7280" } ] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3d4b6e" } ] },
  { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#1a1f2e" } ] },
  { "featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [ { "color": "#a78bfa" } ] },
  { "featureType": "transit", "elementType": "geometry", "stylers": [ { "color": "#2a3042" } ] },
  { "featureType": "transit.station", "elementType": "labels.text.fill", "stylers": [ { "color": "#8b8fa8" } ] },
  { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#0d1b2a" } ] },
  { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d5a7a" } ] }
]
''';