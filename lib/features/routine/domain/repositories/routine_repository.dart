import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

/// Contract for routine products and daily completion logs with offline-first
/// guarantees.
abstract class RoutineRepository {
  /// Retrieves all routine products for [userId] from local Drift cache.
  Future<Either<Failure, List<RoutineProduct>>> getRoutineProducts({
    required String userId,
  });

  /// Watches active routine products for [userId] reactively.
  Stream<List<RoutineProduct>> watchRoutineProducts({required String userId});

  /// Saves or updates a routine product locally and queues remote sync.
  Future<Either<Failure, void>> saveRoutineProduct(RoutineProduct product);

  /// Deletes a routine product locally and queues remote deletion.
  Future<Either<Failure, void>> deleteRoutineProduct({
    required String id,
    required String userId,
  });

  /// Retrieves routine logs for [userId] on a specific [logDate] (YYYY-MM-DD).
  Future<Either<Failure, List<RoutineLogRecord>>> getLogsForDate({
    required String userId,
    required String logDate,
  });

  /// Watches routine logs for [userId] on [logDate] reactively.
  Stream<List<RoutineLogRecord>> watchLogsForDate({
    required String userId,
    required String logDate,
  });

  /// Records a daily routine step checkmark locally and queues remote sync.
  Future<Either<Failure, void>> logRoutineStep(RoutineLogRecord log);

  /// Synchronizes routine items and logs with remote Supabase database.
  Future<Either<Failure, void>> syncRoutine({required String userId});
}
