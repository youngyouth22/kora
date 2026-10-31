import 'package:get_it/get_it.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';
import 'package:kora/features/routine/domain/usecases/evaluate_routine_insights_usecase.dart';
import 'package:kora/features/routine/domain/usecases/routine_usecases.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';

/// Registers dependencies for the routine feature.
void initRoutineInjection(GetIt sl) {
  if (!sl.isRegistered<RoutineRepository>()) {
    sl.registerLazySingleton<RoutineRepository>(
      () => RoutineRepositoryImpl(
        routineDao: sl.isRegistered<RoutineDao>() ? sl<RoutineDao>() : null,
        mutationDao: sl.isRegistered<SyncMutationDao>()
            ? sl<SyncMutationDao>()
            : null,
        syncEngine: sl.isRegistered<SyncEngine>() ? sl<SyncEngine>() : null,
        seedDemoIfEmpty: true,
      ),
    );
  }

  if (!sl.isRegistered<GetRoutineProductsUseCase>()) {
    sl.registerLazySingleton<GetRoutineProductsUseCase>(
      () => GetRoutineProductsUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<SaveRoutineProductUseCase>()) {
    sl.registerLazySingleton<SaveRoutineProductUseCase>(
      () => SaveRoutineProductUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteRoutineProductUseCase>()) {
    sl.registerLazySingleton<DeleteRoutineProductUseCase>(
      () => DeleteRoutineProductUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<ToggleRoutineStepUseCase>()) {
    sl.registerLazySingleton<ToggleRoutineStepUseCase>(
      () => ToggleRoutineStepUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<GetRoutineLogsForDateUseCase>()) {
    sl.registerLazySingleton<GetRoutineLogsForDateUseCase>(
      () => GetRoutineLogsForDateUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<GetCatalogProductsUseCase>()) {
    sl.registerLazySingleton<GetCatalogProductsUseCase>(
      () => GetCatalogProductsUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<ManageSkinCheckinUseCase>()) {
    sl.registerLazySingleton<ManageSkinCheckinUseCase>(
      () => ManageSkinCheckinUseCase(sl<RoutineRepository>()),
    );
  }

  if (!sl.isRegistered<EvaluateRoutineInsightsUseCase>()) {
    sl.registerLazySingleton<EvaluateRoutineInsightsUseCase>(
      EvaluateRoutineInsightsUseCase.new,
    );
  }

  if (!sl.isRegistered<RoutineBloc>()) {
    sl.registerLazySingleton<RoutineBloc>(
      () => RoutineBloc(
        getRoutineProducts: sl<GetRoutineProductsUseCase>(),
        saveRoutineProduct: sl<SaveRoutineProductUseCase>(),
        deleteRoutineProduct: sl<DeleteRoutineProductUseCase>(),
        toggleRoutineStep: sl<ToggleRoutineStepUseCase>(),
        getRoutineLogsForDate: sl<GetRoutineLogsForDateUseCase>(),
        getCatalogProducts: sl<GetCatalogProductsUseCase>(),
        manageSkinCheckin: sl<ManageSkinCheckinUseCase>(),
        evaluateInsights: sl<EvaluateRoutineInsightsUseCase>(),
      ),
    );
  }
}
