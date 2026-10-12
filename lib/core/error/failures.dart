import 'package:equatable/equatable.dart';

/// Base abstract class for all domain layer failures in Kora.
///
/// Failures represent operational and business errors that have bubbled up
/// to the domain layer and are consumed by use cases and BLoCs.
/// They do not depend on any Flutter, database, or network implementation.
abstract class Failure extends Equatable {
  /// Creates a [Failure] with a human-readable [message], optional
  /// [statusCode], and optional underlying [cause].
  const Failure({
    required this.message,
    this.statusCode,
    this.cause,
  });

  /// User-friendly or debug message describing what failed.
  final String message;

  /// Optional HTTP or internal error status code.
  final int? statusCode;

  /// Optional original exception or error object for diagnostic tracing.
  final Object? cause;

  @override
  List<Object?> get props => [message, statusCode, cause];

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Failure caused by remote server or Supabase Edge Function errors (5xx, 4xx).
class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Failure caused by network connectivity issues, timeouts, or DNS failures.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Failure caused by local storage, Drift database, or cache access errors.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Failure caused by authentication issues (expired session, unauthorized).
class AuthFailure extends Failure {
  /// Creates an [AuthFailure].
  const AuthFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Failure caused by invalid inputs or domain validation rule violations.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Failure specific to YouCam Skin AI scan, lighting check, or face capture.
class ScanFailure extends Failure {
  /// Creates a [ScanFailure].
  const ScanFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Failure emitted when a requested resource is not found.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Fallback failure for unexpected, unhandled exceptions.
class UnexpectedFailure extends Failure {
  /// Creates an [UnexpectedFailure].
  const UnexpectedFailure({
    required super.message,
    super.statusCode,
    super.cause,
  });
}
