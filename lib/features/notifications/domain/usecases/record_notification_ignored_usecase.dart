import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Use case that increments consecutive ignored notifications count.
/// When 2 notifications are ignored in a row, divides frequency
/// (halving cadence).
class RecordNotificationIgnoredUseCase
    implements UseCase<NotificationPreferences, NoParams> {
  /// Creates a [RecordNotificationIgnoredUseCase].
  const RecordNotificationIgnoredUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, NotificationPreferences>> call(NoParams params) async {
    return _repository.recordNotificationIgnored();
  }
}
