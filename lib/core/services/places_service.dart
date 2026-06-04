import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

class PlacesService {
  final Dio _dio = Dio();

  /// Searches Google Places API for a location and returns a high-quality photo URL and exact coordinates.
  Future<Map<String, dynamic>?> getPlaceDetails(String query) async {
    final apiKey = AppConfig.googleMapsApiKey;
    if (apiKey.isEmpty) {
      AppLogger.warning('Google Maps API Key is missing. Cannot fetch place photos.');
      
      // Fallback if API key is missing
      final queryParam = Uri.encodeComponent(query.split(',').first);
      return {
        'lat': null,
        'lng': null,
        'photoUrl': 'https://loremflickr.com/800/600/$queryParam,travel',
      };
    }

    try {
      // 1. Text Search to find the Place ID
      final searchUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
      final searchRes = await _dio.get(searchUrl, queryParameters: {
        'query': query,
        'key': apiKey,
      });

      if (searchRes.statusCode == 200 && searchRes.data['status'] == 'OK') {
        final results = searchRes.data['results'] as List;
        if (results.isNotEmpty) {
          final place = results.first;
          final geometry = place['geometry']['location'];
          String? photoUrl;

          if (place['photos'] != null && (place['photos'] as List).isNotEmpty) {
            final photoRef = place['photos'][0]['photo_reference'];
            photoUrl =
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=$photoRef&key=$apiKey';
          } else {
            // Fallback image if Google Places has no photo
            final queryParam = Uri.encodeComponent(query.split(',').first);
            photoUrl = 'https://loremflickr.com/800/600/$queryParam,travel';
          }

          return {
            'lat': geometry['lat'],
            'lng': geometry['lng'],
            'photoUrl': photoUrl,
            'name': place['name'],
            'address': place['formatted_address'],
          };
        }
      } else {
         AppLogger.error('Google Places API Error: ${searchRes.data['status']} - ${searchRes.data['error_message']}');
      }
    } catch (e) {
      AppLogger.error('Failed to get place details: $e');
    }
    
    // Fallback if Places API is disabled or fails
    final queryParam = Uri.encodeComponent(query.split(',').first);
    return {
      'lat': null,
      'lng': null,
      'photoUrl': 'https://loremflickr.com/800/600/$queryParam,travel',
    };
  }
}
