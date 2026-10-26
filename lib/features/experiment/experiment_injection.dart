import 'package:get_it/get_it.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/experiment/data/repositories/experiment_repository_impl.dart';
import 'package:kora/features/experiment/domain/repositories/experiment_repository.dart';

/// Registers dependencies for the experiment feature.
void initExperimentInjection(GetIt sl) {
  if (!sl.isRegistered<ExperimentRepository>()) {
    sl.registerLazySingleton<ExperimentRepository>(
      () => ExperimentRepositoryImpl(
        experimentDao: sl<ExperimentDao>(),
        mutationDao: sl<SyncMutationDao>(),
        syncEngine: sl<SyncEngine>(),
      ),
    );
  }
}
