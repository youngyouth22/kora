import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case that links an existing anonymous guest profile to a newly
/// authenticated account.
class LinkUserAccountUseCase implements UseCase<void, String> {
  /// Creates a [LinkUserAccountUseCase].
  const LinkUserAccountUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<void> call(String userId) {
    return _repository.linkProfileToUser(userId: userId);
  }
}
