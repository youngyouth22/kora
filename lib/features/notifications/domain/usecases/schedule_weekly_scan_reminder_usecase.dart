import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';

/// Parameters for scheduling weekly scan reminder (N1).
class ScheduleWeeklyScanParams extends Equatable {
  /// Creates a [ScheduleWeeklyScanParams] instance.
  const ScheduleWeeklyScanParams({
    this.dayOfWeek,
    this.hour,
    this.minute,
  });

  /// Optional day of week (1..7).
  final int? dayOfWeek;

  /// Optional hour of the day (0..23).
  final int? hour;

  /// Optional minute of the hour (0..59).
  final int? minute;

  @override
  List<Object?> get props => [dayOfWeek, hour, minute];
}

/// Use case that schedules the weekly skin scan reminder (N1) with copy:
/// « Time for your weekly scan. 30 seconds, same spot as last time. »
/// and target route `/scan/capture`.
class ScheduleWeeklyScanReminderUseCase
    implements UseCase<void, ScheduleWeeklyScanParams> {
  /// Creates a [ScheduleWeeklyScanReminderUseCase].
  const ScheduleWeeklyScanReminderUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(ScheduleWeeklyScanParams params) async {
    return _repository.scheduleWeeklyScanReminder(
      dayOfWeek: params.dayOfWeek,
      hour: params.hour,
      minute: params.minute,
    );
  }
}
