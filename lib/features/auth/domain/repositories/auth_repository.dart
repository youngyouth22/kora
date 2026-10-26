import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';

/// Contract defining authentication and account linking operations.
///
/// Implemented in data layer with zero presentation or UI awareness.
abstract class AuthRepository {
  /// Sends an email verification / OTP code to [email].
  ResultFuture<void> sendEmailOtp({required String email});

  /// Verifies the OTP [token] for [email] and links or signs in the user.
  ResultFuture<UserAccount> verifyEmailOtp({
    required String email,
    required String token,
  });

  /// Sets or updates the permanent account [password] for the linked user.
  ResultFuture<UserAccount> setPassword({required String password});

  /// Links the current anonymous session with Sign in with Apple.
  ResultFuture<UserAccount> linkWithApple();

  /// Links the current anonymous session with Google Sign In.
  ResultFuture<UserAccount> linkWithGoogle();

  /// Defers account linking, scheduling free-user reminders (D+3 and D+7).
  ResultFuture<void> skipAccountLinking();

  /// Retrieves the active [UserAccount] if a session exists.
  ResultFuture<UserAccount?> getCurrentUser();
}
