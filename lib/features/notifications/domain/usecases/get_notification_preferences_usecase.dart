import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Use case that fetches active user notification preferences.
class GetNotificationPreferencesUseCase
    implements UseCase<NotificationPreferences, NoParams> {
  /// Creates a [GetNotificationPreferencesUseCase].
  const GetNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, NotificationPreferences>> call(NoParams params) async {
    return _repository.getPreferences();
  }
}
