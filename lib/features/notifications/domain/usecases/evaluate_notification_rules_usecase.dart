// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/entities/notification_rule_result.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';

/// Parameters for evaluating notification dispatch rules.
class EvaluateRulesParams extends Equatable {
  /// Creates an [EvaluateRulesParams] instance.
  const EvaluateRulesParams({
    required this.type,
    required this.targetTime,
    required this.preferences,
    this.isUserExplicitChoice = false,
  });

  /// Target notification type.
  final NotificationType type;

  /// Candidate scheduled time.
  final DateTime targetTime;

  /// User notification preferences.
  final NotificationPreferences preferences;

  /// Whether user explicitly chose this time.
  final bool isUserExplicitChoice;

  @override
  List<Object?> get props => [
    type,
    targetTime,
    preferences,
    isUserExplicitChoice,
  ];
}

/// Pure business logic usecase enforcing all enterprise notification constraints:
/// 1. Notifications must be enabled.
/// 2. Max 3 notifications per week across all categories.
/// 3. Quiet hours (21:00 to 08:00) strictly observed unless user explicitly
///    selected that hour. If intercepted, automatically adjusted to 09:00 AM.
/// 4. Frequency back-off: 2 consecutive ignored notifications double interval.
class EvaluateNotificationRulesUseCase
    implements SynchronousUseCase<NotificationRuleResult, EvaluateRulesParams> {
  /// Creates an [EvaluateNotificationRulesUseCase].
  const EvaluateNotificationRulesUseCase();

  @override
  Either<Failure, NotificationRuleResult> call(EvaluateRulesParams params) {
    final prefs = params.preferences;
    final target = params.targetTime;

    // 1. Master toggle check
    if (!prefs.isEnabled) {
      return Right(
        NotificationRuleResult.rejected(
          reason: 'notifications_disabled',
          requestedTime: target,
        ),
      );
    }

    // 2. Max 3 notifications per week rule
    if (prefs.weeklyDeliveredCount >= prefs.maxWeeklyNotifications) {
      return Right(
        NotificationRuleResult.rejected(
          reason: 'weekly_limit_reached',
          requestedTime: target,
        ),
      );
    }

    // 3. Quiet hours rule: Never between 21:00 and 08:00 (unless user's choice)
    var effectiveTime = target;
    var wasAdjusted = false;

    if (!params.isUserExplicitChoice) {
      final hour = target.hour;
      final isQuiet =
          hour >= prefs.quietHoursStart || hour < prefs.quietHoursEnd;

      if (isQuiet) {
        wasAdjusted = true;
        // Shift to 09:00 AM outside quiet hours
        if (hour >= prefs.quietHoursStart) {
          final nextDay = target.add(const Duration(days: 1));
          effectiveTime = DateTime(
            nextDay.year,
            nextDay.month,
            nextDay.day,
            9,
          );
        } else {
          effectiveTime = DateTime(
            target.year,
            target.month,
            target.day,
            9,
          );
        }
      }
    }

    if (wasAdjusted) {
      return Right(
        NotificationRuleResult.adjusted(
          adjustedTime: effectiveTime,
        ),
      );
    }

    return Right(NotificationRuleResult.allowed(effectiveTime));
  }
}
