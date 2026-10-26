// ignore_for_file: document_ignores, prefer_initializing_formals, lines_longer_than_80_chars

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:kora/features/notifications/data/models/notification_payload_model.dart';
import 'package:kora/features/notifications/data/models/notification_preferences_model.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/entities/notification_rule_result.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kora/features/notifications/domain/usecases/evaluate_notification_rules_usecase.dart';

/// Production implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  /// Creates a [NotificationRepositoryImpl] instance.
  NotificationRepositoryImpl({
    required NotificationLocalDataSource localDataSource,
    required NotificationPermissionService permissionService,
    EvaluateNotificationRulesUseCase? rulesEvaluator,
    void Function(String eventName, Map<String, dynamic> params)?
    analyticsTracker,
  }) : _localDataSource = localDataSource,
       _permissionService = permissionService,
       _rulesEvaluator =
           rulesEvaluator ?? const EvaluateNotificationRulesUseCase(),
       _analyticsTracker = analyticsTracker;

  final NotificationLocalDataSource _localDataSource;
  final NotificationPermissionService _permissionService;
  final EvaluateNotificationRulesUseCase _rulesEvaluator;
  final void Function(String eventName, Map<String, dynamic> params)?
  _analyticsTracker;

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    try {
      final model = await _localDataSource.getPreferences();
      return Right(model);
    } on Object catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to retrieve notification preferences: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final model = NotificationPreferencesModel.fromEntity(preferences);
      await _localDataSource.savePreferences(model);
      return const Right(null);
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to save notification preferences: $e'),
      );
    }
  }

  @override
  Either<Failure, NotificationRuleResult> evaluateRules({
    required NotificationType type,
    required DateTime targetTime,
    required NotificationPreferences preferences,
    bool isUserExplicitChoice = false,
  }) {
    return _rulesEvaluator(
      EvaluateRulesParams(
        type: type,
        targetTime: targetTime,
        preferences: preferences,
        isUserExplicitChoice: isUserExplicitChoice,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> scheduleWeeklyScanReminder({
    int? dayOfWeek,
    int? hour,
    int? minute,
  }) async {
    try {
      final currentPrefs = await _localDataSource.getPreferences();
      final updatedPrefs = currentPrefs.copyWith(
        preferredDayOfWeek: dayOfWeek ?? currentPrefs.preferredDayOfWeek,
        preferredHour: hour ?? currentPrefs.preferredHour,
        preferredMinute: minute ?? currentPrefs.preferredMinute,
        isEnabled: true,
      );

      final payload = NotificationPayloadModel.fromEntity(
        NotificationPayload.fromType(
          type: NotificationType.scanDue,
          createdAt: DateTime.now(),
        ),
      );

      await _localDataSource.scheduleWeeklyNotification(
        id: NotificationType.scanDue.id,
        title: payload.title,
        body: payload.body,
        payloadJson: payload.toJsonString(),
      );

      await _localDataSource.savePreferences(
        NotificationPreferencesModel.fromEntity(updatedPrefs),
      );

      // Track reminder_enabled event
      _analyticsTracker?.call('reminder_enabled', {
        'day_of_week': updatedPrefs.preferredDayOfWeek,
        'hour': updatedPrefs.preferredHour,
        'minute': updatedPrefs.preferredMinute,
        'frequency_multiplier': updatedPrefs.frequencyMultiplier,
      });

      return const Right(null);
    } on Object catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to schedule weekly scan reminder: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> scheduleTrialEndingReminder({
    required DateTime trialEndDate,
  }) async {
    // N3: 2 days before trial ends
    final targetTime = trialEndDate.subtract(const Duration(days: 2));
    final payload = NotificationPayload.fromType(
      type: NotificationType.trialEnding,
    );

    return scheduleNotification(
      payload: payload,
      scheduledTime: targetTime,
    );
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required NotificationPayload payload,
    required DateTime scheduledTime,
    bool isUserExplicitChoice = false,
  }) async {
    try {
      final prefs = await _localDataSource.getPreferences();

      // Enforce business rules
      final ruleResult = _rulesEvaluator(
        EvaluateRulesParams(
          type: payload.type,
          targetTime: scheduledTime,
          preferences: prefs,
          isUserExplicitChoice: isUserExplicitChoice,
        ),
      );

      return await ruleResult.fold(
        (failure) async => Left(failure),
        (result) async {
          if (!result.isAllowed) {
            return Left(
              ValidationFailure(
                message:
                    'Notification rejected by policy: ${result.rejectionReason}',
              ),
            );
          }

          final model = NotificationPayloadModel.fromEntity(payload);

          await _localDataSource.showNotification(
            id: payload.type.id,
            title: payload.title,
            body: payload.body,
            payloadJson: model.toJsonString(),
          );

          await recordNotificationDelivered(payload.type);
          return const Right(null);
        },
      );
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to schedule notification: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationPayload?>> handleNotificationTap(
    String? rawPayload,
  ) async {
    try {
      final parsed = _localDataSource.parsePayload(rawPayload);
      if (parsed == null) return const Right(null);

      // Reset consecutive ignored count on user engagement
      final prefs = await _localDataSource.getPreferences();
      final updatedPrefs = prefs.copyWith(
        consecutiveIgnoredCount: 0,
        frequencyMultiplier: 1, // Restores normal frequency
        lastOpenedAt: DateTime.now(),
      );
      await _localDataSource.savePreferences(
        NotificationPreferencesModel.fromEntity(updatedPrefs),
      );

      // Track notification_opened event
      _analyticsTracker?.call('notification_opened', {
        'notification_type': parsed.type.name,
        'target_route': parsed.targetRoute,
        'category': parsed.type.category,
      });

      return Right(parsed);
    } on Object catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to handle notification tap: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> recordNotificationDelivered(
    NotificationType type,
  ) async {
    try {
      final prefs = await _localDataSource.getPreferences();
      final updated = prefs.copyWith(
        weeklyDeliveredCount: prefs.weeklyDeliveredCount + 1,
        lastDeliveredAt: DateTime.now(),
      );
      await _localDataSource.savePreferences(
        NotificationPreferencesModel.fromEntity(updated),
      );
      return const Right(null);
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to record delivered notification: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>>
  recordNotificationIgnored() async {
    try {
      final prefs = await _localDataSource.getPreferences();
      final nextIgnored = prefs.consecutiveIgnoredCount + 1;
      // Rule: 2 ignored in a row -> frequency divided (multiplier = 2)
      final multiplier = nextIgnored >= 2 ? 2 : prefs.frequencyMultiplier;

      final updated = prefs.copyWith(
        consecutiveIgnoredCount: nextIgnored,
        frequencyMultiplier: multiplier,
      );

      await _localDataSource.savePreferences(
        NotificationPreferencesModel.fromEntity(updated),
      );
      return Right(updated);
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to record ignored notification: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async {
    try {
      await _localDataSource.cancel(id);
      return const Right(null);
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to cancel notification $id: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await _localDataSource.cancelAll();
      return const Right(null);
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to cancel all notifications: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isPermissionGranted() async {
    try {
      final granted = await _permissionService.isPermissionGranted();
      return Right(granted);
    } on Object catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to check permission: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final granted = await _permissionService.requestNotificationPermission();
      return Right(granted);
    } on Object catch (e) {
      return Left(
        UnexpectedFailure(message: 'Failed to request permission: $e'),
      );
    }
  }
}
