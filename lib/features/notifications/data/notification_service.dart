// ─── Notification Service ───────────────────────────────────────────
// Local & push notification management.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/utils/logger.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize the notification system
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    AppLogger.info('Notification service initialized');
  }

  /// Show a local notification immediately
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_travel_channel',
      'Smart Travel AI',
      channelDescription: 'Travel planning notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification for a future time
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // TODO: Implement timezone-aware scheduling
    // Using flutter_local_notifications zonedSchedule
    AppLogger.info(
      'Notification scheduled: "$title" at ${scheduledDate.toIso8601String()}',
    );
  }

  /// Cancel a specific notification
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Show trip countdown notification
  static Future<void> showTripCountdown({
    required String tripTitle,
    required int daysUntil,
    required String tripId,
  }) async {
    await show(
      id: tripId.hashCode,
      title: '🧳 $tripTitle',
      body: daysUntil == 0
          ? "Today's the day! Your trip starts now!"
          : daysUntil == 1
              ? 'Your trip starts tomorrow!'
              : '$daysUntil days until your trip!',
      payload: 'trip:$tripId',
    );
  }

  /// Show AI generation complete notification
  static Future<void> showItineraryReady({
    required String tripTitle,
    required String tripId,
  }) async {
    await show(
      id: 'itinerary_$tripId'.hashCode,
      title: '✨ Itinerary Ready!',
      body: 'Your AI-generated plan for $tripTitle is ready to view.',
      payload: 'itinerary:$tripId',
    );
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    AppLogger.info('Notification tapped: $payload');
    // TODO: Route to appropriate screen based on payload
    // e.g., 'trip:abc123' → navigate to trip detail
    // e.g., 'itinerary:abc123' → navigate to itinerary
  }
}
