// ─── Route Names ────────────────────────────────────────────────────
// Centralized route path constants for GoRouter.

class RouteNames {
  RouteNames._();

  // ── Auth ──
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ── Main ──
  static const String home = '/home';
  static const String discover = '/discover';

  // ── Trip Planning ──
  static const String planTrip = '/plan';
  static const String itinerary = '/itinerary/:tripId';
  static const String budgetRejected = '/budget-rejected';

  // ── Dashboard ──
  static const String dashboard = '/dashboard';
  static const String tripDetail = '/trip/:tripId';

  // ── AI Chat ──
  static const String aiChat = '/ai-chat';
  static const String chatSession = '/ai-chat/:sessionId';

  // ── Maps ──
  static const String map = '/map';
  static const String placeDetail = '/place/:placeId';

  // ── Profile ──
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // ── Bookings ──
  static const String bookings = '/bookings';
  static const String bookingDetail = '/booking/:bookingId';

  // ── Budget & Weather ──
  static const String budgetOverview = '/budget';
  static const String weather = '/weather';

  // ── Notifications & Subscription ──
  static const String notifications = '/notifications';
  static const String paywall = '/paywall';

  // ── Budget (per trip) ──
  static const String budget = '/budget/:tripId';

  // ── Collaborative ──
  static const String collaborators = '/trip/:tripId/collaborators';

  // ── Admin ──
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminTrips = '/admin/trips';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminDestinations = '/admin/destinations';

  // ── Helpers ──
  static String itineraryPath(String tripId) => '/itinerary/$tripId';
  static String tripDetailPath(String tripId) => '/trip/$tripId';
  static String chatSessionPath(String sessionId) => '/ai-chat/$sessionId';
  static String budgetPath(String tripId) => '/budget/$tripId';
}
