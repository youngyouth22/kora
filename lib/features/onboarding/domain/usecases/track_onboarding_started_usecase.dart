import 'package:equatable/equatable.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Parameters for tracking the `onboarding_started` event.
class TrackOnboardingStartedParams extends Equatable {
  /// Creates a [TrackOnboardingStartedParams].
  const TrackOnboardingStartedParams({
    required this.source,
    this.metadata,
  });

  /// Traffic or store attribution source (e.g. 'organic', 'utm_google',
  /// 'app_store').
  final String source;

  /// Optional contextual metadata (campaign, medium, device locale).
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [source, metadata];
}

/// Use case that logs the `onboarding_started` event with attribution metadata.
class TrackOnboardingStartedUseCase
    implements UseCase<void, TrackOnboardingStartedParams> {
  /// Creates the use case.
  const TrackOnboardingStartedUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<void> call(TrackOnboardingStartedParams params) {
    return _repository.trackOnboardingStarted(
      source: params.source,
      metadata: params.metadata,
    );
  }
}
