// ignore_for_file: document_ignores

import 'package:get_it/get_it.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/get_skin_profile_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/link_user_account_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_skin_profile_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';

/// Initializes dependency injection for the onboarding feature.
void initOnboardingInjection(GetIt sl) {
  // Datasources
  if (!sl.isRegistered<OnboardingLocalDataSource>()) {
    sl.registerLazySingleton<OnboardingLocalDataSource>(
      OnboardingLocalDataSourceImpl.new,
    );
  }

  if (!sl.isRegistered<OnboardingRemoteDataSource>()) {
    sl.registerLazySingleton<OnboardingRemoteDataSource>(
      OnboardingRemoteDataSourceImpl.new,
    );
  }

  // Repositories
  if (!sl.isRegistered<OnboardingRepository>()) {
    sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
      ),
    );
  }

  // Usecases
  if (!sl.isRegistered<TrackOnboardingStartedUseCase>()) {
    sl.registerLazySingleton(() => TrackOnboardingStartedUseCase(sl()));
  }

  if (!sl.isRegistered<SaveDemographicsUseCase>()) {
    sl.registerLazySingleton(() => SaveDemographicsUseCase(sl()));
  }

  if (!sl.isRegistered<SaveQuizAnswersUseCase>()) {
    sl.registerLazySingleton(() => SaveQuizAnswersUseCase(sl()));
  }

  if (!sl.isRegistered<CompleteOnboardingUseCase>()) {
    sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
  }

  if (!sl.isRegistered<SaveSkinProfileUseCase>()) {
    sl.registerLazySingleton(() => SaveSkinProfileUseCase(sl()));
  }

  if (!sl.isRegistered<GetSkinProfileUseCase>()) {
    sl.registerLazySingleton(() => GetSkinProfileUseCase(sl()));
  }

  if (!sl.isRegistered<LinkUserAccountUseCase>()) {
    sl.registerLazySingleton(() => LinkUserAccountUseCase(sl()));
  }

  // BLoC
  if (!sl.isRegistered<OnboardingBloc>()) {
    sl.registerFactory(
      () => OnboardingBloc(
        trackOnboardingStarted: sl(),
        saveDemographics: sl(),
        saveQuizAnswers: sl(),
        completeOnboarding: sl(),
        saveSkinProfile: sl(),
        linkUserAccount: sl(),
      ),
    );
  }
}
