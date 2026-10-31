import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_themes.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/auth/domain/usecases/link_with_apple_usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_google_usecase.dart';
import 'package:kora/features/auth/domain/usecases/send_email_otp_usecase.dart';
import 'package:kora/features/auth/domain/usecases/set_account_password_usecase.dart';
import 'package:kora/features/auth/domain/usecases/skip_account_linking_usecase.dart';
import 'package:kora/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/pages/account_secure_page.dart';

class _MockRepo implements AuthRepository {
  @override
  ResultFuture<void> sendEmailOtp({required String email}) async =>
      const Right(null);

  @override
  ResultFuture<UserAccount> verifyEmailOtp({
    required String email,
    required String token,
  }) async => const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<UserAccount> setPassword({required String password}) async =>
      const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<UserAccount> linkWithApple() async =>
      const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<UserAccount> linkWithGoogle() async =>
      const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<void> skipAccountLinking() async => const Right(null);

  @override
  ResultFuture<UserAccount?> getCurrentUser() async => const Right(null);
}

void main() {
  late AuthBloc authBloc;

  setUp(() {
    final repo = _MockRepo();
    authBloc = AuthBloc(
      sendEmailOtpUseCase: SendEmailOtpUseCase(repo),
      verifyEmailOtpUseCase: VerifyEmailOtpUseCase(repo),
      setAccountPasswordUseCase: SetAccountPasswordUseCase(repo),
      linkWithAppleUseCase: LinkWithAppleUseCase(repo),
      linkWithGoogleUseCase: LinkWithGoogleUseCase(repo),
      skipAccountLinkingUseCase: SkipAccountLinkingUseCase(repo),
    );
  });

  tearDown(() async {
    await authBloc.close();
  });

  testWidgets(
    'AccountSecurePage displays exclusively Google Sign-In and Maybe later',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.lightTheme,
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const AccountSecurePage(),
          ),
        ),
      );

      expect(find.text('Protect your skin progress'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Maybe later'), findsOneWidget);

      // Verify Apple and Email are removed per Google-only requirement
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Email'), findsNothing);
    },
  );
}
