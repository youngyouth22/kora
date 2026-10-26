import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/auth/domain/usecases/link_with_apple_usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_google_usecase.dart';
import 'package:kora/features/auth/domain/usecases/send_email_otp_usecase.dart';
import 'package:kora/features/auth/domain/usecases/set_account_password_usecase.dart';
import 'package:kora/features/auth/domain/usecases/skip_account_linking_usecase.dart';
import 'package:kora/features/auth/domain/usecases/verify_email_otp_usecase.dart';

class MockAuthRepository implements AuthRepository {
  bool sendOtpCalled = false;
  bool verifyOtpCalled = false;
  bool setPasswordCalled = false;
  bool linkAppleCalled = false;
  bool linkGoogleCalled = false;
  bool skipCalled = false;

  bool shouldFail = false;

  static const testUser = UserAccount(
    id: 'usr_123',
    isAnonymous: false,
    email: 'user@kora.app',
    isEmailConfirmed: true,
  );

  @override
  ResultFuture<void> sendEmailOtp({required String email}) async {
    sendOtpCalled = true;
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Failed to send OTP'));
    }
    return const Right(null);
  }

  @override
  ResultFuture<UserAccount> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    verifyOtpCalled = true;
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Invalid OTP'));
    }
    return const Right(testUser);
  }

  @override
  ResultFuture<UserAccount> setPassword({required String password}) async {
    setPasswordCalled = true;
    if (shouldFail) {
      return const Left(ValidationFailure(message: 'Weak password'));
    }
    return const Right(testUser);
  }

  @override
  ResultFuture<UserAccount> linkWithApple() async {
    linkAppleCalled = true;
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Apple sign in failed'));
    }
    return const Right(testUser);
  }

  @override
  ResultFuture<UserAccount> linkWithGoogle() async {
    linkGoogleCalled = true;
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Google sign in failed'));
    }
    return const Right(testUser);
  }

  @override
  ResultFuture<void> skipAccountLinking() async {
    skipCalled = true;
    return const Right(null);
  }

  @override
  ResultFuture<UserAccount?> getCurrentUser() async {
    return const Right(testUser);
  }
}

void main() {
  late MockAuthRepository repository;
  late SendEmailOtpUseCase sendEmailOtpUseCase;
  late VerifyEmailOtpUseCase verifyEmailOtpUseCase;
  late SetAccountPasswordUseCase setAccountPasswordUseCase;
  late LinkWithAppleUseCase linkWithAppleUseCase;
  late LinkWithGoogleUseCase linkWithGoogleUseCase;
  late SkipAccountLinkingUseCase skipAccountLinkingUseCase;

  setUp(() {
    repository = MockAuthRepository();
    sendEmailOtpUseCase = SendEmailOtpUseCase(repository);
    verifyEmailOtpUseCase = VerifyEmailOtpUseCase(repository);
    setAccountPasswordUseCase = SetAccountPasswordUseCase(repository);
    linkWithAppleUseCase = LinkWithAppleUseCase(repository);
    linkWithGoogleUseCase = LinkWithGoogleUseCase(repository);
    skipAccountLinkingUseCase = SkipAccountLinkingUseCase(repository);
  });

  test('SendEmailOtpUseCase triggers repository sendEmailOtp', () async {
    final result = await sendEmailOtpUseCase('test@kora.app');
    expect(result.isRight(), isTrue);
    expect(repository.sendOtpCalled, isTrue);
  });

  test('VerifyEmailOtpUseCase verifies OTP and returns UserAccount', () async {
    final result = await verifyEmailOtpUseCase(
      const VerifyEmailOtpParams(email: 'test@kora.app', token: '123456'),
    );
    expect(result.isRight(), isTrue);
    expect(repository.verifyOtpCalled, isTrue);
  });

  test(
    'SetAccountPasswordUseCase sets password and returns UserAccount',
    () async {
      final result = await setAccountPasswordUseCase('SecretPassword123!');
      expect(result.isRight(), isTrue);
      expect(repository.setPasswordCalled, isTrue);
    },
  );

  test('LinkWithAppleUseCase triggers Apple sign-in', () async {
    final result = await linkWithAppleUseCase(const NoParams());
    expect(result.isRight(), isTrue);
    expect(repository.linkAppleCalled, isTrue);
  });

  test('LinkWithGoogleUseCase triggers Google sign-in', () async {
    final result = await linkWithGoogleUseCase(const NoParams());
    expect(result.isRight(), isTrue);
    expect(repository.linkGoogleCalled, isTrue);
  });

  test('SkipAccountLinkingUseCase skips account linking', () async {
    final result = await skipAccountLinkingUseCase(const NoParams());
    expect(result.isRight(), isTrue);
    expect(repository.skipCalled, isTrue);
  });
}
