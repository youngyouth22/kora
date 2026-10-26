import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/auth/domain/usecases/link_with_apple_usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_google_usecase.dart';
import 'package:kora/features/auth/domain/usecases/send_email_otp_usecase.dart';
import 'package:kora/features/auth/domain/usecases/set_account_password_usecase.dart';
import 'package:kora/features/auth/domain/usecases/skip_account_linking_usecase.dart';
import 'package:kora/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  bool failNext = false;
  int failCode = 400;

  static const testUser = UserAccount(
    id: 'usr_abc',
    isAnonymous: false,
    email: 'user@kora.app',
    isEmailConfirmed: true,
  );

  @override
  Future<Either<Failure, void>> sendEmailOtp({required String email}) async {
    if (failNext) {
      return Left(
        AuthFailure(
          message: failCode == 409
              ? 'This email is already registered.'
              : 'Failed to send OTP',
          statusCode: failCode,
        ),
      );
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserAccount>> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    if (failNext) {
      return const Left(AuthFailure(message: 'Invalid OTP code'));
    }
    return const Right(testUser);
  }

  @override
  Future<Either<Failure, UserAccount>> setPassword({
    required String password,
  }) async {
    if (failNext) {
      return const Left(ValidationFailure(message: 'Weak password'));
    }
    return const Right(testUser);
  }

  @override
  Future<Either<Failure, UserAccount>> linkWithApple() async {
    if (failNext) {
      return const Left(AuthFailure(message: 'Apple error'));
    }
    return const Right(testUser);
  }

  @override
  Future<Either<Failure, UserAccount>> linkWithGoogle() async {
    if (failNext) {
      return const Left(AuthFailure(message: 'Google error'));
    }
    return const Right(testUser);
  }

  @override
  Future<Either<Failure, void>> skipAccountLinking() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserAccount?>> getCurrentUser() async {
    return const Right(testUser);
  }
}

void main() {
  late _FakeAuthRepository repository;
  late AuthBloc authBloc;

  setUp(() {
    repository = _FakeAuthRepository();
    authBloc = AuthBloc(
      sendEmailOtpUseCase: SendEmailOtpUseCase(repository),
      verifyEmailOtpUseCase: VerifyEmailOtpUseCase(repository),
      setAccountPasswordUseCase: SetAccountPasswordUseCase(repository),
      linkWithAppleUseCase: LinkWithAppleUseCase(repository),
      linkWithGoogleUseCase: LinkWithGoogleUseCase(repository),
      skipAccountLinkingUseCase: SkipAccountLinkingUseCase(repository),
    );
  });

  tearDown(() async {
    await authBloc.close();
  });

  test('initial state has AuthStatus.initial', () {
    expect(authBloc.state.status, AuthStatus.initial);
  });

  test('emits [loading, otpSent] when AuthSendOtpRequested succeeds', () async {
    unawaited(
      expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.loading, email: 'test@kora.app'),
          const AuthState(status: AuthStatus.otpSent, email: 'test@kora.app'),
        ]),
      ),
    );

    authBloc.add(const AuthSendOtpRequested('test@kora.app'));
  });

  test(
    'emits [loading, emailAlreadyInUse] on registered email',
    () async {
      repository
        ..failNext = true
        ..failCode = 409;

      unawaited(
        expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(
              status: AuthStatus.loading,
              email: 'existing@kora.app',
            ),
            const AuthState(
              status: AuthStatus.emailAlreadyInUse,
              email: 'existing@kora.app',
              errorMessage: 'This email is already registered.',
            ),
          ]),
        ),
      );

      authBloc.add(const AuthSendOtpRequested('existing@kora.app'));
    },
  );

  test(
    'emits [loading, otpVerified] when AuthVerifyOtpRequested succeeds',
    () async {
      unawaited(
        expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.loading),
            const AuthState(
              status: AuthStatus.otpVerified,
              email: 'test@kora.app',
              user: _FakeAuthRepository.testUser,
            ),
          ]),
        ),
      );

      authBloc.add(
        const AuthVerifyOtpRequested(
          email: 'test@kora.app',
          token: '123456',
        ),
      );
    },
  );

  test(
    'emits [loading, authenticated] when AuthSetPasswordRequested succeeds',
    () async {
      unawaited(
        expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.loading),
            const AuthState(
              status: AuthStatus.authenticated,
              user: _FakeAuthRepository.testUser,
            ),
          ]),
        ),
      );

      authBloc.add(const AuthSetPasswordRequested('NewSecurePassword123!'));
    },
  );

  test(
    'emits [loading, skipped] when AuthSkipRequested is dispatched',
    () async {
      unawaited(
        expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.loading),
            const AuthState(status: AuthStatus.skipped),
          ]),
        ),
      );

      authBloc.add(const AuthSkipRequested());
    },
  );
}
