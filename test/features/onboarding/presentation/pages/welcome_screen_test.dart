import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:kora/features/onboarding/presentation/widgets/animated_product_experiment_card.dart';
import 'package:kora/features/onboarding/presentation/widgets/animated_scan_stack.dart';
import 'package:kora/features/onboarding/presentation/widgets/animated_social_proof_card.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';

void main() {
  late OnboardingBloc bloc;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    repository = OnboardingRepositoryImpl(
      localDataSource: OnboardingLocalDataSourceImpl(),
      remoteDataSource: OnboardingRemoteDataSourceImpl(),
    );

    bloc = OnboardingBloc(
      trackOnboardingStarted: TrackOnboardingStartedUseCase(repository),
      saveDemographics: SaveDemographicsUseCase(repository),
      saveQuizAnswers: SaveQuizAnswersUseCase(repository),
      completeOnboarding: CompleteOnboardingUseCase(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  Widget buildTestWidget({GoRouter? router}) {
    if (router != null) {
      return BlocProvider.value(
        value: bloc,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    return BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
        home: WelcomeScreen(source: 'test_store'),
      ),
    );
  }

  testWidgets('renders Step 1 with scan stacking visual, indicators, and CTA', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // 1. Skip button
    expect(find.text('Skip'), findsOneWidget);

    // 2. Step 1 content
    expect(
      find.text("Track your skin's evolution\nwithout the guesswork"),
      findsOneWidget,
    );
    expect(find.byType(AnimatedScanStack), findsOneWidget);

    // 3. Indicator present
    expect(find.byType(OnboardingStepIndicator), findsWidgets);

    // 4. Primary CTA "Continue" on Step 1
    expect(find.text('Continue'), findsOneWidget);

    // 5. Secondary link
    expect(find.text('I already have an account'), findsOneWidget);

    // 6. Prohibited words check: no "diagnostic", "treatment", "cure"
    expect(find.textContaining('diagnostic', findRichText: true), findsNothing);
    expect(find.textContaining('treatment', findRichText: true), findsNothing);
    expect(find.textContaining('cure', findRichText: true), findsNothing);
  });

  testWidgets('tapping Continue steps through Step 2 and Step 3', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // On Step 1 initially
    expect(
      find.text("Track your skin's evolution\nwithout the guesswork"),
      findsOneWidget,
    );
    expect(find.byType(AnimatedScanStack), findsOneWidget);

    // Tap Continue -> advances to Step 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('Test skincare products\nwith real AI verdicts'),
      findsOneWidget,
    );
    expect(find.byType(AnimatedProductExperimentCard), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap Continue -> advances to Step 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('Achieve consistent results\nbacked by real science'),
      findsOneWidget,
    );
    expect(find.byType(AnimatedSocialProofCard), findsOneWidget);
    // On Step 3, CTA changes to "Get started"
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('tapping Get started on Step 3 navigates to mascot screen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding/mascot',
          builder: (context, state) =>
              const Scaffold(body: Text('Mascot Screen')),
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(router: router));
    await tester.pumpAndSettle();

    // Move to step 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Move to step 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Tap "Get started"
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Mascot Screen'), findsOneWidget);
  });

  testWidgets('tapping Skip on Step 1 navigates directly to mascot screen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding/mascot',
          builder: (context, state) =>
              const Scaffold(body: Text('Mascot Screen')),
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Mascot Screen'), findsOneWidget);
  });

  testWidgets(
    'tapping I already have an account navigates to account secure page',
    (tester) async {
      final sessionState = AppSessionState();
      final router = GoRouter(
        initialLocation: '/welcome',
        routes: [
          GoRoute(
            path: '/welcome',
            builder: (context, state) => WelcomeScreen(
              sessionState: sessionState,
            ),
          ),
          GoRoute(
            path: AppRoutes.accountSecure,
            builder: (context, state) =>
                const Scaffold(body: Text('Account Secure Screen')),
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(router: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();

      expect(sessionState.intendedDestination, equals(AppRoutes.home));
      expect(find.text('Account Secure Screen'), findsOneWidget);
    },
  );
}
