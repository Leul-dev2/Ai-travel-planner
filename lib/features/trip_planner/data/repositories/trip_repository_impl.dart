// ─── Trip Repository Implementation ─────────────────────────────────
// Bridges trip datasource + AI chain to domain layer.

import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../../ai_chat/data/ai_fallback_chain.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDatasource _remoteDatasource;
  final AIFallbackChain _aiFallbackChain;
  final NetworkInfo _networkInfo;
  final String _currentUserId;

  TripRepositoryImpl({
    required TripRemoteDatasource remoteDatasource,
    required AIFallbackChain aiFallbackChain,
    required NetworkInfo networkInfo,
    required String currentUserId,
  })  : _remoteDatasource = remoteDatasource,
        _aiFallbackChain = aiFallbackChain,
        _networkInfo = networkInfo,
        _currentUserId = currentUserId;

  @override
  Future<Either<Failure, List<TripEntity>>> getMyTrips() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await _remoteDatasource.getTripsForUser(_currentUserId);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('getMyTrips failed', e);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String tripId) async {
    try {
      final model = await _remoteDatasource.getTripById(tripId);
      final itinerary = await _remoteDatasource.getItinerary(tripId);
      return Right(
        model.toEntity(itinerary: itinerary.map((d) => d.toEntity()).toList()),
      );
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> createTrip(TripEntity trip) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = TripModel.fromEntity(trip);
      final created = await _remoteDatasource.createTrip(model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> updateTrip(TripEntity trip) async {
    try {
      final model = TripModel.fromEntity(trip);
      final updated = await _remoteDatasource.updateTrip(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    try {
      await _remoteDatasource.deleteTrip(tripId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItineraryDayEntity>>> generateItinerary(
      TripFormData formData) async {
    try {
      // Build the AI prompt
      final prompt = _buildItineraryPrompt(formData);
      final request = AIRequest(
        prompt: prompt,
        context: formData.toJson(),
        maxTokens: 4096,
        temperature: 0.8,
      );

      // Execute through fallback chain
      final response = await _aiFallbackChain.execute(request);

      // Parse the AI response into structured itinerary days
      final days = _parseItineraryResponse(response.content, formData.duration);

      AppLogger.info(
        'Itinerary generated via ${response.provider} '
        '(${response.latency?.inMilliseconds ?? 0}ms, '
        '${response.tokensUsed ?? 0} tokens)',
      );

      return Right(days);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      AppLogger.error('generateItinerary failed', e);
      return const Left(AIExhaustedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveItinerary(
    String tripId,
    List<ItineraryDayEntity> days,
  ) async {
    try {
      final models = days
          .map((d) => ItineraryDayModel(
                dayNumber: d.dayNumber,
                title: d.title,
                imageUrl: d.imageUrl,
                activities: d.activities
                    .map((a) => {
                          'name': a.name,
                          'description': a.description,
                          'time': a.time,
                          'duration': a.durationMinutes,
                          'lat': a.lat,
                          'lng': a.lng,
                          'category': a.category,
                          'estimatedCost': a.estimatedCost,
                          'notes': a.notes,
                        })
                    .toList(),
              ))
          .toList();

      await _remoteDatasource.saveItinerary(tripId, models);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> shareTrip(String tripId) async {
    try {
      final link = await _remoteDatasource.generateShareLink(tripId);
      return Right(link);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> duplicateTrip(String tripId) async {
    try {
      final original = await _remoteDatasource.getTripById(tripId);
      final itinerary = await _remoteDatasource.getItinerary(tripId);

      final copy = TripModel(
        id: '',
        ownerId: _currentUserId,
        title: '${original.title} (Copy)',
        destination: original.destination,
        departureDate: original.departureDate,
        returnDate: original.returnDate,
        duration: original.duration,
        tripType: original.tripType,
        interests: original.interests,
        budget: original.budget,
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _remoteDatasource.createTrip(copy);
      if (itinerary.isNotEmpty) {
        await _remoteDatasource.saveItinerary(created.id, itinerary);
      }

      return Right(created.toEntity(
        itinerary: itinerary.map((d) => d.toEntity()).toList(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to duplicate trip: $e'));
    }
  }

  @override
  Stream<List<TripEntity>> watchMyTrips() {
    return _remoteDatasource
        .watchTripsForUser(_currentUserId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  // ── Private: Build AI Prompt ──

  String _buildItineraryPrompt(TripFormData formData) {
    return '''
You are an expert travel planner. Create a detailed ${formData.duration}-day itinerary for ${formData.city}, ${formData.country}.

Trip Details:
- Trip Type: ${formData.tripType}
- Travelers: ${formData.numberOfTravelers}
- Budget: ${formData.budgetAmount} ${formData.budgetCurrency} (${formData.budgetCategory})
- Interests: ${formData.interests.join(', ')}
- Transport: ${formData.transportPreference ?? 'flexible'}

For each day, provide 4-6 activities with:
- Activity name
- Time slot (e.g., "09:00")
- Estimated duration in minutes
- Category (hotel, restaurant, attraction, transport)
- Estimated cost in ${formData.budgetCurrency}
- Brief description

Format as structured JSON array:
[
  {
    "dayNumber": 1,
    "title": "Day Title",
    "activities": [
      {
        "name": "Activity Name",
        "time": "09:00",
        "duration": 120,
        "category": "attraction",
        "estimatedCost": 25.0,
        "description": "Brief description"
      }
    ]
  }
]

Stay within the total budget of ${formData.budgetAmount} ${formData.budgetCurrency}.
Include local restaurants, cultural experiences, and practical tips.
''';
  }

  // ── Private: Parse AI Response ──

  List<ItineraryDayEntity> _parseItineraryResponse(
      String content, int expectedDays) {
    // Try to parse as JSON first
    try {
      // Find JSON array in the response
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']');
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = content.substring(jsonStart, jsonEnd + 1);
        final List<dynamic> parsed =
            List<dynamic>.from(_parseJson(jsonStr) as List);
        return parsed.map((day) {
          final d = day as Map<String, dynamic>;
          return ItineraryDayEntity(
            dayNumber: d['dayNumber'] as int? ?? 1,
            title: d['title'] as String? ?? 'Day ${d['dayNumber']}',
            activities: (d['activities'] as List?)
                    ?.map((a) => ActivityEntity(
                          name: a['name'] as String? ?? '',
                          description: a['description'] as String?,
                          time: a['time'] as String?,
                          durationMinutes: a['duration'] as int?,
                          category: a['category'] as String? ?? 'attraction',
                          estimatedCost:
                              (a['estimatedCost'] as num?)?.toDouble(),
                        ))
                    .toList() ??
                [],
          );
        }).toList();
      }
    } catch (e) {
      AppLogger.warning('Failed to parse AI response as JSON: $e');
    }

    // Fallback: create basic structure from text
    return List.generate(
      expectedDays,
      (i) => ItineraryDayEntity(
        dayNumber: i + 1,
        title: 'Day ${i + 1}',
        activities: const [
          ActivityEntity(
            name: 'See itinerary details',
            description: 'AI-generated plan — view the full text response.',
            category: 'attraction',
          ),
        ],
      ),
    );
  }

  dynamic _parseJson(String jsonStr) {
    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return [];
    }
  }
}
