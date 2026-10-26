import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';

/// Links anonymous session using Google Sign In.
class LinkWithGoogleUseCase implements UseCase<UserAccount, NoParams> {
  /// Creates a [LinkWithGoogleUseCase].
  const LinkWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserAccount>> call(NoParams params) {
    return _repository.linkWithGoogle();
  }
}
