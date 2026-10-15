import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case that persists user demographic selections.
class SaveDemographicsUseCase implements UseCase<void, UserDemographics> {
  /// Creates the use case.
  const SaveDemographicsUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<void> call(UserDemographics params) {
    return _repository.saveDemographics(params);
  }
}
