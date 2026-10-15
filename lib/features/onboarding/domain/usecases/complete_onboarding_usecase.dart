import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case that marks onboarding completion.
class CompleteOnboardingUseCase implements UseCase<void, NoParams> {
  /// Creates the use case.
  const CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<void> call(NoParams params) {
    return _repository.completeOnboarding();
  }
}
