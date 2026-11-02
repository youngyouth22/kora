import 'package:get_it/get_it.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:kora/features/progress/domain/repositories/progress_repository.dart';
import 'package:kora/features/progress/domain/usecases/progress_usecases.dart';
import 'package:kora/features/progress/presentation/bloc/progress_bloc.dart';

/// Registers dependencies for the Progress & Comparison feature.
void initProgressInjection(GetIt sl) {
  if (!sl.isRegistered<ProgressRepository>()) {
    sl.registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(
        scanDao: sl.isRegistered<ScanDao>() ? sl<ScanDao>() : null,
        experimentDao: sl.isRegistered<ExperimentDao>()
            ? sl<ExperimentDao>()
            : null,
        routineDao: sl.isRegistered<RoutineDao>() ? sl<RoutineDao>() : null,
      ),
    );
  }

  if (!sl.isRegistered<GetProgressDashboardUseCase>()) {
    sl.registerLazySingleton<GetProgressDashboardUseCase>(
      () => GetProgressDashboardUseCase(sl<ProgressRepository>()),
    );
  }

  if (!sl.isRegistered<GetCalendarMonthUseCase>()) {
    sl.registerLazySingleton<GetCalendarMonthUseCase>(
      () => GetCalendarMonthUseCase(sl<ProgressRepository>()),
    );
  }

  if (!sl.isRegistered<EvaluateProgressMetricsUseCase>()) {
    sl.registerLazySingleton<EvaluateProgressMetricsUseCase>(
      EvaluateProgressMetricsUseCase.new,
    );
  }

  if (!sl.isRegistered<ProgressBloc>()) {
    sl.registerLazySingleton<ProgressBloc>(
      () => ProgressBloc(
        getDashboard: sl<GetProgressDashboardUseCase>(),
        getCalendarMonth: sl<GetCalendarMonthUseCase>(),
      ),
    );
  }
}
