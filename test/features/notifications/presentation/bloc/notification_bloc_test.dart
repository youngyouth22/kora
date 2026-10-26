// ignore_for_file: document_ignores, avoid_redundant_argument_values, lines_longer_than_80_chars

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/services/notification_permission_service.dart';
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
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_state.dart';

final _testFixedDate = DateTime(2026, 10, 18, 12);

class _MockRepo implements NotificationRepository {
  NotificationPreferences prefs = const NotificationPreferences();
  bool shouldFail = false;

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'get preferences error'));
    }
    return Right(prefs);
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'update preferences error'));
    }
    prefs = preferences;
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
    if (shouldFail) {
      return const Left(CacheFailure(message: 'schedule weekly error'));
    }
    prefs = prefs.copyWith(
      preferredDayOfWeek: dayOfWeek ?? prefs.preferredDayOfWeek,
      preferredHour: hour ?? prefs.preferredHour,
      preferredMinute: minute ?? prefs.preferredMinute,
      isEnabled: true,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> scheduleTrialEndingReminder({
    required DateTime trialEndDate,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required NotificationPayload payload,
    required DateTime scheduledTime,
    bool isUserExplicitChoice = false,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, NotificationPayload?>> handleNotificationTap(
    String? rawPayload,
  ) async {
    return Right(
      NotificationPayload.fromType(
        type: NotificationType.scanDue,
        createdAt: _testFixedDate,
      ),
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
    prefs = prefs.copyWith(
      consecutiveIgnoredCount: prefs.consecutiveIgnoredCount + 1,
    );
    return Right(prefs);
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async =>
      const Right(null);

  @override
  Future<Either<Failure, bool>> isPermissionGranted() async =>
      const Right(true);

  @override
  Future<Either<Failure, bool>> requestPermission() async => const Right(true);
}

class _MockPermissionService implements NotificationPermissionService {
  bool granted = true;
  bool permDenied = false;

  @override
  Future<bool> requestNotificationPermission() async => granted;

  @override
  Future<bool> isPermissionGranted() async => granted;

  @override
  Future<bool> isPermanentlyDenied() async => permDenied;

  @override
  Future<bool> openSettings() async => true;
}

void main() {
  late _MockRepo repo;
  late _MockPermissionService permService;
  late NotificationBloc bloc;

  setUp(() {
    repo = _MockRepo();
    permService = _MockPermissionService();

    bloc = NotificationBloc(
      getPreferences: GetNotificationPreferencesUseCase(repo),
      updatePreferences: UpdateNotificationPreferencesUseCase(repo),
      scheduleWeeklyScanReminder: ScheduleWeeklyScanReminderUseCase(repo),
      scheduleTrialReminder: ScheduleTrialReminderUseCase(repo),
      dispatchNotification: DispatchNotificationUseCase(repo),
      handleNotificationTap: HandleNotificationTapUseCase(repo),
      recordNotificationIgnored: RecordNotificationIgnoredUseCase(repo),
      requestPermission: RequestNotificationPermissionUseCase(repo),
      permissionService: permService,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('NotificationBloc Tests', () {
    test('initial state has BaseStatus.initial', () {
      expect(bloc.state.status, BaseStatus.initial);
      expect(bloc.state.isPermissionGranted, isFalse);
    });

    test(
      'NotificationStarted emits [loading, success] with loaded preferences',
      () {
        final expectedStates = [
          const NotificationState(status: BaseStatus.loading),
          const NotificationState(
            status: BaseStatus.success,
            isPermissionGranted: true,
          ),
        ];

        unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));
        bloc.add(const NotificationStarted());
      },
    );

    test('NotificationPermissionRequested grants permission, schedules weekly scan and emits success', () {
      final expectedStates = [
        const NotificationState(status: BaseStatus.loading),
        const NotificationState(
          status: BaseStatus.success,
          isPermissionGranted: true,
          preferences: NotificationPreferences(isEnabled: true),
        ),
      ];

      unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));
      bloc.add(const NotificationPermissionRequested());
    });

    test('NotificationWeeklyReminderConfigured emits [loading, success] with updated cadence', () {
      final expectedStates = [
        const NotificationState(status: BaseStatus.loading),
        const NotificationState(
          status: BaseStatus.success,
          preferences: NotificationPreferences(
            preferredDayOfWeek: 1, // Monday
            preferredHour: 9,
            preferredMinute: 30,
            isEnabled: true,
          ),
        ),
      ];

      unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));
      bloc.add(
        const NotificationWeeklyReminderConfigured(
          dayOfWeek: 1,
          hour: 9,
          minute: 30,
        ),
      );
    });

    test(
      'NotificationOpened updates lastOpenedPayload and resets counters',
      () {
        final expectedStates = [
          NotificationState(
            status: BaseStatus.success,
            lastOpenedPayload: NotificationPayload.fromType(
              type: NotificationType.scanDue,
              createdAt: _testFixedDate,
            ),
          ),
        ];

        unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));
        bloc.add(const NotificationOpened('{"type":"scanDue"}'));
      },
    );
  });
}
