import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Parameters for updating notification preferences.
class UpdatePreferencesParams extends Equatable {
  /// Creates an [UpdatePreferencesParams] instance.
  const UpdatePreferencesParams(this.preferences);

  /// Target notification preferences to update.
  final NotificationPreferences preferences;

  @override
  List<Object?> get props => [preferences];
}

/// Use case that updates and saves user notification preferences.
class UpdateNotificationPreferencesUseCase
    implements UseCase<void, UpdatePreferencesParams> {
  /// Creates an [UpdateNotificationPreferencesUseCase].
  const UpdateNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(UpdatePreferencesParams params) async {
    return _repository.updatePreferences(params.preferences);
  }
}
