import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/core.dart';
import 'package:kora/features/coach/presentation/pages/coach_page.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';
import 'package:kora/features/experiment/presentation/pages/experiment_detail_page.dart';
import 'package:kora/features/experiment/presentation/pages/experiment_verdict_page.dart';
import 'package:kora/features/guided_capture/presentation/pages/guided_capture_page.dart';
import 'package:kora/features/home/presentation/pages/home_page.dart';
import 'package:kora/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:kora/features/profile/presentation/pages/profile_page.dart';
import 'package:kora/features/profile/presentation/pages/subscription_page.dart';
import 'package:kora/features/progress/presentation/pages/compare_scans_page.dart';
import 'package:kora/features/progress/presentation/pages/concern_detail_page.dart';
import 'package:kora/features/progress/presentation/pages/progress_page.dart';
import 'package:kora/features/routine/presentation/pages/add_product_page.dart';
import 'package:kora/features/routine/presentation/pages/ingredient_analysis_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_catalog_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_checkin_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_product_detail_page.dart';
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
          find.textContaining("Track your skin's evolution"),
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

        expect(find.byType(HomePage), findsOneWidget);

        // Tap on Routine Tab
        await tester.tap(find.text('Routine'));
        await tester.pumpAndSettle();

        expect(find.byType(RoutinePage), findsOneWidget);

        // Tap on Progress Tab
        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();

        expect(find.byType(ProgressPage), findsOneWidget);

        // Tap on Me Tab
        await tester.tap(find.text('Me'));
        await tester.pumpAndSettle();

        expect(find.byType(ProfilePage), findsOneWidget);

        // Return to Home Tab
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);

        // Tap Mascot FAB to open Coach Hub bottom sheet
        await tester.tap(
          find.bySemanticsLabel('Open AI Skincare Companion Chat'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CoachBottomSheetContent), findsOneWidget);

        // Tap New Chat FAB to navigate to chat conversation in PageView
        await tester.tap(find.text('New Chat'));
        await tester.pumpAndSettle();

        expect(find.text('Write your question...'), findsOneWidget);

        // Close bottom sheet
        await tester.tap(find.bySemanticsLabel('Close chat'));
        await tester.pumpAndSettle();

        // Verify direct GoRouter navigation to CoachPage
        router.router.go(AppRoutes.coach);
        await tester.pumpAndSettle();

        expect(find.byType(CoachPage), findsOneWidget);
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

      expect(find.byType(HomePage), findsOneWidget);
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

    testWidgets(
      'profile subroutes hide bottom navigation bar and render full screen',
      (tester) async {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
        );
        final router = AppRouter(sessionState: session);

        await tester.pumpWidget(MainApp(appRouter: router));
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Me'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfilePage), findsOneWidget);

        // Tap on Subscription
        await tester.ensureVisible(find.text('Subscription'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Subscription'));
        await tester.pumpAndSettle();

        expect(find.byType(SubscriptionPage), findsOneWidget);

        // Pop back to Profile
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(ProfilePage), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(ProfilePage),
            matching: find.text('Me'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'routine subroutes hide bottom navigation bar and render full screen',
      (tester) async {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
        );
        final router = AppRouter(sessionState: session);

        await tester.pumpWidget(MainApp(appRouter: router));
        await tester.pumpAndSettle();

        // Navigate to Routine tab
        await tester.tap(find.text('Routine'));
        await tester.pumpAndSettle();
        expect(find.byType(RoutinePage), findsOneWidget);

        // Navigate to Routine Check-in subroute
        unawaited(router.router.push(AppRoutes.routineCheckin));
        await tester.pumpAndSettle();
        expect(find.byType(RoutineCheckinPage), findsOneWidget);
        // Bottom navigation bar should not be visible on full-screen subroute
        expect(find.byType(KoraShellScaffold), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(RoutinePage), findsOneWidget);

        // Navigate to Routine Catalog subroute
        unawaited(router.router.push(AppRoutes.routineCatalog));
        await tester.pumpAndSettle();
        expect(find.byType(RoutineCatalogPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();

        // Navigate to Routine Product Detail subroute
        unawaited(
          router.router.push(
            AppRoutes.buildRoutineProductDetailPath('item-cerave-cleanser'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(RoutineProductDetailPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();

        // Navigate to Add Product subroute
        unawaited(router.router.push(AppRoutes.routineAdd));
        await tester.pumpAndSettle();
        expect(find.byType(AddProductPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();

        // Navigate to Ingredient Analysis subroute
        unawaited(
          router.router.push(
            AppRoutes.buildRoutineIngredientsPath('item-ordinary-retinol'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(IngredientAnalysisPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);
      },
    );

    testWidgets(
      'progress subroutes hide bottom navigation bar and render full screen',
      (tester) async {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
        );
        final router = AppRouter(sessionState: session);

        await tester.pumpWidget(MainApp(appRouter: router));
        await tester.pumpAndSettle();

        // Navigate to Progress tab
        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();
        expect(find.byType(ProgressPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsOneWidget);

        // Navigate to Concern Detail subroute
        unawaited(
          router.router.push(AppRoutes.buildProgressConcernPath('age_spot')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ConcernDetailPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(ProgressPage), findsOneWidget);

        // Navigate to Compare Scans subroute
        unawaited(
          router.router.push(AppRoutes.buildComparePath('scan_1', 'scan_8')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CompareScansPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);

        await tester.pageBack();
        await tester.pumpAndSettle();

        // Navigate to Experiment Detail subroute
        unawaited(
          router.router.push(
            AppRoutes.buildExperimentPath('exp-retinol-demo'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ExperimentDetailPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);

        // Navigate to Experiment Verdict subroute
        unawaited(
          router.router.push(
            AppRoutes.buildExperimentVerdictPath('exp-retinol-demo'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ExperimentVerdictPage), findsOneWidget);
        expect(find.byType(KoraShellScaffold), findsNothing);
      },
    );
  });
}
