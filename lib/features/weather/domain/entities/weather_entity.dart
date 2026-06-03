// ─── Weather Entity ─────────────────────────────────────────────────
// Domain entity for weather forecasts.

import 'package:equatable/equatable.dart';

class WeatherForecast extends Equatable {
  final String city;
  final String country;
  final DateTime date;
  final double temp;
  final double tempMin;
  final double tempMax;
  final double feelsLike;
  final int humidity;
  final String condition;
  final String description;
  final String icon;
  final double windSpeed;
  final int cloudiness;
  final double? rain;

  const WeatherForecast({
    required this.city,
    required this.country,
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.humidity,
    required this.condition,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.cloudiness,
    this.rain,
  });

  /// Get the icon URL from OpenWeatherMap.
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Is weather good for outdoor activities?
  bool get isGoodForOutdoors =>
      !condition.toLowerCase().contains('rain') &&
      !condition.toLowerCase().contains('storm') &&
      temp > 10 &&
      temp < 35;

  /// Temperature display with unit
  String tempDisplay({bool celsius = true}) {
    if (celsius) return '${temp.round()}°C';
    return '${(temp * 9 / 5 + 32).round()}°F';
  }

  @override
  List<Object?> get props => [city, date, temp, condition];
}

/// Weather service for fetching forecasts via OpenWeatherMap API
class WeatherService {
  final String apiKey;
  WeatherService({required this.apiKey});

  /// Get 5-day forecast URL
  String forecastUrl(String city) =>
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

  /// Get current weather URL
  String currentUrl(double lat, double lon) =>
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
}
