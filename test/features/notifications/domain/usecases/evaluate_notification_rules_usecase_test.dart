// ignore_for_file: document_ignores, avoid_redundant_argument_values, cascade_invocations, lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';
import 'package:kora/features/notifications/domain/usecases/evaluate_notification_rules_usecase.dart';

void main() {
  late EvaluateNotificationRulesUseCase useCase;

  setUp(() {
    useCase = const EvaluateNotificationRulesUseCase();
  });

  group('EvaluateNotificationRulesUseCase', () {
    test(
      'allows notification when enabled, under weekly cap, and in day hours',
      () {
        final preferences = NotificationPreferences.initial();
        final targetTime = DateTime(2026, 10, 19, 14); // 2:00 PM Monday

        final result = useCase(
          EvaluateRulesParams(
            type: NotificationType.scanDue,
            targetTime: targetTime,
            preferences: preferences,
          ),
        );

        result.fold(
          (failure) => fail('Expected Right but got $failure'),
          (ruleResult) {
            expect(ruleResult.isAllowed, isTrue);
            expect(ruleResult.isAdjustedForQuietHours, isFalse);
            expect(ruleResult.scheduledTime, equals(targetTime));
          },
        );
      },
    );

    test('rejects notification when user disabled notifications', () {
      const preferences = NotificationPreferences(isEnabled: false);
      final targetTime = DateTime(2026, 10, 19, 14);

      final result = useCase(
        EvaluateRulesParams(
          type: NotificationType.scanDue,
          targetTime: targetTime,
          preferences: preferences,
        ),
      );

      result.fold(
        (failure) => fail('Expected Right but got $failure'),
        (ruleResult) {
          expect(ruleResult.isAllowed, isFalse);
          expect(ruleResult.rejectionReason, equals('notifications_disabled'));
        },
      );
    });

    test(
      'rejects notification when weekly cap (max 3/week) has been reached',
      () {
        const preferences = NotificationPreferences(
          weeklyDeliveredCount: 3,
          maxWeeklyNotifications: 3,
        );
        final targetTime = DateTime(2026, 10, 19, 14);

        final result = useCase(
          EvaluateRulesParams(
            type: NotificationType.scanLate,
            targetTime: targetTime,
            preferences: preferences,
          ),
        );

        result.fold(
          (failure) => fail('Expected Right but got $failure'),
          (ruleResult) {
            expect(ruleResult.isAllowed, isFalse);
            expect(ruleResult.rejectionReason, equals('weekly_limit_reached'));
          },
        );
      },
    );

    test('shifts notification during late evening quiet hours (>= 21:00) to 09:00 next day', () {
      final preferences = NotificationPreferences.initial();
      final targetTime = DateTime(2026, 10, 19, 21, 30); // 9:30 PM

      final result = useCase(
        EvaluateRulesParams(
          type: NotificationType.verdict,
          targetTime: targetTime,
          preferences: preferences,
        ),
      );

      result.fold(
        (failure) => fail('Expected Right but got $failure'),
        (ruleResult) {
          expect(ruleResult.isAllowed, isTrue);
          expect(ruleResult.isAdjustedForQuietHours, isTrue);
          expect(ruleResult.scheduledTime.year, equals(2026));
          expect(ruleResult.scheduledTime.month, equals(10));
          expect(ruleResult.scheduledTime.day, equals(20)); // Next day
          expect(ruleResult.scheduledTime.hour, equals(9)); // 9:00 AM
        },
      );
    });

    test('shifts notification during early morning quiet hours (< 08:00) to 09:00 same day', () {
      final preferences = NotificationPreferences.initial();
      final targetTime = DateTime(2026, 10, 19, 6, 45); // 6:45 AM

      final result = useCase(
        EvaluateRulesParams(
          type: NotificationType.routine,
          targetTime: targetTime,
          preferences: preferences,
        ),
      );

      result.fold(
        (failure) => fail('Expected Right but got $failure'),
        (ruleResult) {
          expect(ruleResult.isAllowed, isTrue);
          expect(ruleResult.isAdjustedForQuietHours, isTrue);
          expect(ruleResult.scheduledTime.day, equals(19)); // Same day
          expect(ruleResult.scheduledTime.hour, equals(9)); // 9:00 AM
        },
      );
    });

    test('does NOT shift quiet hours when isUserExplicitChoice is true', () {
      final preferences = NotificationPreferences.initial();
      final targetTime = DateTime(2026, 10, 19, 22); // 10:00 PM chosen by user

      final result = useCase(
        EvaluateRulesParams(
          type: NotificationType.scanDue,
          targetTime: targetTime,
          preferences: preferences,
          isUserExplicitChoice: true,
        ),
      );

      result.fold(
        (failure) => fail('Expected Right but got $failure'),
        (ruleResult) {
          expect(ruleResult.isAllowed, isTrue);
          expect(ruleResult.isAdjustedForQuietHours, isFalse);
          expect(ruleResult.scheduledTime, equals(targetTime));
        },
      );
    });
  });
}
