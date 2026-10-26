import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Use case that prompts user for system notification authorization.
class RequestNotificationPermissionUseCase implements UseCase<bool, NoParams> {
  /// Creates a [RequestNotificationPermissionUseCase].
  const RequestNotificationPermissionUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return _repository.requestPermission();
  }
}
