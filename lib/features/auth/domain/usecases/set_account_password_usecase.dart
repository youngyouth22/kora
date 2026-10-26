import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';

/// Configures or updates the account password.
class SetAccountPasswordUseCase implements UseCase<UserAccount, String> {
  /// Creates a [SetAccountPasswordUseCase].
  const SetAccountPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserAccount>> call(String password) {
    return _repository.setPassword(password: password);
  }
}
