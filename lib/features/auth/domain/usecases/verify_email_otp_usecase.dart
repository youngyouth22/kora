import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for OTP verification.
class VerifyEmailOtpParams extends Equatable {
  /// Creates a [VerifyEmailOtpParams].
  const VerifyEmailOtpParams({required this.email, required this.token});

  /// The target email.
  final String email;

  /// The 6-digit OTP code entered by the user.
  final String token;

  @override
  List<Object?> get props => [email, token];
}

/// Verifies the OTP code sent to the email and links the account.
class VerifyEmailOtpUseCase
    implements UseCase<UserAccount, VerifyEmailOtpParams> {
  /// Creates a [VerifyEmailOtpUseCase].
  const VerifyEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserAccount>> call(VerifyEmailOtpParams params) {
    return _repository.verifyEmailOtp(
      email: params.email,
      token: params.token,
    );
  }
}
