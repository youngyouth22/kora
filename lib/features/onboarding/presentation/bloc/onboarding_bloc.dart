// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/link_user_account_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_skin_profile_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_state.dart';

/// BLoC coordinating the onboarding user journey and data persistence.
///
/// Pure orchestrator adhering to Kora Rules Article 2: zero direct business
/// logic or UI dependencies.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// Creates an [OnboardingBloc] with required usecases.
  OnboardingBloc({
    required TrackOnboardingStartedUseCase trackOnboardingStarted,
    required SaveDemographicsUseCase saveDemographics,
    required SaveQuizAnswersUseCase saveQuizAnswers,
    required CompleteOnboardingUseCase completeOnboarding,
    SaveSkinProfileUseCase? saveSkinProfile,
    LinkUserAccountUseCase? linkUserAccount,
  }) : _trackOnboardingStarted = trackOnboardingStarted,
       _saveDemographics = saveDemographics,
       _saveQuizAnswers = saveQuizAnswers,
       _completeOnboarding = completeOnboarding,
       _saveSkinProfile = saveSkinProfile,
       _linkUserAccount = linkUserAccount,
       super(const OnboardingState()) {
    on<OnboardingStartedEvent>(_onStarted);
    on<OnboardingGenderSelected>(_onGenderSelected);
    on<OnboardingAgeRangeSelected>(_onAgeRangeSelected);
    on<OnboardingSensitiveSkinSelected>(_onSensitiveSkinSelected);
    on<OnboardingDemographicsStepChanged>(_onDemographicsStepChanged);
    on<OnboardingDemographicsSubmitted>(_onDemographicsSubmitted);
    on<OnboardingQuestionAnswered>(_onQuestionAnswered);
    on<OnboardingQuizStepChanged>(_onQuizStepChanged);
    on<OnboardingQuizSubmitted>(_onQuizSubmitted);
    on<OnboardingLinkAccountRequested>(_onLinkAccountRequested);
    on<OnboardingReset>(_onReset);
  }

  final TrackOnboardingStartedUseCase _trackOnboardingStarted;
  final SaveDemographicsUseCase _saveDemographics;
  final SaveQuizAnswersUseCase _saveQuizAnswers;
  final CompleteOnboardingUseCase _completeOnboarding;
  final SaveSkinProfileUseCase? _saveSkinProfile;
  final LinkUserAccountUseCase? _linkUserAccount;

  Future<void> _onStarted(
    OnboardingStartedEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BaseStatus.loading,
        lastTrackedSource: event.source,
      ),
    );

    final result = await _trackOnboardingStarted(
      TrackOnboardingStartedParams(
        source: event.source,
        metadata: event.metadata,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: BaseStatus.success,
        ),
      ),
    );
  }

  void _onGenderSelected(
    OnboardingGenderSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        demographics: state.demographics.copyWith(gender: event.gender),
      ),
    );
  }

  void _onAgeRangeSelected(
    OnboardingAgeRangeSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        demographics: state.demographics.copyWith(ageRange: event.ageRange),
      ),
    );
  }

  void _onSensitiveSkinSelected(
    OnboardingSensitiveSkinSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      state.copyWith(
        demographics: state.demographics.copyWith(
          hasSensitiveSkin: event.hasSensitiveSkin,
        ),
      ),
    );
  }

  void _onDemographicsStepChanged(
    OnboardingDemographicsStepChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(demographicsStep: event.stepIndex));
  }

  Future<void> _onDemographicsSubmitted(
    OnboardingDemographicsSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final result = await _saveDemographics(state.demographics);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: BaseStatus.success,
        ),
      ),
    );
  }

  void _onQuestionAnswered(
    OnboardingQuestionAnswered event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedAnswers = Map<int, String>.from(state.quizAnswers)
      ..[event.questionIndex] = event.answer;

    emit(state.copyWith(quizAnswers: updatedAnswers));
  }

  void _onQuizStepChanged(
    OnboardingQuizStepChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(quizStep: event.stepIndex));
  }

  Future<void> _onQuizSubmitted(
    OnboardingQuizSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final saveResult = await _saveQuizAnswers(state.quizAnswers);

    await saveResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BaseStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        final profileModel = UserSkinProfileModel.fromQuizAnswers(
          answers: state.quizAnswers,
          demographics: state.demographics,
        );

        if (_saveSkinProfile != null) {
          await _saveSkinProfile(profileModel);
        }

        final completeResult = await _completeOnboarding(const NoParams());
        completeResult.fold(
          (failure) => emit(
            state.copyWith(
              status: BaseStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (_) => emit(
            state.copyWith(
              status: BaseStatus.success,
              skinProfile: profileModel.toEntity(),
              isOnboardingCompleted: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLinkAccountRequested(
    OnboardingLinkAccountRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (_linkUserAccount != null) {
      final result = await _linkUserAccount(event.userId);
      result.fold(
        (_) => null,
        (_) {
          final now = DateTime.now();
          final current =
              state.skinProfile ??
              UserSkinProfile(
                demographics: state.demographics,
                isAnonymous: false,
                userId: event.userId,
                createdAt: now,
                updatedAt: now,
              );
          emit(
            state.copyWith(
              skinProfile: current.copyWith(
                userId: event.userId,
                isAnonymous: false,
                updatedAt: now,
              ),
            ),
          );
        },
      );
    }
  }

  void _onReset(
    OnboardingReset event,
    Emitter<OnboardingState> emit,
  ) {
    emit(const OnboardingState());
  }
}
