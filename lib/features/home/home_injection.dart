import 'package:get_it/get_it.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/home/data/repositories/home_repository_impl.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';
import 'package:kora/features/home/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:kora/features/home/presentation/bloc/home_bloc.dart';
import 'package:kora/features/progress/domain/repositories/progress_repository.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';
import 'package:supabase/supabase.dart';

/// Registers dependencies for the home feature.
void initHomeInjection(GetIt sl) {
  if (!sl.isRegistered<HomeRepository>()) {
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        profileDao: sl.isRegistered<ProfileDao>() ? sl<ProfileDao>() : null,
        scanDao: sl.isRegistered<ScanDao>() ? sl<ScanDao>() : null,
        routineDao: sl.isRegistered<RoutineDao>() ? sl<RoutineDao>() : null,
        experimentDao: sl.isRegistered<ExperimentDao>()
            ? sl<ExperimentDao>()
            : null,
        progressRepository: sl.isRegistered<ProgressRepository>()
            ? sl<ProgressRepository>()
            : null,
        routineRepository: sl.isRegistered<RoutineRepository>()
            ? sl<RoutineRepository>()
            : null,
        supabaseClient: sl.isRegistered<SupabaseClient>()
            ? sl<SupabaseClient>()
            : null,
        preferencesService: sl.isRegistered<AppPreferencesService>()
            ? sl<AppPreferencesService>()
            : null,
      ),
    );
  }

  if (!sl.isRegistered<GetHomeDashboardUseCase>()) {
    sl.registerLazySingleton<GetHomeDashboardUseCase>(
      () => GetHomeDashboardUseCase(sl<HomeRepository>()),
    );
  }

  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(
      () => HomeBloc(
        getHomeDashboard: sl<GetHomeDashboardUseCase>(),
        homeRepository: sl<HomeRepository>(),
      ),
    );
  }
}
