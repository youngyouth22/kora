import 'package:get_it/get_it.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';

/// Registers dependencies for the routine feature.
void initRoutineInjection(GetIt sl) {
  if (!sl.isRegistered<RoutineRepository>()) {
    sl.registerLazySingleton<RoutineRepository>(
      () => RoutineRepositoryImpl(
        routineDao: sl<RoutineDao>(),
        mutationDao: sl<SyncMutationDao>(),
        syncEngine: sl<SyncEngine>(),
      ),
    );
  }
}
