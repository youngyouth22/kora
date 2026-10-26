import 'package:equatable/equatable.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';

/// Status enum reflecting the state of authentication/linking operations.
enum AuthStatus {
  /// Initial idle state.
  initial,

  /// Asynchronous operation in progress.
  loading,

  /// OTP code was successfully dispatched to user's email.
  otpSent,

  /// OTP code has been verified successfully.
  otpVerified,

  /// Account linking / authentication succeeded.
  authenticated,

  /// User chose "Maybe later".
  skipped,

  /// The provided email is already registered to an existing account.
  emailAlreadyInUse,

  /// Operation failed.
  failure,
}

/// State representing authentication status and user data.
class AuthState extends Equatable {
  /// Creates an [AuthState].
  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.user,
    this.errorMessage,
  });

  /// The current state status.
  final AuthStatus status;

  /// The email address currently undergoing verification.
  final String? email;

  /// The linked user account.
  final UserAccount? user;

  /// Human-readable error message on failure.
  final String? errorMessage;

  /// Whether a loading indicator should be active.
  bool get isLoading => status == AuthStatus.loading;

  /// Whether linking succeeded.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Creates a copy of [AuthState] with updated values.
  AuthState copyWith({
    AuthStatus? status,
    String? email,
    UserAccount? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, email, user, errorMessage];
}
