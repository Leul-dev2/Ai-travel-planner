// ─── Trip Repository Interface ──────────────────────────────────────
// Abstract contract for trip operations.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/trip_entity.dart';

abstract class TripRepository {
  /// Get all trips for the current user.
  Future<Either<Failure, List<TripEntity>>> getMyTrips();

  /// Get a specific trip by ID.
  Future<Either<Failure, TripEntity>> getTripById(String tripId);

  /// Create a new trip.
  Future<Either<Failure, TripEntity>> createTrip(TripEntity trip);

  /// Update an existing trip.
  Future<Either<Failure, TripEntity>> updateTrip(TripEntity trip);

  /// Delete a trip.
  Future<Either<Failure, void>> deleteTrip(String tripId);

  /// Generate an AI itinerary for a trip.
  Future<Either<Failure, List<ItineraryDayEntity>>> generateItinerary(
      TripFormData formData);

  /// Save itinerary days to a trip.
  Future<Either<Failure, void>> saveItinerary(
    String tripId,
    List<ItineraryDayEntity> days,
  );

  /// Share a trip via link.
  Future<Either<Failure, String>> shareTrip(String tripId);

  /// Duplicate a trip.
  Future<Either<Failure, TripEntity>> duplicateTrip(String tripId);

  /// Watch trips in real-time.
  Stream<List<TripEntity>> watchMyTrips();
}
