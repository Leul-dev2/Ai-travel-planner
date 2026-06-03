import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final double lat;
  final double lng;
  final String formattedAddress;
  final List<String>? photos;
  final double? rating;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.formattedAddress,
    this.photos,
    this.rating,
  });
}

class PlacesService {
  String get _apiKey => AppConfig.googleMapsApiKey;

  Future<List<PlaceSuggestion>> getAutocomplete(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        }
      }
      return [];
    } catch (e) {
      AppLogger.error('Places API Error', e);
      return [];
    }
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          
          List<String> photos = [];
          if (result['photos'] != null) {
            photos = (result['photos'] as List).map((p) {
              return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${p['photo_reference']}&key=$_apiKey';
            }).toList();
          }

          return PlaceDetails(
            placeId: placeId,
            name: result['name'],
            lat: location['lat'],
            lng: location['lng'],
            formattedAddress: result['formatted_address'],
            photos: photos,
            rating: result['rating']?.toDouble(),
          );
        }
      }
      throw const ServerFailure(message: 'Failed to fetch place details');
    } catch (e) {
      AppLogger.error('Places Details API Error', e);
      throw ServerFailure(message: 'Failed to fetch place details: $e');
    }
  }
}
