import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Parameters for dispatching or scheduling a notification payload.
class DispatchNotificationParams extends Equatable {
  /// Creates a [DispatchNotificationParams] instance.
  const DispatchNotificationParams({
    required this.payload,
    required this.scheduledTime,
    this.isUserExplicitChoice = false,
  });

  /// Target notification payload.
  final NotificationPayload payload;

  /// Target scheduled time.
  final DateTime scheduledTime;

  /// Whether user explicitly chose this time.
  final bool isUserExplicitChoice;

  @override
  List<Object?> get props => [payload, scheduledTime, isUserExplicitChoice];
}

/// Generic usecase dispatching or scheduling any notification obeying all
/// enterprise rules (quiet hours, weekly cap, non-guilt copy).
class DispatchNotificationUseCase
    implements UseCase<void, DispatchNotificationParams> {
  /// Creates a [DispatchNotificationUseCase].
  const DispatchNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(DispatchNotificationParams params) async {
    return _repository.scheduleNotification(
      payload: params.payload,
      scheduledTime: params.scheduledTime,
      isUserExplicitChoice: params.isUserExplicitChoice,
    );
  }
}
