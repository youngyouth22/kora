import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/link_user_account_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_skin_profile_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_state.dart';

void main() {
  late OnboardingLocalDataSource localDataSource;
  late OnboardingRemoteDataSource remoteDataSource;
  late OnboardingRepositoryImpl repository;
  late TrackOnboardingStartedUseCase trackOnboardingStarted;
  late SaveDemographicsUseCase saveDemographics;
  late SaveQuizAnswersUseCase saveQuizAnswers;
  late CompleteOnboardingUseCase completeOnboarding;
  late SaveSkinProfileUseCase saveSkinProfile;
  late LinkUserAccountUseCase linkUserAccount;
  late OnboardingBloc bloc;

  setUp(() {
    localDataSource = OnboardingLocalDataSourceImpl();
    remoteDataSource = OnboardingRemoteDataSourceImpl();
    repository = OnboardingRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    trackOnboardingStarted = TrackOnboardingStartedUseCase(repository);
    saveDemographics = SaveDemographicsUseCase(repository);
    saveQuizAnswers = SaveQuizAnswersUseCase(repository);
    completeOnboarding = CompleteOnboardingUseCase(repository);
    saveSkinProfile = SaveSkinProfileUseCase(repository);
    linkUserAccount = LinkUserAccountUseCase(repository);

    bloc = OnboardingBloc(
      trackOnboardingStarted: trackOnboardingStarted,
      saveDemographics: saveDemographics,
      saveQuizAnswers: saveQuizAnswers,
      completeOnboarding: completeOnboarding,
      saveSkinProfile: saveSkinProfile,
      linkUserAccount: linkUserAccount,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is correct', () {
    expect(bloc.state.status, BaseStatus.initial);
    expect(bloc.state.demographicsStep, 0);
    expect(bloc.state.quizStep, 0);
    expect(bloc.state.quizAnswers, isEmpty);
    expect(bloc.state.isOnboardingCompleted, isFalse);
  });

  test('OnboardingStartedEvent emits [loading, success]', () async {
    final expectedStates = [
      predicate<OnboardingState>(
        (state) =>
            state.status == BaseStatus.loading &&
            state.lastTrackedSource == 'app_store',
      ),
      predicate<OnboardingState>((state) => state.status == BaseStatus.success),
    ];

    final streamExpectation = expectLater(
      bloc.stream,
      emitsInOrder(expectedStates),
    );

    bloc.add(const OnboardingStartedEvent(source: 'app_store'));
    await streamExpectation;
  });

  test('OnboardingGenderSelected updates gender in demographics', () async {
    bloc.add(const OnboardingGenderSelected('Female'));
    await pumpEventQueue();

    expect(bloc.state.demographics.gender, 'Female');
  });

  test('OnboardingAgeRangeSelected updates age range', () async {
    bloc.add(const OnboardingAgeRangeSelected('25–34'));
    await pumpEventQueue();

    expect(bloc.state.demographics.ageRange, '25–34');
  });

  test('OnboardingSensitiveSkinSelected updates sensitive skin flag', () async {
    bloc.add(const OnboardingSensitiveSkinSelected(true));
    await pumpEventQueue();

    expect(bloc.state.demographics.hasSensitiveSkin, isTrue);
  });

  test('OnboardingDemographicsStepChanged updates step index', () async {
    bloc.add(const OnboardingDemographicsStepChanged(2));
    await pumpEventQueue();

    expect(bloc.state.demographicsStep, 2);
  });

  test('OnboardingDemographicsSubmitted persists demographics', () async {
    bloc
      ..add(const OnboardingGenderSelected('Female'))
      ..add(const OnboardingAgeRangeSelected('25–34'))
      ..add(const OnboardingSensitiveSkinSelected(true));
    await pumpEventQueue();

    expect(bloc.state.isDemographicsComplete, isTrue);

    bloc.add(const OnboardingDemographicsSubmitted());
    await pumpEventQueue();

    expect(bloc.state.status, BaseStatus.success);
    final saved = await repository.getDemographics();
    expect(saved.isRight(), isTrue);
    saved.fold(
      (_) => fail('Should have saved'),
      (d) => expect(d?.gender, 'Female'),
    );
  });

  test('OnboardingQuestionAnswered updates quiz answer and progress', () async {
    bloc.add(
      const OnboardingQuestionAnswered(
        questionIndex: 0,
        answer: 'Clear blemishes',
      ),
    );
    await pumpEventQueue();

    expect(bloc.state.quizAnswers[0], 'Clear blemishes');
    expect(bloc.state.quizProgress, closeTo(1 / 6.0, 0.01));
  });

  test('OnboardingQuizStepChanged updates active quiz page', () async {
    bloc.add(const OnboardingQuizStepChanged(3));
    await pumpEventQueue();

    expect(bloc.state.quizStep, 3);
  });

  test(
    'OnboardingQuizSubmitted saves answers and completes onboarding',
    () async {
      for (var i = 0; i < 6; i++) {
        bloc.add(
          OnboardingQuestionAnswered(
            questionIndex: i,
            answer: 'Option $i',
          ),
        );
      }
      await pumpEventQueue();

      bloc.add(const OnboardingQuizSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, BaseStatus.success);
      expect(bloc.state.isOnboardingCompleted, isTrue);
      expect(bloc.state.skinProfile, isNotNull);

      final isCompleted = await repository.isOnboardingCompleted();
      expect(isCompleted.getOrElse(() => false), isTrue);
    },
  );

  test(
    'OnboardingLinkAccountRequested updates profile with authenticated user id',
    () async {
      bloc.add(const OnboardingLinkAccountRequested('usr_auth_linked_123'));
      await pumpEventQueue();

      expect(bloc.state.skinProfile?.userId, 'usr_auth_linked_123');
      expect(bloc.state.skinProfile?.isAnonymous, isFalse);
    },
  );

  test('OnboardingReset restores initial state', () async {
    bloc.add(const OnboardingGenderSelected('Male'));
    await pumpEventQueue();
    expect(bloc.state.demographics.gender, 'Male');

    bloc.add(const OnboardingReset());
    await pumpEventQueue();

    expect(bloc.state.demographics.gender, isNull);
    expect(bloc.state.status, BaseStatus.initial);
  });
}
