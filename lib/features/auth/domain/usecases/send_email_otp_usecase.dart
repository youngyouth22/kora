import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';

/// Sends a 6-digit OTP code to the requested email.
class SendEmailOtpUseCase implements UseCase<void, String> {
  /// Creates a [SendEmailOtpUseCase].
  const SendEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(String email) {
    return _repository.sendEmailOtp(email: email);
  }
}
