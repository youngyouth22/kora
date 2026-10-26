import 'package:equatable/equatable.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';

/// Base class for all [NotificationEvent] events.
abstract class NotificationEvent extends Equatable {
  /// Base const constructor.
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on application bootstrap or page initialization
/// to load notification preferences and verify permission status.
class NotificationStarted extends NotificationEvent {
  /// Creates a [NotificationStarted] event.
  const NotificationStarted();
}

/// Dispatched when the user taps "Enable Reminders" CTA to trigger
/// system authorization request via permission_handler.
class NotificationPermissionRequested extends NotificationEvent {
  /// Creates a [NotificationPermissionRequested] event.
  const NotificationPermissionRequested({
    this.scheduleScanReminder = true,
  });

  /// Whether to immediately schedule weekly scan reminder upon authorization.
  final bool scheduleScanReminder;

  @override
  List<Object?> get props => [scheduleScanReminder];
}

/// Dispatched when user adjusts their weekly scan reminder cadence or time.
class NotificationWeeklyReminderConfigured extends NotificationEvent {
  /// Creates a [NotificationWeeklyReminderConfigured] event.
  const NotificationWeeklyReminderConfigured({
    this.dayOfWeek,
    this.hour,
    this.minute,
  });

  /// Target day of week (1..7).
  final int? dayOfWeek;

  /// Target hour of the day (0..23).
  final int? hour;

  /// Target minute of the hour (0..59).
  final int? minute;

  @override
  List<Object?> get props => [dayOfWeek, hour, minute];
}

/// Dispatched to schedule N3 trial reminder 2 days before trial ends.
class NotificationTrialReminderScheduled extends NotificationEvent {
  /// Creates a [NotificationTrialReminderScheduled] event.
  const NotificationTrialReminderScheduled({
    required this.trialEndDate,
  });

  /// Date when free trial concludes.
  final DateTime trialEndDate;

  @override
  List<Object?> get props => [trialEndDate];
}

/// Dispatched to update notification preferences directly.
class NotificationPreferencesUpdated extends NotificationEvent {
  /// Creates a [NotificationPreferencesUpdated] event.
  const NotificationPreferencesUpdated(this.preferences);

  /// Updated preferences entity.
  final NotificationPreferences preferences;

  @override
  List<Object?> get props => [preferences];
}

/// Dispatched when a local notification is tapped to trigger navigation.
class NotificationOpened extends NotificationEvent {
  /// Creates a [NotificationOpened] event.
  const NotificationOpened(this.rawPayload);

  /// Raw payload string from system notification response.
  final String? rawPayload;

  @override
  List<Object?> get props => [rawPayload];
}

/// Dispatched when a notification was delivered but ignored without open.
class NotificationIgnored extends NotificationEvent {
  /// Creates a [NotificationIgnored] event.
  const NotificationIgnored();
}

/// Dispatched to schedule or dispatch an arbitrary notification payload.
class NotificationDispatched extends NotificationEvent {
  /// Creates a [NotificationDispatched] event.
  const NotificationDispatched({
    required this.payload,
    required this.scheduledTime,
    this.isUserExplicitChoice = false,
  });

  /// Target payload to dispatch.
  final NotificationPayload payload;

  /// Target scheduled time.
  final DateTime scheduledTime;

  /// Whether time was explicitly chosen by the user.
  final bool isUserExplicitChoice;

  @override
  List<Object?> get props => [payload, scheduledTime, isUserExplicitChoice];
}
