// ─── Booking Entity ─────────────────────────────────────────────────
// Domain entities for hotel, flight, and activity bookings.

import 'package:equatable/equatable.dart';

enum BookingType { hotel, flight, activity }
enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String tripId;
  final BookingType type;
  final String provider; // booking.com, expedia, amadeus
  final String? externalId;
  final BookingStatus status;
  final BookingDetails details;
  final PriceEntity price;
  final String? paymentId;
  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.type,
    required this.provider,
    this.externalId,
    this.status = BookingStatus.pending,
    required this.details,
    required this.price,
    this.paymentId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, type, status];
}

class BookingDetails extends Equatable {
  final String name;
  final String? description;
  final String? imageUrl;
  final String? address;
  final double? lat;
  final double? lng;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? confirmationCode;
  final Map<String, dynamic>? extras;

  const BookingDetails({
    required this.name,
    this.description,
    this.imageUrl,
    this.address,
    this.lat,
    this.lng,
    this.checkIn,
    this.checkOut,
    this.confirmationCode,
    this.extras,
  });

  @override
  List<Object?> get props => [name, address, confirmationCode];
}

class PriceEntity extends Equatable {
  final double amount;
  final String currency;

  const PriceEntity({
    required this.amount,
    this.currency = 'USD',
  });

  @override
  List<Object?> get props => [amount, currency];
}
