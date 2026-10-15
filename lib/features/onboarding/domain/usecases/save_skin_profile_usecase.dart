import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case to save the structured, language-agnostic user skin profile.
class SaveSkinProfileUseCase implements UseCase<void, UserSkinProfile> {
  /// Creates a [SaveSkinProfileUseCase].
  const SaveSkinProfileUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<void> call(UserSkinProfile params) {
    return _repository.saveSkinProfile(params);
  }
}
