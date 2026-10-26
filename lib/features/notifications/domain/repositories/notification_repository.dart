import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/entities/notification_rule_result.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';

/// Abstract contract governing notification preferences, rule enforcement,
/// local delivery, and deep-link lifecycle in Kora.
abstract class NotificationRepository {
  /// Fetches the active user notification preferences.
  Future<Either<Failure, NotificationPreferences>> getPreferences();

  /// Persists modified user notification preferences.
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferences preferences,
  );

  /// Evaluates business rules (max 3/week, quiet hours 21h-8h, back-off)
  /// for a target candidate time and notification type.
  Either<Failure, NotificationRuleResult> evaluateRules({
    required NotificationType type,
    required DateTime targetTime,
    required NotificationPreferences preferences,
    bool isUserExplicitChoice = false,
  });

  /// Schedules the weekly skin scan reminder (N1) based on preferences.
  Future<Either<Failure, void>> scheduleWeeklyScanReminder({
    int? dayOfWeek,
    int? hour,
    int? minute,
  });

  /// Schedules a free trial ending reminder (N3) 2 days before expiry.
  Future<Either<Failure, void>> scheduleTrialEndingReminder({
    required DateTime trialEndDate,
  });

  /// Dispatches or schedules a single structured notification payload.
  Future<Either<Failure, void>> scheduleNotification({
    required NotificationPayload payload,
    required DateTime scheduledTime,
    bool isUserExplicitChoice = false,
  });

  /// Processes notification response when user taps a delivered notification.
  /// Parses payload, records analytics event, and resets ignored counter.
  Future<Either<Failure, NotificationPayload?>> handleNotificationTap(
    String? rawPayload,
  );

  /// Records that a notification was delivered or scheduled.
  Future<Either<Failure, void>> recordNotificationDelivered(
    NotificationType type,
  );

  /// Records an ignored notification (e.g. delivered but unopened),
  /// incrementing consecutive counter and dividing frequency if >= 2.
  Future<Either<Failure, NotificationPreferences>> recordNotificationIgnored();

  /// Cancels a specific notification by ID.
  Future<Either<Failure, void>> cancelNotification(int id);

  /// Cancels all scheduled local notifications.
  Future<Either<Failure, void>> cancelAllNotifications();

  /// Checks if notification permission is granted.
  Future<Either<Failure, bool>> isPermissionGranted();

  /// Requests notification permission from user.
  Future<Either<Failure, bool>> requestPermission();
}
