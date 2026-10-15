// ignore_for_file: document_ignores, public_member_api_docs
// ignore_for_file: avoid_positional_boolean_parameters, comment_references

import 'package:equatable/equatable.dart';

/// Base abstract event for [OnboardingBloc].
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the onboarding flow starts on WelcomeScreen.
class OnboardingStartedEvent extends OnboardingEvent {
  const OnboardingStartedEvent({
    required this.source,
    this.metadata,
  });

  /// Attribution source (e.g. 'organic', 'utm_google', 'app_store').
  final String source;

  /// Optional contextual attribution properties.
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [source, metadata];
}

/// Dispatched when the user selects a gender.
class OnboardingGenderSelected extends OnboardingEvent {
  const OnboardingGenderSelected(this.gender);

  final String gender;

  @override
  List<Object?> get props => [gender];
}

/// Dispatched when the user selects an age range.
class OnboardingAgeRangeSelected extends OnboardingEvent {
  const OnboardingAgeRangeSelected(this.ageRange);

  final String ageRange;

  @override
  List<Object?> get props => [ageRange];
}

/// Dispatched when the user selects whether they have sensitive skin.
class OnboardingSensitiveSkinSelected extends OnboardingEvent {
  const OnboardingSensitiveSkinSelected(this.hasSensitiveSkin);

  final bool hasSensitiveSkin;

  @override
  List<Object?> get props => [hasSensitiveSkin];
}

/// Dispatched when changing page within the 3-step demographics PageView.
class OnboardingDemographicsStepChanged extends OnboardingEvent {
  const OnboardingDemographicsStepChanged(this.stepIndex);

  final int stepIndex;

  @override
  List<Object?> get props => [stepIndex];
}

/// Dispatched when submitting demographics after step 3.
class OnboardingDemographicsSubmitted extends OnboardingEvent {
  const OnboardingDemographicsSubmitted();
}

/// Dispatched when answering a question in the 6-question quiz.
class OnboardingQuestionAnswered extends OnboardingEvent {
  const OnboardingQuestionAnswered({
    required this.questionIndex,
    required this.answer,
  });

  /// 0-indexed question index (0 to 5).
  final int questionIndex;

  /// Selected option text or identifier.
  final String answer;

  @override
  List<Object?> get props => [questionIndex, answer];
}

/// Dispatched when changing page within the 6-question quiz PageView.
class OnboardingQuizStepChanged extends OnboardingEvent {
  const OnboardingQuizStepChanged(this.stepIndex);

  final int stepIndex;

  @override
  List<Object?> get props => [stepIndex];
}

/// Dispatched when submitting the completed 6-question quiz.
class OnboardingQuizSubmitted extends OnboardingEvent {
  const OnboardingQuizSubmitted();
}

/// Dispatched to link an anonymous guest profile to an authenticated
/// account user.
class OnboardingLinkAccountRequested extends OnboardingEvent {
  const OnboardingLinkAccountRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Dispatched to reset the onboarding state back to initial.
class OnboardingReset extends OnboardingEvent {
  const OnboardingReset();
}
