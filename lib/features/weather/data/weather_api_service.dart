import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/entities/weather_entity.dart';

class WeatherApiService {
  const WeatherApiService();

  bool get isConfigured {
    final key = AppConfig.openWeatherApiKey;
    return key.isNotEmpty && key != 'your-weather-key';
  }

  Future<WeatherForecast> fetchCurrent({required String city}) async {
    final key = AppConfig.openWeatherApiKey;
    if (!isConfigured) {
      throw Exception('OpenWeather API key not configured in .env');
    }

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?q=${Uri.encodeComponent(city)}&appid=$key&units=metric',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather API ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final main = data['main'] as Map<String, dynamic>? ?? {};
    final weather = (data['weather'] as List?)?.first as Map<String, dynamic>? ?? {};
    final wind = data['wind'] as Map<String, dynamic>? ?? {};
    final sys = data['sys'] as Map<String, dynamic>? ?? {};

    return WeatherForecast(
      city: data['name'] as String? ?? city,
      country: sys['country'] as String? ?? '',
      date: DateTime.now(),
      temp: (main['temp'] as num?)?.toDouble() ?? 0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      condition: weather['main'] as String? ?? 'Unknown',
      description: weather['description'] as String? ?? '',
      icon: weather['icon'] as String? ?? '01d',
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      cloudiness: (data['clouds']?['all'] as num?)?.toInt() ?? 0,
    );
  }
}
