import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';

/// Skips account linking, scheduling D+3 and D+7 reminders.
class SkipAccountLinkingUseCase implements UseCase<void, NoParams> {
  /// Creates a [SkipAccountLinkingUseCase].
  const SkipAccountLinkingUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.skipAccountLinking();
  }
}
