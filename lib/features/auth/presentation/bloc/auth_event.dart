import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  /// Creates an [AuthEvent].
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers sending an OTP code to [email].
class AuthSendOtpRequested extends AuthEvent {
  /// Creates an [AuthSendOtpRequested] event.
  const AuthSendOtpRequested(this.email);

  /// Target email to send the OTP to.
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Triggers verification of the OTP [token] for [email].
class AuthVerifyOtpRequested extends AuthEvent {
  /// Creates an [AuthVerifyOtpRequested] event.
  const AuthVerifyOtpRequested({required this.email, required this.token});

  /// The email address.
  final String email;

  /// The OTP token.
  final String token;

  @override
  List<Object?> get props => [email, token];
}

/// Triggers setting the permanent [password] for the account.
class AuthSetPasswordRequested extends AuthEvent {
  /// Creates an [AuthSetPasswordRequested] event.
  const AuthSetPasswordRequested(this.password);

  /// The selected password.
  final String password;

  @override
  List<Object?> get props => [password];
}

/// Triggers Sign in with Apple account linking.
class AuthLinkAppleRequested extends AuthEvent {
  /// Creates an [AuthLinkAppleRequested] event.
  const AuthLinkAppleRequested();
}

/// Triggers Google Sign In account linking.
class AuthLinkGoogleRequested extends AuthEvent {
  /// Creates an [AuthLinkGoogleRequested] event.
  const AuthLinkGoogleRequested();
}

/// Triggers skipping account linking (deferral to D+3 / D+7).
class AuthSkipRequested extends AuthEvent {
  /// Creates an [AuthSkipRequested] event.
  const AuthSkipRequested();
}

/// Resets transient failure / error messages.
class AuthResetErrorRequested extends AuthEvent {
  /// Creates an [AuthResetErrorRequested] event.
  const AuthResetErrorRequested();
}
