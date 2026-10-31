import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';

/// Contract for skin progress data, scan timelines, concern histories,
/// calendar activity days, streaks, milestones, and experiments.
abstract class ProgressRepository {
  /// Retrieves all completed weekly scans for [userId] sorted chronologically
  /// descending (newest first).
  Future<Either<Failure, List<ProgressScan>>> getScans({
    required String userId,
  });

  /// Retrieves a single scan by [scanId].
  Future<Either<Failure, ProgressScan?>> getScanById({
    required String scanId,
    required String userId,
  });

  /// Retrieves the reference table of 12 skin concern types
  /// (`public.concern_types` in SQL).
  Future<Either<Failure, List<ProgressConcernType>>> getConcernTypes();

  /// Retrieves the calendar activity days (`public.activity_days`) for
  /// [month] (`YYYY-MM-01`).
  Future<Either<Failure, List<ProgressActivityDay>>> getCalendarMonth({
    required String userId,
    required DateTime month,
  });

  /// Retrieves the user's current streak state (`public.streak_state`).
  Future<Either<Failure, ProgressStreakState>> getStreakState({
    required String userId,
  });

  /// Retrieves all unlocked milestones (`public.milestones`) for [userId].
  Future<Either<Failure, List<ProgressMilestone>>> getMilestones({
    required String userId,
  });

  /// Retrieves all skincare experiments (`public.experiments`) for [userId].
  Future<Either<Failure, List<ProgressExperiment>>> getExperiments({
    required String userId,
  });
}
