// ─── Application Constants ──────────────────────────────────────────
// Static values used throughout the application.

class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'Smart Travel AI';
  static const String appTagline = 'Your AI-Powered Travel Companion';
  static const String appVersion = '2.0.0';

  // ── Supported Interests ──
  static const List<String> interests = [
    'beaches',
    'museums',
    'hiking',
    'food',
    'nightlife',
    'shopping',
    'adventure',
    'culture',
    'nature',
    'photography',
    'wellness',
    'history',
    'architecture',
    'wildlife',
    'water_sports',
  ];

  // ── Trip Types ──
  static const List<String> tripTypes = [
    'solo',
    'couple',
    'family',
    'group',
    'business',
  ];

  // ── Budget Categories ──
  static const List<BudgetPreset> budgetPresets = [
    BudgetPreset(label: 'Backpacker', range: '\$0 – \$500', amount: 250),
    BudgetPreset(label: 'Economy', range: '\$500 – \$1,000', amount: 750),
    BudgetPreset(label: 'Comfort', range: '\$1,000 – \$3,000', amount: 2000),
    BudgetPreset(label: 'Business', range: '\$3,000 – \$5,000', amount: 4000),
    BudgetPreset(label: 'Luxury', range: '\$5,000+', amount: 7500),
  ];

  // ── Supported Currencies ──
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'ETB',
    'KES',
    'JPY',
    'AED',
    'INR',
  ];

  // ── Supported Languages ──
  static const Map<String, String> languages = {
    'en': 'English',
    'am': 'አማርኛ',
    'fr': 'French',
    'ar': 'Arabic',
  };

  // ── Date Formats ──
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy • HH:mm';

  // ── Pagination ──
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 50;

  // ── Validation ──
  static const int minPasswordLength = 8;
  static const int maxTripDuration = 90;
  static const int maxTripNameLength = 100;
  static const int maxChatMessageLength = 2000;

  // ── Animation Durations ──
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 600);
}

class BudgetPreset {
  final String label;
  final String range;
  final double amount;

  const BudgetPreset({
    required this.label,
    required this.range,
    required this.amount,
  });
}
