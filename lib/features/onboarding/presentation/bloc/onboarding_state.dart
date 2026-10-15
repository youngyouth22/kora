// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

/// State representation for the onboarding flow.
///
/// Follows Kora Rules Article 2: strictly uses [BaseStatus] rather than
/// loose nullable booleans.
class OnboardingState extends Equatable {
  /// Creates an [OnboardingState].
  const OnboardingState({
    this.status = BaseStatus.initial,
    this.demographics = const UserDemographics(),
    this.demographicsStep = 0,
    this.quizAnswers = const {},
    this.quizStep = 0,
    this.skinProfile,
    this.isOnboardingCompleted = false,
    this.errorMessage,
    this.lastTrackedSource,
  });

  /// Status of async usecase executions (initial, loading, success, failure).
  final BaseStatus status;

  /// Collected user demographic responses.
  final UserDemographics demographics;

  /// Active page in the demographics 3-step PageView (0 = Gender, 1 = Age, 2 = Sensitive Skin).
  final int demographicsStep;

  /// Collected answers for the 6 onboarding questions (map of questionIndex -> answer).
  final Map<int, String> quizAnswers;

  /// Active page in the final 6-step quiz PageView (0 to 5).
  final int quizStep;

  /// Strongly-typed, normalized user skin profile for recommendation algorithms.
  final UserSkinProfile? skinProfile;

  /// Whether the complete onboarding sequence has finished.
  final bool isOnboardingCompleted;

  /// Error message when status is [BaseStatus.failure].
  final String? errorMessage;

  /// Attribution source captured on start.
  final String? lastTrackedSource;

  /// Progress fraction for the 6-question quiz (0.0 to 1.0).
  double get quizProgress => (quizAnswers.length / 6.0).clamp(0.0, 1.0);

  /// Whether all 3 demographic questions have been answered.
  bool get isDemographicsComplete => demographics.isComplete;

  /// Checks if the current demographic step has a valid selection.
  bool get canProceedDemographicsStep {
    switch (demographicsStep) {
      case 0:
        return demographics.gender != null && demographics.gender!.isNotEmpty;
      case 1:
        return demographics.ageRange != null &&
            demographics.ageRange!.isNotEmpty;
      case 2:
        return demographics.hasSensitiveSkin != null;
      default:
        return false;
    }
  }

  /// Checks if current quiz question has an answer recorded.
  bool get canProceedQuizStep =>
      quizAnswers.containsKey(quizStep) &&
      (quizAnswers[quizStep]?.trim().isNotEmpty ?? false);

  /// Creates a copy of the current state with specified modifications.
  OnboardingState copyWith({
    BaseStatus? status,
    UserDemographics? demographics,
    int? demographicsStep,
    Map<int, String>? quizAnswers,
    int? quizStep,
    UserSkinProfile? skinProfile,
    bool? isOnboardingCompleted,
    String? errorMessage,
    String? lastTrackedSource,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      demographics: demographics ?? this.demographics,
      demographicsStep: demographicsStep ?? this.demographicsStep,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      quizStep: quizStep ?? this.quizStep,
      skinProfile: skinProfile ?? this.skinProfile,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      errorMessage: errorMessage ?? this.errorMessage,
      lastTrackedSource: lastTrackedSource ?? this.lastTrackedSource,
    );
  }

  @override
  List<Object?> get props => [
    status,
    demographics,
    demographicsStep,
    quizAnswers,
    quizStep,
    skinProfile,
    isOnboardingCompleted,
    errorMessage,
    lastTrackedSource,
  ];
}
