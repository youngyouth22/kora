import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';

/// Base abstract class for all data-layer exceptions in Kora.
///
/// Exceptions are thrown at data source boundaries (HTTP, Supabase, Drift)
/// and caught in Repository implementations to be mapped to domain [Failure]s.
abstract class AppException extends Equatable implements Exception {
  /// Creates an [AppException] with [message], optional [statusCode],
  /// and [cause].
  const AppException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  /// Human-readable description of the exception.
  final String message;

  /// Optional HTTP or internal code associated with the exception.
  final int? statusCode;

  /// Optional underlying error or stack trace cause.
  final Object? cause;

  @override
  List<Object?> get props => [message, statusCode, cause];

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Thrown when remote server responds with an error (HTTP 5xx, unexpected 4xx).
class ServerException extends AppException {
  /// Creates a [ServerException].
  const ServerException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when a network transport or connection failure occurs.
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when local cache or Drift database operation fails.
class CacheException extends AppException {
  /// Creates a [CacheException].
  const CacheException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when an authentication or permission error occurs.
class AuthException extends AppException {
  /// Creates an [AuthException].
  const AuthException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when input data fails client-side validation.
class ValidationException extends AppException {
  /// Creates a [ValidationException].
  const ValidationException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when a YouCam Skin API scan processing task fails.
class ScanException extends AppException {
  /// Creates a [ScanException].
  const ScanException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when a requested entity is missing in data sources.
class NotFoundException extends AppException {
  /// Creates a [NotFoundException].
  const NotFoundException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

/// Thrown when an unclassified error occurs in data sources.
class UnexpectedException extends AppException {
  /// Creates an [UnexpectedException].
  const UnexpectedException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}
