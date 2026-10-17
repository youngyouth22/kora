import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/camera_permission_service.dart';
import 'package:kora/features/onboarding/presentation/pages/camera_permission_screen.dart';

class _FakeCameraPermissionService implements CameraPermissionService {
  _FakeCameraPermissionService({
    required this.isGranted,
    this.isPermDenied = false,
  });

  bool isGranted;
  bool isPermDenied;
  int requestCount = 0;
  bool openSettingsCalled = false;

  @override
  Future<bool> requestCameraPermission() async {
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

void main() {
  group('CameraPermissionScreen Widget Tests', () {
    testWidgets('renders initial informative pre-permission UI', (
      tester,
    ) async {
      final fakeService = _FakeCameraPermissionService(isGranted: true);
      final sessionState = AppSessionState();

      await tester.pumpWidget(
        MaterialApp(
          home: CameraPermissionScreen(
            permissionService: fakeService,
            sessionState: sessionState,
          ),
        ),
      );

      expect(find.text('Enable Camera Access'), findsOneWidget);
      expect(
        find.text(
          'To analyze your skin and guide your posture in real time, '
          'Kora needs access to your front camera.',
        ),
        findsOneWidget,
      );
      expect(find.text('Live Face Alignment'), findsOneWidget);
      expect(find.text('Private & Secure'), findsOneWidget);
      expect(find.text('Enable Camera'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
      expect(find.byType(EmptyStateView), findsNothing);
    });

    testWidgets(
      'navigates when permission is granted and marks onboarding complete',
      (tester) async {
        final fakeService = _FakeCameraPermissionService(isGranted: true);
        final sessionState = AppSessionState();
        var grantedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: CameraPermissionScreen(
              permissionService: fakeService,
              sessionState: sessionState,
              onPermissionGranted: () => grantedCalled = true,
            ),
          ),
        );

        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(fakeService.requestCount, equals(1));
        expect(grantedCalled, isTrue);
        expect(sessionState.isOnboardingCompleted, isTrue);
        expect(find.byType(EmptyStateView), findsNothing);
      },
    );

    testWidgets(
      'switches to EmptyStateView when permission is transiently denied '
      'and allows retry',
      (tester) async {
        final fakeService = _FakeCameraPermissionService(isGranted: false);
        final sessionState = AppSessionState();
        var grantedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: CameraPermissionScreen(
              permissionService: fakeService,
              sessionState: sessionState,
              onPermissionGranted: () => grantedCalled = true,
            ),
          ),
        );

        // Tap Enable Camera -> fails
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(fakeService.requestCount, equals(1));
        expect(grantedCalled, isFalse);
        expect(find.byType(EmptyStateView), findsOneWidget);
        expect(find.text('Camera Access Denied'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Continue to Home'), findsOneWidget);

        // Retry with granted = true
        fakeService.isGranted = true;
        await tester.tap(find.text('Try Again'));
        await tester.pump();

        expect(fakeService.requestCount, equals(2));
        expect(grantedCalled, isTrue);
      },
    );

    testWidgets(
      'shows Open Settings and calls openSettings when permanently denied',
      (tester) async {
        final fakeService = _FakeCameraPermissionService(
          isGranted: false,
          isPermDenied: true,
        );
        final sessionState = AppSessionState();

        await tester.pumpWidget(
          MaterialApp(
            home: CameraPermissionScreen(
              permissionService: fakeService,
              sessionState: sessionState,
            ),
          ),
        );

        // Tap Enable Camera -> permanently denied
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Camera Permission Required'), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);

        await tester.tap(find.text('Open Settings'));
        await tester.pump();

        expect(fakeService.openSettingsCalled, isTrue);
      },
    );

    testWidgets(
      'automatically navigates on AppLifecycleState.resumed if permission '
      'granted in settings',
      (tester) async {
        final fakeService = _FakeCameraPermissionService(isGranted: false);
        final sessionState = AppSessionState();
        var grantedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: CameraPermissionScreen(
              permissionService: fakeService,
              sessionState: sessionState,
              onPermissionGranted: () => grantedCalled = true,
            ),
          ),
        );

        // Deny first
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();
        expect(find.byType(EmptyStateView), findsOneWidget);

        // User goes to settings, enables permission, and returns
        fakeService.isGranted = true;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        expect(grantedCalled, isTrue);
        expect(sessionState.isOnboardingCompleted, isTrue);
      },
    );

    testWidgets('calls onSkip and marks onboarding completed on skip tap', (
      tester,
    ) async {
      final fakeService = _FakeCameraPermissionService(isGranted: false);
      final sessionState = AppSessionState();
      var skipCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CameraPermissionScreen(
            permissionService: fakeService,
            sessionState: sessionState,
            onSkip: () => skipCalled = true,
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
  });
}
