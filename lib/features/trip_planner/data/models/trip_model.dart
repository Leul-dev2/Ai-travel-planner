// ─── Trip Model (Data Layer) ────────────────────────────────────────
// Firestore-compatible data model that maps to/from TripEntity.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip_entity.dart';

class TripModel {
  final String id;
  final String ownerId;
  final String title;
  final Map<String, dynamic> destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int duration;
  final String tripType;
  final List<String> interests;
  final Map<String, dynamic> budget;
  final String status;
  final List<String> collaborators;
  final String? shareLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.duration,
    required this.tripType,
    this.interests = const [],
    required this.budget,
    this.status = 'draft',
    this.collaborators = const [],
    this.shareLink,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document.
  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TripModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      destination:
          Map<String, dynamic>.from(data['destination'] as Map? ?? {}),
      departureDate:
          (data['departureDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDate:
          (data['returnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: data['duration'] as int? ?? 0,
      tripType: data['tripType'] as String? ?? 'solo',
      interests: List<String>.from(data['interests'] as List? ?? []),
      budget: Map<String, dynamic>.from(data['budget'] as Map? ?? {}),
      status: data['status'] as String? ?? 'draft',
      collaborators:
          List<String>.from(data['collaborators'] as List? ?? []),
      shareLink: data['shareLink'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Serialize to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'destination': destination,
      'departureDate': Timestamp.fromDate(departureDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'duration': duration,
      'tripType': tripType,
      'interests': interests,
      'budget': budget,
      'status': status,
      'collaborators': collaborators,
      'shareLink': shareLink,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Convert to domain entity (without itinerary — loaded separately).
  TripEntity toEntity({List<ItineraryDayEntity> itinerary = const []}) {
    return TripEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      destination: DestinationEntity(
        country: destination['country'] as String? ?? '',
        city: destination['city'] as String? ?? '',
        lat: (destination['lat'] as num?)?.toDouble(),
        lng: (destination['lng'] as num?)?.toDouble(),
      ),
      departureDate: departureDate,
      returnDate: returnDate,
      duration: duration,
      tripType: tripType,
      interests: interests,
      budget: BudgetEntity(
        amount: (budget['amount'] as num?)?.toDouble() ?? 0,
        currency: budget['currency'] as String? ?? 'USD',
        category: budget['category'] as String? ?? 'economy',
      ),
      status: _parseStatus(status),
      collaborators: collaborators,
      shareLink: shareLink,
      itinerary: itinerary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from domain entity.
  factory TripModel.fromEntity(TripEntity entity) {
    return TripModel(
      id: entity.id,
      ownerId: entity.ownerId,
      title: entity.title,
      destination: {
        'country': entity.destination.country,
        'city': entity.destination.city,
        'lat': entity.destination.lat,
        'lng': entity.destination.lng,
      },
      departureDate: entity.departureDate,
      returnDate: entity.returnDate,
      duration: entity.duration,
      tripType: entity.tripType,
      interests: entity.interests,
      budget: {
        'amount': entity.budget.amount,
        'currency': entity.budget.currency,
        'category': entity.budget.category,
      },
      status: entity.status.name,
      collaborators: entity.collaborators,
      shareLink: entity.shareLink,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static TripStatus _parseStatus(String status) {
    switch (status) {
      case 'draft':
        return TripStatus.draft;
      case 'planned':
        return TripStatus.planned;
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.draft;
    }
  }
}

// ── Itinerary Day Model ──
class ItineraryDayModel {
  final int dayNumber;
  final String title;
  final String? imageUrl;
  final List<Map<String, dynamic>> activities;
  final Map<String, dynamic>? weather;

  const ItineraryDayModel({
    required this.dayNumber,
    required this.title,
    this.imageUrl,
    this.activities = const [],
    this.weather,
  });

  factory ItineraryDayModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ItineraryDayModel(
      dayNumber: data['dayNumber'] as int? ?? 0,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      activities: List<Map<String, dynamic>>.from(
        (data['activities'] as List?)?.map((a) =>
            Map<String, dynamic>.from(a as Map)) ??
            [],
      ),
      weather: data['weather'] != null
          ? Map<String, dynamic>.from(data['weather'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'imageUrl': imageUrl,
      'activities': activities,
      'weather': weather,
    };
  }

  ItineraryDayEntity toEntity() {
    return ItineraryDayEntity(
      dayNumber: dayNumber,
      title: title,
      imageUrl: imageUrl,
      activities: activities.map((a) => ActivityEntity(
        name: a['name'] as String? ?? '',
        description: a['description'] as String?,
        time: a['time'] as String?,
        durationMinutes: a['duration'] as int?,
        lat: (a['lat'] as num?)?.toDouble(),
        lng: (a['lng'] as num?)?.toDouble(),
        category: a['category'] as String? ?? 'attraction',
        estimatedCost: (a['estimatedCost'] as num?)?.toDouble(),
        notes: a['notes'] as String?,
        imageUrl: a['imageUrl'] as String?,
      )).toList(),
      weather: weather != null
          ? WeatherEntity(
              temp: (weather!['temp'] as num?)?.toDouble() ?? 0,
              condition: weather!['condition'] as String? ?? '',
              icon: weather!['icon'] as String? ?? '',
            )
          : null,
    );
  }
}
