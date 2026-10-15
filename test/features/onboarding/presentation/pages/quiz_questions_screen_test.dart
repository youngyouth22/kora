import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/app_constants.dart';
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
import 'package:kora/features/onboarding/presentation/pages/quiz_questions_screen.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';

void main() {
  group('QuizQuestionsScreen Widget Tests', () {
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

    Widget buildApp(Widget home) {
      return BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          home: home,
        ),
      );
    }

    testWidgets(
      'renders mascot with Hero on step 0 and initial quiz questionnaire UI',
      (tester) async {
        await tester.pumpWidget(buildApp(const QuizQuestionsScreen()));
        await tester.pumpAndSettle();

        // Verify top progress bar in AppBar
        expect(find.byType(OnboardingProgressBar), findsOneWidget);
        expect(find.text('1 of 6'), findsOneWidget);
        expect(find.text('Personalizing Your Plan'), findsOneWidget);

        // Verify question 0 title and options
        expect(find.text('What is your skin tone?'), findsOneWidget);
        expect(find.text('Very Fair'), findsOneWidget);
        expect(find.text('Fair'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('Olive'), findsOneWidget);
        expect(find.text('Brown'), findsOneWidget);
        expect(find.text('Dark Brown'), findsOneWidget);

        // Verify Hero mascot configuration on step 0
        final heroFinder = find.byType(Hero);
        expect(heroFinder, findsOneWidget);

        final heroWidget = tester.widget<Hero>(heroFinder);
        expect(heroWidget.tag, AppConstants.mascotHeroTag);
        expect(heroWidget.flightShuttleBuilder, isNotNull);

        // Verify CTA Next button initially disabled
        final nextBtnFinder = find.byType(PrimaryButton);
        expect(nextBtnFinder, findsOneWidget);
        final btn = tester.widget<PrimaryButton>(nextBtnFinder);
        expect(btn.isDisabled, isTrue);
        expect(btn.onPressed, isNull);
      },
    );

    testWidgets(
      'notifies sessionState and sets intendedDestination to scanCapture '
      'when onboarding completes',
      (tester) async {
        final sessionState = AppSessionState(isInitialized: true);

        await tester.pumpWidget(
          BlocProvider.value(
            value: bloc,
            child: MaterialApp(
              home: QuizQuestionsScreen(sessionState: sessionState),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Emit onboarding completed state directly via bloc
        bloc.emit(bloc.state.copyWith(isOnboardingCompleted: true));
        await tester.pump();

        expect(sessionState.isOnboardingCompleted, isTrue);
        expect(sessionState.intendedDestination, AppRoutes.scanCapture);
      },
    );
  });
}
