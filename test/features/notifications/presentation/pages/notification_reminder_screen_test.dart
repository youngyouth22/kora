// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_state.dart';
import 'package:kora/features/notifications/presentation/pages/notification_reminder_screen.dart';
import 'package:kora/features/notifications/presentation/widgets/notification_preview_card.dart';
import 'package:kora/features/notifications/presentation/widgets/notification_rule_info_row.dart';

class _FakeNotificationPermissionService
    implements NotificationPermissionService {
  _FakeNotificationPermissionService({
    required this.isGranted,
    this.isPermDenied = false,
  });

  bool isGranted;
  bool isPermDenied;
  int requestCount = 0;
  bool openSettingsCalled = false;

  @override
  Future<bool> requestNotificationPermission() async {
    requestCount++;
    return isGranted;
  }

  @override
  Future<bool> isPermissionGranted() async => isGranted;

  @override
  Future<bool> isPermanentlyDenied() async => isPermDenied;

  @override
  Future<bool> openSettings() async {
    openSettingsCalled = true;
    return true;
  }
}

// ignore: prefer_file_naming_conventions
class _DummyNotificationBloc extends Bloc<NotificationEvent, NotificationState>
    implements NotificationBloc {
  _DummyNotificationBloc() : super(const NotificationState()) {
    on<NotificationEvent>((event, emit) {});
  }
}

void main() {
  group('NotificationReminderScreen Widget Tests', () {
    testWidgets('renders initial UI with preview card and enterprise rules', (
      tester,
    ) async {
      final fakeService = _FakeNotificationPermissionService(isGranted: true);
      final sessionState = AppSessionState();
      final dummyBloc = _DummyNotificationBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotificationBloc>.value(
            value: dummyBloc,
            child: NotificationReminderScreen(
              permissionService: fakeService,
              sessionState: sessionState,
            ),
          ),
        ),
      );

      expect(
        find.text('Stay consistent with weekly scan reminders'),
        findsOneWidget,
      );
      expect(find.byType(NotificationPreviewCard), findsOneWidget);
      expect(find.byType(NotificationRuleInfoRow), findsNWidgets(3));
      expect(find.text('Confirm & Enable Reminders'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
      expect(find.text('Preferred Scan Day'), findsOneWidget);
      expect(find.text('Preferred Reminder Time'), findsOneWidget);
      expect(find.byType(EmptyStateView), findsNothing);
    });

    testWidgets(
      'tapping Enable Reminders requests permission and triggers onPermissionGranted',
      (tester) async {
        final fakeService = _FakeNotificationPermissionService(isGranted: true);
        final sessionState = AppSessionState();
        final dummyBloc = _DummyNotificationBloc();
        var grantedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<NotificationBloc>.value(
              value: dummyBloc,
              child: NotificationReminderScreen(
                permissionService: fakeService,
                sessionState: sessionState,
                onPermissionGranted: () => grantedCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(fakeService.requestCount, equals(1));
        expect(grantedCalled, isTrue);
        expect(sessionState.isOnboardingCompleted, isTrue);
      },
    );

    testWidgets('tapping Maybe Later triggers onSkip without error', (
      tester,
    ) async {
      final fakeService = _FakeNotificationPermissionService(isGranted: false);
      final sessionState = AppSessionState();
      final dummyBloc = _DummyNotificationBloc();
      var skipCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotificationBloc>.value(
            value: dummyBloc,
            child: NotificationReminderScreen(
              permissionService: fakeService,
              sessionState: sessionState,
              onSkip: () => skipCalled = true,
            ),
          ),
        ),
      );

      final skipFinder = find.text('Maybe Later');
      await tester.ensureVisible(skipFinder);
      await tester.tap(skipFinder);
      await tester.pump();

      expect(skipCalled, isTrue);
      expect(sessionState.isOnboardingCompleted, isTrue);
    });

    testWidgets(
      'shows EmptyStateView when permission denied and allows retry/settings',
      (tester) async {
        final fakeService = _FakeNotificationPermissionService(
          isGranted: false,
          isPermDenied: true,
        );
        final sessionState = AppSessionState();
        final dummyBloc = _DummyNotificationBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<NotificationBloc>.value(
              value: dummyBloc,
              child: NotificationReminderScreen(
                permissionService: fakeService,
                sessionState: sessionState,
              ),
            ),
          ),
        );

        // Tap Enable Reminders -> fails permanently
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.byType(EmptyStateView), findsOneWidget);
        expect(find.text('Notifications Disabled'), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);

        await tester.tap(find.text('Open Settings'));
        await tester.pump();

        expect(fakeService.openSettingsCalled, isTrue);
      },
    );
  });
}
