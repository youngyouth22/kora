import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kora/features/notifications/data/models/notification_payload_model.dart';
import 'package:kora/features/notifications/data/models/notification_preferences_model.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';

/// Contract for local notifications plugin interactions and cached preferences.
abstract class NotificationLocalDataSource {
  /// Initializes the local notifications plugin and notification channels.
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  });

  /// Retrieves user notification preferences.
  Future<NotificationPreferencesModel> getPreferences();

  /// Persists modified user notification preferences.
  Future<void> savePreferences(NotificationPreferencesModel preferences);

  /// Shows an immediate or timed local notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payloadJson,
  });

  /// Periodically schedules weekly notification.
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required String payloadJson,
  });

  /// Cancels a specific notification by ID.
  Future<void> cancel(int id);

  /// Cancels all active and scheduled notifications.
  Future<void> cancelAll();

  /// Processes raw payload received from notification response.
  NotificationPayloadModel? parsePayload(String? payload);
}

/// Production implementation backed by [FlutterLocalNotificationsPlugin].
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  /// Creates a [NotificationLocalDataSourceImpl] instance.
  NotificationLocalDataSourceImpl({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationPreferencesModel _preferences =
      const NotificationPreferencesModel();
  void Function(NotificationPayload payload)? _onNotificationTapped;
  bool _isInitialized = false;

  static const String _channelId = 'kora_skin_reminders';
  static const String _channelName = 'Weekly Skin Scans';
  static const String _channelDescription =
      'Gentle reminders for your weekly skin scans and routine check-ins.';

  @override
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  }) async {
    if (_isInitialized) {
      _onNotificationTapped = onNotificationTapped;
      return;
    }

    _onNotificationTapped = onNotificationTapped;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = parsePayload(response.payload);
        if (payload != null && _onNotificationTapped != null) {
          _onNotificationTapped!(payload);
        }
      },
    );

    // Create high importance Android notification channel
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
    }

    _isInitialized = true;
  }

  @override
  Future<NotificationPreferencesModel> getPreferences() async {
    _resetWeeklyCounterIfNeeded();
    return _preferences;
  }

  @override
  Future<void> savePreferences(NotificationPreferencesModel preferences) async {
    _preferences = preferences;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payloadJson,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payloadJson,
    );
  }

  @override
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required String payloadJson,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: RepeatInterval.weekly,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payloadJson,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  NotificationPayloadModel? parsePayload(String? payload) {
    return NotificationPayloadModel.tryParse(payload);
  }

  void _resetWeeklyCounterIfNeeded() {
    final now = DateTime.now();
    // Approximate calendar week index from epoch
    final currentWeek = (now.millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7))
        .floor();
    if (_preferences.currentWeekNumber != currentWeek) {
      _preferences = _preferences.copyWith(
        weeklyDeliveredCount: 0,
        currentWeekNumber: currentWeek,
      ) as NotificationPreferencesModel;
    }
  }
}
