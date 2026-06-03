import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';

part 'map_provider.g.dart';

/// Immutable State for the Map UI
class MapState {
  final LatLng center;
  final Set<Marker> markers;
  final bool isLoading;
  final String? errorMessage;

  MapState({
    required this.center,
    this.markers = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  MapState copyWith({
    LatLng? center,
    Set<Marker>? markers,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MapState(
      center: center ?? this.center,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier responsible for managing map positioning and location permissions
@riverpod
class MapNotifier extends _$MapNotifier {
  @override
  MapState build() {
    return MapState(center: const LatLng(0, 0));
  }

  Future<void> determinePosition() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Check if hardware device location service is enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const ServerFailure(
            message: 'Location services are disabled on your device.');
      }

      // 2. Evaluate current app permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const ServerFailure(
              message: 'Location permissions were denied.');
        }
      }

      // 3. Handle persistent permanent denials
      if (permission == LocationPermission.deniedForever) {
        throw const ServerFailure(
          message:
              'Location permissions are permanently denied. Please enable them via app settings.',
        );
      }

      // 4. Fetch position (Fallback signature compatible with older Geolocator versions)
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 5. Update state successfully
      state = state.copyWith(
        center: LatLng(position.latitude, position.longitude),
        isLoading: false,
      );
    } on ServerFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected location error occurred: $e',
      );
    }
  }

  /// Appends a new marker to the set without modifying the existing markers
  void addMarker(Marker marker) {
    state = state.copyWith(markers: {...state.markers, marker});
  }

  /// Clears out the current error message manually if required
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
