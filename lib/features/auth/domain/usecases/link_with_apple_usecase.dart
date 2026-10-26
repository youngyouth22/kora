import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';

/// Links anonymous session using Sign in with Apple.
class LinkWithAppleUseCase implements UseCase<UserAccount, NoParams> {
  /// Creates a [LinkWithAppleUseCase].
  const LinkWithAppleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserAccount>> call(NoParams params) {
    return _repository.linkWithApple();
  }
}
