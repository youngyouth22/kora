// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:kora/features/notifications/data/models/notification_payload_model.dart';
import 'package:kora/features/notifications/data/models/notification_preferences_model.dart';
import 'package:kora/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';
import 'package:kora/features/notifications/domain/usecases/evaluate_notification_rules_usecase.dart';

class _FakeLocalDataSource implements NotificationLocalDataSource {
  NotificationPreferencesModel preferences =
      const NotificationPreferencesModel();
  bool showCalled = false;
  bool scheduleWeeklyCalled = false;
  bool cancelCalled = false;
  bool cancelAllCalled = false;
  String? lastPayload;

  @override
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  }) async {}

  @override
  Future<NotificationPreferencesModel> getPreferences() async => preferences;

  @override
  Future<void> savePreferences(
    NotificationPreferencesModel newPreferences,
  ) async {
    preferences = newPreferences;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payloadJson,
  }) async {
    showCalled = true;
    lastPayload = payloadJson;
  }

  @override
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required String payloadJson,
  }) async {
    scheduleWeeklyCalled = true;
    lastPayload = payloadJson;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalled = true;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }

  @override
  NotificationPayloadModel? parsePayload(String? payload) {
    return NotificationPayloadModel.tryParse(payload);
  }
}

class _FakePermissionService implements NotificationPermissionService {
  bool granted = true;
  bool permanentlyDenied = false;

  @override
  Future<bool> requestNotificationPermission() async => granted;

  @override
  Future<bool> isPermissionGranted() async => granted;

  @override
  Future<bool> isPermanentlyDenied() async => permanentlyDenied;

  @override
  Future<bool> openSettings() async => true;
}

void main() {
  late _FakeLocalDataSource dataSource;
  late _FakePermissionService permissionService;
  late NotificationRepositoryImpl repository;
  late Map<String, dynamic> trackedEvents;

  setUp(() {
    dataSource = _FakeLocalDataSource();
    permissionService = _FakePermissionService();
    trackedEvents = {};

    repository = NotificationRepositoryImpl(
      localDataSource: dataSource,
      permissionService: permissionService,
      rulesEvaluator: const EvaluateNotificationRulesUseCase(),
      analyticsTracker: (event, params) {
        trackedEvents[event] = params;
      },
    );
  });

  group('NotificationRepositoryImpl Tests', () {
    test('getPreferences returns preferences from local datasource', () async {
      final result = await repository.getPreferences();
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected right'),
        (prefs) => expect(prefs.isEnabled, isTrue),
      );
    });

    test(
      'scheduleWeeklyScanReminder schedules weekly and tracks reminder_enabled',
      () async {
        final result = await repository.scheduleWeeklyScanReminder(
          dayOfWeek: 7,
          hour: 10,
          minute: 0,
        );

        expect(result.isRight(), isTrue);
        expect(dataSource.scheduleWeeklyCalled, isTrue);
        expect(trackedEvents.containsKey('reminder_enabled'), isTrue);
        final eventParams =
            trackedEvents['reminder_enabled'] as Map<String, dynamic>;
        expect(eventParams['day_of_week'], equals(7));
        expect(eventParams['hour'], equals(10));
      },
    );

    test(
      'scheduleTrialEndingReminder targets 2 days before trial end',
      () async {
        final trialEnd = DateTime(2026, 11, 10, 14);
        final result = await repository.scheduleTrialEndingReminder(
          trialEndDate: trialEnd,
        );

        expect(result.isRight(), isTrue);
        expect(dataSource.showCalled, isTrue);
      },
    );

    test(
      'scheduleNotification returns ValidationFailure when rejected by policy',
      () async {
        // Set weekly cap reached (3 notifications delivered)
        dataSource.preferences = NotificationPreferencesModel.fromEntity(
          dataSource.preferences.copyWith(
            weeklyDeliveredCount: 3,
            maxWeeklyNotifications: 3,
          ),
        );

        final payload = NotificationPayload.fromType(
          type: NotificationType.scanLate,
        );

        final result = await repository.scheduleNotification(
          payload: payload,
          scheduledTime: DateTime(2026, 10, 20, 15),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('weekly_limit_reached'));
          },
          (_) => fail('expected left'),
        );
      },
    );

    test('recordNotificationIgnored divides frequency (multiplier = 2) when 2 in a row ignored', () async {
      // First ignore
      var res = await repository.recordNotificationIgnored();
      expect(res.isRight(), isTrue);
      res.fold(
        (_) => fail('expected right'),
        (prefs) {
          expect(prefs.consecutiveIgnoredCount, equals(1));
          expect(prefs.frequencyMultiplier, equals(1));
          expect(prefs.isFrequencyDivided, isFalse);
        },
      );

      // Second ignore -> frequency divided!
      res = await repository.recordNotificationIgnored();
      expect(res.isRight(), isTrue);
      res.fold(
        (_) => fail('expected right'),
        (prefs) {
          expect(prefs.consecutiveIgnoredCount, equals(2));
          expect(prefs.frequencyMultiplier, equals(2));
          expect(prefs.isFrequencyDivided, isTrue);
        },
      );
    });

    test('handleNotificationTap resets consecutive ignored count, restores frequency multiplier to 1, and tracks notification_opened', () async {
      // Setup state with 2 ignored
      dataSource.preferences = NotificationPreferencesModel.fromEntity(
        dataSource.preferences.copyWith(
          consecutiveIgnoredCount: 2,
          frequencyMultiplier: 2,
        ),
      );

      final payload = NotificationPayloadModel.fromEntity(
        NotificationPayload.fromType(type: NotificationType.scanDue),
      );

      final result = await repository.handleNotificationTap(
        payload.toJsonString(),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected right'),
        (parsed) {
          expect(parsed?.type, equals(NotificationType.scanDue));
          expect(dataSource.preferences.consecutiveIgnoredCount, equals(0));
          expect(dataSource.preferences.frequencyMultiplier, equals(1));
          expect(trackedEvents.containsKey('notification_opened'), isTrue);
          final eventParams =
              trackedEvents['notification_opened'] as Map<String, dynamic>;
          expect(
            eventParams['notification_type'],
            equals('scanDue'),
          );
        },
      );
    });

    test('permission requests delegate to permissionService', () async {
      final isGrantedResult = await repository.isPermissionGranted();
      expect(isGrantedResult.isRight(), isTrue);

      final requestResult = await repository.requestPermission();
      expect(requestResult.isRight(), isTrue);
    });
  });
}
