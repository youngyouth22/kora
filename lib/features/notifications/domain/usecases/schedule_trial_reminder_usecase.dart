import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Parameters for scheduling free trial ending reminder (N3).
class ScheduleTrialReminderParams extends Equatable {
  /// Creates a [ScheduleTrialReminderParams] instance.
  const ScheduleTrialReminderParams({
    required this.trialEndDate,
  });

  /// Date when the trial expires.
  final DateTime trialEndDate;

  @override
  List<Object?> get props => [trialEndDate];
}

/// Use case that schedules N3 reminder 2 days before the user's trial ends:
/// « Your free trial ends in 2 days. You can manage it anytime in Settings. »
/// with target route `/profile/subscription`.
class ScheduleTrialReminderUseCase
    implements UseCase<void, ScheduleTrialReminderParams> {
  /// Creates a [ScheduleTrialReminderUseCase].
  const ScheduleTrialReminderUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(ScheduleTrialReminderParams params) async {
    return _repository.scheduleTrialEndingReminder(
      trialEndDate: params.trialEndDate,
    );
  }
}
