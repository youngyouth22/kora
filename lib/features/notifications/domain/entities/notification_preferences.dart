import 'package:equatable/equatable.dart';

/// Pure domain entity storing notification settings, scheduling cadence,
/// quiet hours policies, and frequency back-off metrics.
class NotificationPreferences extends Equatable {
  /// Creates a [NotificationPreferences] entity.
  const NotificationPreferences({
    this.isEnabled = true,
    this.preferredDayOfWeek = DateTime.sunday,
    this.preferredHour = 10,
    this.preferredMinute = 0,
    this.quietHoursStart = 21,
    this.quietHoursEnd = 8,
    this.maxWeeklyNotifications = 3,
    this.consecutiveIgnoredCount = 0,
    this.frequencyMultiplier = 1,
    this.weeklyDeliveredCount = 0,
    this.currentWeekNumber = 0,
    this.lastDeliveredAt,
    this.lastOpenedAt,
  });

  /// Factory creating default standard preferences.
  factory NotificationPreferences.initial() => const NotificationPreferences();

  /// Whether local notifications are enabled by user.
  final bool isEnabled;

  /// Preferred day of week for weekly skin scan (1 = Monday, 7 = Sunday).
  final int preferredDayOfWeek;

  /// Preferred hour of the day (0..23). Default 10 (10:00 AM).
  final int preferredHour;

  /// Preferred minute of the hour (0..59).
  final int preferredMinute;

  /// Start hour of quiet hours (21 = 9 PM).
  final int quietHoursStart;

  /// End hour of quiet hours (8 = 8 AM).
  final int quietHoursEnd;

  /// Maximum notifications permitted per calendar week across all categories.
  final int maxWeeklyNotifications;

  /// Count of consecutive notifications delivered without being opened.
  final int consecutiveIgnoredCount;

  /// Frequency multiplier (1 = normal weekly; 2 = divided/bi-weekly cadence).
  final int frequencyMultiplier;

  /// Total notifications delivered during the active calendar week.
  final int weeklyDeliveredCount;

  /// Active calendar week index (used for weekly counter resets).
  final int currentWeekNumber;

  /// Timestamp of the last dispatched notification.
  final DateTime? lastDeliveredAt;

  /// Timestamp when a notification was last opened.
  final DateTime? lastOpenedAt;

  /// Whether the frequency has been halved/divided due to 2+ ignored in a row.
  bool get isFrequencyDivided => frequencyMultiplier > 1;

  /// Copies instance with modified properties.
  NotificationPreferences copyWith({
    bool? isEnabled,
    int? preferredDayOfWeek,
    int? preferredHour,
    int? preferredMinute,
    int? quietHoursStart,
    int? quietHoursEnd,
    int? maxWeeklyNotifications,
    int? consecutiveIgnoredCount,
    int? frequencyMultiplier,
    int? weeklyDeliveredCount,
    int? currentWeekNumber,
    DateTime? lastDeliveredAt,
    DateTime? lastOpenedAt,
  }) {
    return NotificationPreferences(
      isEnabled: isEnabled ?? this.isEnabled,
      preferredDayOfWeek: preferredDayOfWeek ?? this.preferredDayOfWeek,
      preferredHour: preferredHour ?? this.preferredHour,
      preferredMinute: preferredMinute ?? this.preferredMinute,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      maxWeeklyNotifications:
          maxWeeklyNotifications ?? this.maxWeeklyNotifications,
      consecutiveIgnoredCount:
          consecutiveIgnoredCount ?? this.consecutiveIgnoredCount,
      frequencyMultiplier: frequencyMultiplier ?? this.frequencyMultiplier,
      weeklyDeliveredCount: weeklyDeliveredCount ?? this.weeklyDeliveredCount,
      currentWeekNumber: currentWeekNumber ?? this.currentWeekNumber,
      lastDeliveredAt: lastDeliveredAt ?? this.lastDeliveredAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  List<Object?> get props => [
    isEnabled,
    preferredDayOfWeek,
    preferredHour,
    preferredMinute,
    quietHoursStart,
    quietHoursEnd,
    maxWeeklyNotifications,
    consecutiveIgnoredCount,
    frequencyMultiplier,
    weeklyDeliveredCount,
    currentWeekNumber,
    lastDeliveredAt,
    lastOpenedAt,
  ];
}
