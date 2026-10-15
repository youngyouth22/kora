import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case to retrieve the user's saved skin profile (guest or authenticated).
class GetSkinProfileUseCase implements UseCase<UserSkinProfile?, NoParams> {
  /// Creates a [GetSkinProfileUseCase].
  const GetSkinProfileUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<UserSkinProfile?> call(NoParams params) {
    return _repository.getSkinProfile();
  }
}
