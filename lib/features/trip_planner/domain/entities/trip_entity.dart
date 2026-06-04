// ─── Trip Entity ────────────────────────────────────────────────────
// Domain entity representing a complete trip with itinerary.

import 'package:equatable/equatable.dart';

// ── Trip Status ──
enum TripStatus { draft, planned, active, completed, cancelled }

// ── Trip Entity ──
class TripEntity extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final DestinationEntity destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int duration;
  final String tripType;
  final List<String> interests;
  final BudgetEntity budget;
  final TripStatus status;
  final List<String> collaborators;
  final String? shareLink;
  final List<ItineraryDayEntity> itinerary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripEntity({
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
    this.status = TripStatus.draft,
    this.collaborators = const [],
    this.shareLink,
    this.itinerary = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, ownerId, title, status];

  TripEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    DestinationEntity? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    int? duration,
    String? tripType,
    List<String>? interests,
    BudgetEntity? budget,
    TripStatus? status,
    List<String>? collaborators,
    String? shareLink,
    List<ItineraryDayEntity>? itinerary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      duration: duration ?? this.duration,
      tripType: tripType ?? this.tripType,
      interests: interests ?? this.interests,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      collaborators: collaborators ?? this.collaborators,
      shareLink: shareLink ?? this.shareLink,
      itinerary: itinerary ?? this.itinerary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ── Destination ──
class DestinationEntity extends Equatable {
  final String country;
  final String city;
  final double? lat;
  final double? lng;

  const DestinationEntity({
    required this.country,
    required this.city,
    this.lat,
    this.lng,
  });

  String get displayName => '$city, $country';

  @override
  List<Object?> get props => [country, city, lat, lng];
}

// ── Budget ──
class BudgetEntity extends Equatable {
  final double amount;
  final String currency;
  final String category;

  const BudgetEntity({
    required this.amount,
    this.currency = 'USD',
    this.category = 'economy',
  });

  @override
  List<Object?> get props => [amount, currency, category];
}

// ── Itinerary Day ──
class ItineraryDayEntity extends Equatable {
  final int dayNumber;
  final String title;
  final String? imageUrl;
  final List<ActivityEntity> activities;
  final WeatherEntity? weather;

  const ItineraryDayEntity({
    required this.dayNumber,
    required this.title,
    this.imageUrl,
    this.activities = const [],
    this.weather,
  });

  @override
  List<Object?> get props => [dayNumber, title];
}

// ── Activity ──
class ActivityEntity extends Equatable {
  final String name;
  final String? description;
  final String? time;
  final int? durationMinutes;
  final double? lat;
  final double? lng;
  final String category; // hotel, restaurant, attraction, transport
  final double? estimatedCost;
  final String? notes;
  final String? imageUrl;

  const ActivityEntity({
    required this.name,
    this.description,
    this.time,
    this.durationMinutes,
    this.lat,
    this.lng,
    this.category = 'attraction',
    this.estimatedCost,
    this.notes,
    this.imageUrl,
  });

  ActivityEntity copyWith({
    String? name,
    String? description,
    String? time,
    int? durationMinutes,
    double? lat,
    double? lng,
    String? category,
    double? estimatedCost,
    String? notes,
    String? imageUrl,
  }) {
    return ActivityEntity(
      name: name ?? this.name,
      description: description ?? this.description,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [name, lat, lng, category];
}

// ── Weather (embedded in day) ──
class WeatherEntity extends Equatable {
  final double temp;
  final String condition;
  final String icon;

  const WeatherEntity({
    required this.temp,
    required this.condition,
    required this.icon,
  });

  @override
  List<Object?> get props => [temp, condition];
}

// ── Trip Form Data (used during wizard) ──
class TripFormData {
  String country;
  String city;
  DateTime? departureDate;
  DateTime? returnDate;
  int duration;
  String tripType;
  List<String> interests;
  double budgetAmount;
  String budgetCurrency;
  String budgetCategory;
  int numberOfTravelers;
  String? transportPreference;

  TripFormData({
    this.country = '',
    this.city = '',
    this.departureDate,
    this.returnDate,
    this.duration = 0,
    this.tripType = 'solo',
    this.interests = const [],
    this.budgetAmount = 500,
    this.budgetCurrency = 'USD',
    this.budgetCategory = 'Economy',
    this.numberOfTravelers = 1,
    this.transportPreference,
  });

  Map<String, dynamic> toJson() => {
        'country': country,
        'city': city,
        'departureDate': departureDate?.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
        'duration': duration,
        'tripType': tripType,
        'interests': interests,
        'budget': budgetAmount.toInt(),
        'currency': budgetCurrency,
        'numberOfTravelers': numberOfTravelers,
        'transportPreference': transportPreference,
      };

  TripFormData copyWith({
    String? country,
    String? city,
    DateTime? departureDate,
    DateTime? returnDate,
    int? duration,
    String? tripType,
    List<String>? interests,
    double? budgetAmount,
    String? budgetCurrency,
    String? budgetCategory,
    int? numberOfTravelers,
    String? transportPreference,
  }) {
    return TripFormData(
      country: country ?? this.country,
      city: city ?? this.city,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      duration: duration ?? this.duration,
      tripType: tripType ?? this.tripType,
      interests: interests ?? this.interests,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      budgetCurrency: budgetCurrency ?? this.budgetCurrency,
      budgetCategory: budgetCategory ?? this.budgetCategory,
      numberOfTravelers: numberOfTravelers ?? this.numberOfTravelers,
      transportPreference: transportPreference ?? this.transportPreference,
    );
  }
}
