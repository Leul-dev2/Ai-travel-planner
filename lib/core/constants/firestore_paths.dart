// ─── Firestore Collection Paths ─────────────────────────────────────
// Centralized Firestore collection and document path constants.

class FirestorePaths {
  FirestorePaths._();

  // ── Top-Level Collections ──
  static const String users = 'users';
  static const String trips = 'trips';
  static const String bookings = 'bookings';
  static const String payments = 'payments';
  static const String chatSessions = 'chat_sessions';
  static const String featuredDestinations = 'featured_destinations';
  static const String analytics = 'analytics';
  static const String appConfig = 'app_config';

  // ── User Subcollections ──
  static String userDoc(String userId) => '$users/$userId';
  static String savedDestinations(String userId) =>
      '$users/$userId/saved_destinations';
  static String travelHistory(String userId) =>
      '$users/$userId/travel_history';

  // ── Trip Subcollections ──
  static String tripDoc(String tripId) => '$trips/$tripId';
  static String itinerary(String tripId) => '$trips/$tripId/itinerary';
  static String tripComments(String tripId) => '$trips/$tripId/comments';
  static String tripVotes(String tripId) => '$trips/$tripId/votes';
  static String tripExpenses(String tripId) => '$trips/$tripId/expenses';

  // ── Chat Subcollections ──
  static String chatSessionDoc(String sessionId) =>
      '$chatSessions/$sessionId';
  static String chatMessages(String sessionId) =>
      '$chatSessions/$sessionId/messages';

  // ── App Config ──
  static const String settingsDoc = '$appConfig/settings';
}
