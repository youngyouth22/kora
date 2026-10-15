import 'package:get_it/get_it.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/onboarding_injection.dart';
import 'package:kora/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:kora/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:kora/features/splash/domain/repositories/splash_repository.dart';
import 'package:kora/features/splash/domain/usecases/bootstrap_app_usecase.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';

/// Initializes dependency injection for the splash feature.
void initSplashInjection(GetIt sl) {
  // Ensure onboarding datasource dependency is satisfied
  if (!sl.isRegistered<OnboardingLocalDataSource>()) {
    initOnboardingInjection(sl);
  }

  // Datasource
  if (!sl.isRegistered<SplashLocalDataSource>()) {
    sl.registerLazySingleton<SplashLocalDataSource>(
      () => SplashLocalDataSourceImpl(
        onboardingLocalDataSource: sl<OnboardingLocalDataSource>(),
      ),
    );
  }

  // Repository
  if (!sl.isRegistered<SplashRepository>()) {
    sl.registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(
        localDataSource: sl<SplashLocalDataSource>(),
      ),
    );
  }

  // Use Case
  if (!sl.isRegistered<BootstrapAppUseCase>()) {
    sl.registerLazySingleton(
      () => BootstrapAppUseCase(sl<SplashRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<SplashBloc>()) {
    sl.registerFactory(
      () => SplashBloc(
        bootstrapApp: sl<BootstrapAppUseCase>(),
      ),
    );
  }
}
