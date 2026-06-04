// ─── Core Configuration ─────────────────────────────────────────────
// Environment-based app configuration with secure key management.
// Keys are loaded from .env file and Firebase Remote Config.

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/firebase_constants.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment _env = Environment.development;

  static Environment get environment => _env;
  static bool get isDev => _env == Environment.development;
  static bool get isStaging => _env == Environment.staging;
  static bool get isProd => _env == Environment.production;

  /// Initialize configuration from .env
  static Future<void> init({Environment env = Environment.development}) async {
    _env = env;
    await dotenv.load(fileName: '.env');
  }

  // ── Firebase ──
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseWebAppId => dotenv.env['FIREBASE_WEB_APP_ID'] ?? '';

  static String get firebaseWebApiKey =>
      dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';

  // ── AI Keys ──

  /// Cohere (PRIMARY) — Command R+
  static String get cohereApiKey => dotenv.env['COHERE_API_KEY'] ?? '';
  static bool get cohereEnabled => cohereApiKey.isNotEmpty;

  /// Direct OpenAI (sk-proj…). Prefer OPEN_AI_API_KEY over OPENAI_API_KEY.
  static String get openAiApiKey {
    final dedicated = dotenv.env['OPEN_AI_API_KEY'] ?? '';
    if (dedicated.isNotEmpty) return dedicated;
    final openAi = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (openAi.startsWith('sk-proj')) return openAi;
    return '';
  }

  /// OpenRouter (sk-or-v1… or OPENROUTER_API_KEY).
  static String get openRouterApiKey {
    final dedicated = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (dedicated.isNotEmpty) return dedicated;
    final openAi = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (openAi.startsWith('sk-or-')) return openAi;
    return '';
  }

  static String get openRouterModelId =>
      dotenv.env['OPENROUTER_MODEL'] ?? 'openai/gpt-4o-mini';

  static String get openRouterHttpReferer =>
      dotenv.env['OPENROUTER_HTTP_REFERER'] ?? 'http://localhost';

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get geminiModelId =>
      dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.0-flash';

  static bool get geminiEnabled =>
      dotenv.env['DISABLE_GEMINI'] != 'true' && geminiApiKey.isNotEmpty;

  // ── Google ──
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static String get googleSignInClientId =>
      dotenv.env['GOOGLE_SIGNIN_CLIENT_ID'] ?? kGoogleSignInWebClientId;

  // ── Payments ──
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get chapaApiKey => dotenv.env['CHAPUBK_TEST'] ?? '';

  // ── Weather ──
  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // ── Legacy Backend ──
  static String get legacyApiUrl =>
      dotenv.env['LEGACY_API_URL'] ?? 'http://10.0.2.2:5000';

  // ── App Defaults ──
  static const String appName = 'Wanderlust AI';
  static const String appVersion = '2.0.0';
  static const int aiTimeoutSeconds = 30;
  static const int maxFreeTripsPerMonth = 10;
  static const int chatRateLimitPerHour = 60;
  static const int aiRateLimitPerHour = 10;
}
