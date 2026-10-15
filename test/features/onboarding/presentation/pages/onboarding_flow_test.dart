import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/app_constants.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/pages/demographics_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/disclaimer_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/mascot_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/quiz_questions_screen.dart';

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

  Widget buildApp(Widget home) {
    return BlocProvider.value(
      value: bloc,
      child: MaterialApp(
        home: home,
      ),
    );
  }

  testWidgets('MascotScreen renders intro, Next CTA and mascot Hero', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const MascotScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Kora'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, AppConstants.mascotHeroTag);
  });

  testWidgets(
    'DemographicsScreen renders gender step, options and mascot Hero',
    (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const DemographicsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('What is your gender identity?'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      final btn = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(btn.isDisabled, isTrue);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, AppConstants.mascotHeroTag);
    },
  );

  testWidgets('DisclaimerScreen renders non-medical advisory and CTA', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const DisclaimerScreen()));
    await tester.pumpAndSettle();

    expect(find.text("Let's start!"), findsOneWidget);
    expect(
      find.textContaining('Great Start', findRichText: true),
      findsOneWidget,
    );
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, AppConstants.mascotHeroTag);
  });

  testWidgets('QuizQuestionsScreen renders 6 questions and progress bar', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const QuizQuestionsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('1 of 6'), findsOneWidget);
    expect(find.text('What is your skin tone?'), findsOneWidget);
    expect(find.text('Very Fair'), findsOneWidget);
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, AppConstants.mascotHeroTag);
  });
}
