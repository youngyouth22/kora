import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Parameters for handling notification tap response.
class HandleTapParams extends Equatable {
  /// Creates a [HandleTapParams] instance.
  const HandleTapParams({this.rawPayload});

  /// Raw JSON string from the notification response payload.
  final String? rawPayload;

  @override
  List<Object?> get props => [rawPayload];
}

/// Use case invoked when user taps on any local notification.
/// Parses the target route, resets consecutive ignored counter,
/// and returns the structured [NotificationPayload] for navigation.
class HandleNotificationTapUseCase
    implements UseCase<NotificationPayload?, HandleTapParams> {
  /// Creates a [HandleNotificationTapUseCase] with injected repository.
  const HandleNotificationTapUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, NotificationPayload?>> call(
    HandleTapParams params,
  ) async {
    return _repository.handleNotificationTap(params.rawPayload);
  }
}
