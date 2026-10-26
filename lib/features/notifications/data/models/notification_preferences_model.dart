import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';

/// Data model and serialization mapper for [NotificationPreferences].
class NotificationPreferencesModel extends NotificationPreferences {
  /// Creates a [NotificationPreferencesModel] instance.
  const NotificationPreferencesModel({
    super.isEnabled,
    super.preferredDayOfWeek,
    super.preferredHour,
    super.preferredMinute,
    super.quietHoursStart,
    super.quietHoursEnd,
    super.maxWeeklyNotifications,
    super.consecutiveIgnoredCount,
    super.frequencyMultiplier,
    super.weeklyDeliveredCount,
    super.currentWeekNumber,
    super.lastDeliveredAt,
    super.lastOpenedAt,
  });

  /// Factory creating a model from a domain entity.
  factory NotificationPreferencesModel.fromEntity(
    NotificationPreferences entity,
  ) {
    return NotificationPreferencesModel(
      isEnabled: entity.isEnabled,
      preferredDayOfWeek: entity.preferredDayOfWeek,
      preferredHour: entity.preferredHour,
      preferredMinute: entity.preferredMinute,
      quietHoursStart: entity.quietHoursStart,
      quietHoursEnd: entity.quietHoursEnd,
      maxWeeklyNotifications: entity.maxWeeklyNotifications,
      consecutiveIgnoredCount: entity.consecutiveIgnoredCount,
      frequencyMultiplier: entity.frequencyMultiplier,
      weeklyDeliveredCount: entity.weeklyDeliveredCount,
      currentWeekNumber: entity.currentWeekNumber,
      lastDeliveredAt: entity.lastDeliveredAt,
      lastOpenedAt: entity.lastOpenedAt,
    );
  }

  /// Deserializes model from JSON map.
  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      isEnabled: (json['isEnabled'] as bool?) ?? true,
      preferredDayOfWeek:
          (json['preferredDayOfWeek'] as int?) ?? DateTime.sunday,
      preferredHour: (json['preferredHour'] as int?) ?? 10,
      preferredMinute: (json['preferredMinute'] as int?) ?? 0,
      quietHoursStart: (json['quietHoursStart'] as int?) ?? 21,
      quietHoursEnd: (json['quietHoursEnd'] as int?) ?? 8,
      maxWeeklyNotifications: (json['maxWeeklyNotifications'] as int?) ?? 3,
      consecutiveIgnoredCount: (json['consecutiveIgnoredCount'] as int?) ?? 0,
      frequencyMultiplier: (json['frequencyMultiplier'] as int?) ?? 1,
      weeklyDeliveredCount: (json['weeklyDeliveredCount'] as int?) ?? 0,
      currentWeekNumber: (json['currentWeekNumber'] as int?) ?? 0,
      lastDeliveredAt: json['lastDeliveredAt'] != null
          ? DateTime.tryParse(json['lastDeliveredAt'] as String)
          : null,
      lastOpenedAt: json['lastOpenedAt'] != null
          ? DateTime.tryParse(json['lastOpenedAt'] as String)
          : null,
    );
  }

  /// Serializes model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'preferredDayOfWeek': preferredDayOfWeek,
      'preferredHour': preferredHour,
      'preferredMinute': preferredMinute,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'maxWeeklyNotifications': maxWeeklyNotifications,
      'consecutiveIgnoredCount': consecutiveIgnoredCount,
      'frequencyMultiplier': frequencyMultiplier,
      'weeklyDeliveredCount': weeklyDeliveredCount,
      'currentWeekNumber': currentWeekNumber,
      'lastDeliveredAt': lastDeliveredAt?.toIso8601String(),
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    };
  }
}
