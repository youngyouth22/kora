// ignore_for_file: document_ignores, avoid_redundant_argument_values, lines_longer_than_80_chars

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/entities/notification_rule_result.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kora/features/notifications/domain/usecases/dispatch_notification_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/handle_notification_tap_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/record_notification_ignored_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/request_notification_permission_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/schedule_trial_reminder_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/schedule_weekly_scan_reminder_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/update_notification_preferences_usecase.dart';

class _FakeNotificationRepository implements NotificationRepository {
  NotificationPreferences preferences = NotificationPreferences.initial();
  bool permissionGranted = true;
  bool scheduleWeeklyCalled = false;
  bool scheduleTrialCalled = false;
  bool dispatchCalled = false;
  bool handleTapCalled = false;
  bool recordIgnoredCalled = false;
  bool shouldFail = false;

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    if (shouldFail) return const Left(CacheFailure(message: 'error'));
    return Right(preferences);
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferences prefs,
  ) async {
    if (shouldFail) return const Left(CacheFailure(message: 'error'));
    preferences = prefs;
    return const Right(null);
  }

  @override
  Either<Failure, NotificationRuleResult> evaluateRules({
    required NotificationType type,
    required DateTime targetTime,
    required NotificationPreferences preferences,
    bool isUserExplicitChoice = false,
  }) {
    return Right(NotificationRuleResult.allowed(targetTime));
  }

  @override
  Future<Either<Failure, void>> scheduleWeeklyScanReminder({
    int? dayOfWeek,
    int? hour,
    int? minute,
  }) async {
    if (shouldFail) return const Left(CacheFailure(message: 'error'));
    scheduleWeeklyCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> scheduleTrialEndingReminder({
    required DateTime trialEndDate,
  }) async {
    if (shouldFail) return const Left(CacheFailure(message: 'error'));
    scheduleTrialCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required NotificationPayload payload,
    required DateTime scheduledTime,
    bool isUserExplicitChoice = false,
  }) async {
    if (shouldFail) return const Left(CacheFailure(message: 'error'));
    dispatchCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, NotificationPayload?>> handleNotificationTap(
    String? rawPayload,
  ) async {
    if (shouldFail) return const Left(UnexpectedFailure(message: 'error'));
    handleTapCalled = true;
    return Right(
      NotificationPayload.fromType(type: NotificationType.scanDue),
    );
  }

  @override
  Future<Either<Failure, void>> recordNotificationDelivered(
    NotificationType type,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, NotificationPreferences>>
  recordNotificationIgnored() async {
    if (shouldFail) return const Left(CacheFailure(message: 'error'));
    recordIgnoredCalled = true;
    preferences = preferences.copyWith(
      consecutiveIgnoredCount: preferences.consecutiveIgnoredCount + 1,
    );
    return Right(preferences);
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async =>
      const Right(null);

  @override
  Future<Either<Failure, bool>> isPermissionGranted() async =>
      Right(permissionGranted);

  @override
  Future<Either<Failure, bool>> requestPermission() async =>
      Right(permissionGranted);
}

void main() {
  late _FakeNotificationRepository repo;

  setUp(() {
    repo = _FakeNotificationRepository();
  });

  group('Notification Domain UseCases', () {
    test('ScheduleWeeklyScanReminderUseCase delegates to repository', () async {
      final useCase = ScheduleWeeklyScanReminderUseCase(repo);
      final result = await useCase(
        const ScheduleWeeklyScanParams(dayOfWeek: 7, hour: 10, minute: 0),
      );

      expect(result.isRight(), isTrue);
      expect(repo.scheduleWeeklyCalled, isTrue);
    });

    test('ScheduleTrialReminderUseCase delegates to repository', () async {
      final useCase = ScheduleTrialReminderUseCase(repo);
      final result = await useCase(
        ScheduleTrialReminderParams(trialEndDate: DateTime(2026, 11, 1)),
      );

      expect(result.isRight(), isTrue);
      expect(repo.scheduleTrialCalled, isTrue);
    });

    test('DispatchNotificationUseCase delegates to repository', () async {
      final useCase = DispatchNotificationUseCase(repo);
      final result = await useCase(
        DispatchNotificationParams(
          payload: NotificationPayload.fromType(
            type: NotificationType.milestone,
          ),
          scheduledTime: DateTime(2026, 10, 20, 11, 0),
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repo.dispatchCalled, isTrue);
    });

    test(
      'HandleNotificationTapUseCase delegates and returns payload',
      () async {
        final useCase = HandleNotificationTapUseCase(repo);
        final result = await useCase(
          const HandleTapParams(rawPayload: '{"type":"scanDue"}'),
        );

        expect(result.isRight(), isTrue);
        expect(repo.handleTapCalled, isTrue);
      },
    );

    test('RecordNotificationIgnoredUseCase delegates to repository', () async {
      final useCase = RecordNotificationIgnoredUseCase(repo);
      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      expect(repo.recordIgnoredCalled, isTrue);
    });

    test('GetNotificationPreferencesUseCase retrieves preferences', () async {
      final useCase = GetNotificationPreferencesUseCase(repo);
      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be right'),
        (prefs) => expect(prefs.isEnabled, isTrue),
      );
    });

    test('UpdateNotificationPreferencesUseCase updates preferences', () async {
      final useCase = UpdateNotificationPreferencesUseCase(repo);
      final result = await useCase(
        const UpdatePreferencesParams(
          NotificationPreferences(isEnabled: false),
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repo.preferences.isEnabled, isFalse);
    });

    test(
      'RequestNotificationPermissionUseCase requests authorization',
      () async {
        final useCase = RequestNotificationPermissionUseCase(repo);
        final result = await useCase(const NoParams());

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('should be right'),
          (granted) => expect(granted, isTrue),
        );
      },
    );
  });
}
