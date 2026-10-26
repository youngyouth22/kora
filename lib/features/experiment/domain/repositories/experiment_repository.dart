import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/experiment/domain/entities/skincare_experiment.dart';

/// Contract for skincare experiments with offline-first guarantees.
abstract class ExperimentRepository {
  /// Retrieves all experiments for [userId] from local Drift cache.
  Future<Either<Failure, List<SkincareExperiment>>> getExperiments({
    required String userId,
  });

  /// Watches all experiments for [userId] reactively.
  Stream<List<SkincareExperiment>> watchExperiments({required String userId});

  /// Retrieves an experiment by [id] from local Drift cache.
  Future<Either<Failure, SkincareExperiment?>> getExperiment({
    required String id,
  });

  /// Saves or updates an experiment locally and queues remote sync.
  Future<Either<Failure, void>> saveExperiment(SkincareExperiment experiment);

  /// Deletes an experiment locally and queues remote deletion.
  Future<Either<Failure, void>> deleteExperiment({
    required String id,
    required String userId,
  });

  /// Synchronizes experiments with remote Supabase database.
  Future<Either<Failure, void>> syncExperiments({required String userId});
}
