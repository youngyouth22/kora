import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/core.dart';
import 'package:kora/features/guided_capture/presentation/pages/guided_capture_page.dart';
import 'package:kora/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:kora/features/splash/presentation/pages/splash_screen.dart';
import 'package:kora/main.dart';

void main() {
  group('AppRouter Widget and Navigation Tests', () {
    testWidgets(
      'pumps MainApp, displays splash, and transitions to onboarding welcome',
      (tester) async {
        final session = AppSessionState();
        final router = AppRouter(sessionState: session);

        await tester.pumpWidget(MainApp(appRouter: router));
        expect(find.byType(SplashScreen), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(
          find.text('Find out if your routine really works'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'transitions to home and allows tab navigation when onboarding completed',
      (tester) async {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
        );
        final router = AppRouter(sessionState: session);

        await tester.pumpWidget(MainApp(appRouter: router));
        await tester.pumpAndSettle();

        expect(find.text('Home Dashboard'), findsOneWidget);

        // Tap on Routine Tab
        await tester.tap(find.text('Routine'));
        await tester.pumpAndSettle();

        expect(find.text('Skincare Routine'), findsOneWidget);
        expect(find.text('/routine'), findsOneWidget);

        // Tap on Coach Tab
        await tester.tap(find.text('Coach'));
        await tester.pumpAndSettle();

        expect(find.text('AI Skin Coach'), findsOneWidget);
        expect(find.text('/coach'), findsOneWidget);

        // Tap on Progress Tab
        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();

        expect(find.text('Skin Progress'), findsOneWidget);
        expect(find.text('/progress'), findsOneWidget);

        // Tap on Profile Tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        expect(find.text('My Profile'), findsOneWidget);
        expect(find.text('/profile'), findsOneWidget);
      },
    );

    testWidgets('displays RouteErrorScreen for unhandled routes', (
      tester,
    ) async {
      final session = AppSessionState(
        isInitialized: true,
        isOnboardingCompleted: true,
      );
      final router = AppRouter(sessionState: session);

      await tester.pumpWidget(MainApp(appRouter: router));
      await tester.pumpAndSettle();

      // Trigger navigation to unknown route
      router.router.go('/some/unknown/route');
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorScreen), findsOneWidget);
      expect(find.text('Page Not Found'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // Tap Back to Home
      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      expect(find.text('Home Dashboard'), findsOneWidget);
    });

    testWidgets('renders parameter values on dynamic routes', (tester) async {
      final session = AppSessionState(
        isInitialized: true,
        isOnboardingCompleted: true,
      );
      final router = AppRouter(sessionState: session);

      await tester.pumpWidget(MainApp(appRouter: router));
      await tester.pumpAndSettle();

      router.router.go(AppRoutes.buildScanResultPath('scan-abc-123'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Result'), findsOneWidget);
      expect(find.text('id: '), findsOneWidget);
      expect(find.text('scan-abc-123'), findsOneWidget);
    });

    testWidgets('navigates to guided capture screen at /scan/capture', (
      tester,
    ) async {
      final session = AppSessionState(
        isInitialized: true,
        isOnboardingCompleted: true,
      );
      final router = AppRouter(sessionState: session);

      await tester.pumpWidget(MainApp(appRouter: router));
      await tester.pumpAndSettle();

      router.router.go(AppRoutes.scanCapture);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GuidedCapturePage), findsOneWidget);
    });
  });
}
