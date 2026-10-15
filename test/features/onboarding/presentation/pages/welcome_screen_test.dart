import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_curve_visual.dart';

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

  testWidgets('renders WelcomeScreen elements matching requirements', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // 1. Title <= 8 words: "Find out if your routine really works" (7 words)
    const expectedTitle = 'Find out if your routine really works';
    expect(find.text(expectedTitle), findsOneWidget);
    final wordCount = expectedTitle.split(' ').length;
    expect(wordCount <= 8, isTrue);

    // 2. Visual: curve + skin tone representations
    expect(find.byType(OnboardingCurveVisual), findsOneWidget);

    // 3. 3 reassurance points: Private · Science-based · No jargon
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Science-based'), findsOneWidget);
    expect(find.text('No jargon'), findsOneWidget);

    // 4. Single primary CTA "Get started"
    expect(find.text('Get started'), findsOneWidget);

    // 5. Secondary link "I already have an account"
    expect(find.text('I already have an account'), findsOneWidget);

    // 6. Prohibited words check: no "diagnostic", "treatment", "cure"
    expect(find.textContaining('diagnostic', findRichText: true), findsNothing);
    expect(find.textContaining('treatment', findRichText: true), findsNothing);
    expect(find.textContaining('cure', findRichText: true), findsNothing);
  });

  testWidgets('tapping Get started navigates to mascot screen', (tester) async {
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

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Mascot Screen'), findsOneWidget);
  });
}
