// ─── Trip Remote Datasource ─────────────────────────────────────────
// Firestore operations for trips and itineraries.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/trip_model.dart';

abstract class TripRemoteDatasource {
  Future<List<TripModel>> getTripsForUser(String userId);
  Future<TripModel> getTripById(String tripId);
  Future<TripModel> createTrip(TripModel trip);
  Future<TripModel> updateTrip(TripModel trip);
  Future<void> deleteTrip(String tripId);
  Future<void> saveItinerary(String tripId, List<ItineraryDayModel> days);
  Future<List<ItineraryDayModel>> getItinerary(String tripId);
  Future<String> generateShareLink(String tripId);
  Stream<List<TripModel>> watchTripsForUser(String userId);
}

class TripRemoteDatasourceImpl implements TripRemoteDatasource {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  TripRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _tripsCol =>
      _firestore.collection(FirestorePaths.trips);

  @override
  Future<List<TripModel>> getTripsForUser(String userId) async {
    try {
      final query = await _tripsCol
          .where('ownerId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return query.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error('Failed to get trips', e);
      throw ServerException(message: 'Failed to load trips: $e');
    }
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    try {
      final doc = await _tripsCol.doc(tripId).get();
      if (!doc.exists) {
        throw NotFoundException(message: 'Trip not found');
      }
      return TripModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(message: 'Failed to get trip: $e');
    }
  }

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    try {
      final id = _uuid.v4();
      final data = trip.toFirestore();
      await _tripsCol.doc(id).set(data);
      final doc = await _tripsCol.doc(id).get();
      return TripModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Failed to create trip', e);
      throw ServerException(message: 'Failed to create trip: $e');
    }
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    try {
      await _tripsCol.doc(trip.id).update(trip.toFirestore());
      final doc = await _tripsCol.doc(trip.id).get();
      return TripModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update trip: $e');
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      // Delete subcollections first
      final itineraryDocs = await _tripsCol
          .doc(tripId)
          .collection('itinerary')
          .get();
      for (final doc in itineraryDocs.docs) {
        await doc.reference.delete();
      }

      final commentDocs = await _tripsCol
          .doc(tripId)
          .collection('comments')
          .get();
      for (final doc in commentDocs.docs) {
        await doc.reference.delete();
      }

      // Delete the trip document
      await _tripsCol.doc(tripId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete trip: $e');
    }
  }

  @override
  Future<void> saveItinerary(
      String tripId, List<ItineraryDayModel> days) async {
    try {
      final batch = _firestore.batch();
      final itineraryCol = _tripsCol.doc(tripId).collection('itinerary');

      // Clear existing itinerary
      final existing = await itineraryCol.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Write new itinerary days
      for (final day in days) {
        final dayDoc = itineraryCol.doc('day_${day.dayNumber}');
        batch.set(dayDoc, day.toFirestore());
      }

      await batch.commit();
      AppLogger.info('Saved ${days.length} itinerary days for trip $tripId');
    } catch (e) {
      throw ServerException(message: 'Failed to save itinerary: $e');
    }
  }

  @override
  Future<List<ItineraryDayModel>> getItinerary(String tripId) async {
    try {
      final query = await _tripsCol
          .doc(tripId)
          .collection('itinerary')
          .orderBy('dayNumber')
          .get();

      return query.docs
          .map((doc) => ItineraryDayModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to load itinerary: $e');
    }
  }

  @override
  Future<String> generateShareLink(String tripId) async {
    try {
      final shareId = _uuid.v4().substring(0, 8);
      final shareLink = 'https://smarttravel.ai/trip/$shareId';

      await _tripsCol.doc(tripId).update({
        'shareLink': shareLink,
      });

      return shareLink;
    } catch (e) {
      throw ServerException(message: 'Failed to generate share link: $e');
    }
  }

  @override
  Stream<List<TripModel>> watchTripsForUser(String userId) {
    return _tripsCol
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList());
  }
}
