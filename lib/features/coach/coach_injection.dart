import 'package:get_it/get_it.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/coach/data/datasources/coach_local_datasource.dart';
import 'package:kora/features/coach/data/datasources/coach_remote_datasource.dart';
import 'package:kora/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:kora/features/coach/domain/repositories/coach_repository.dart';
import 'package:kora/features/coach/domain/usecases/delete_coach_thread_usecase.dart';
import 'package:kora/features/coach/domain/usecases/get_coach_threads_usecase.dart';
import 'package:kora/features/coach/domain/usecases/save_coach_thread_usecase.dart';
import 'package:kora/features/coach/domain/usecases/send_coach_message_usecase.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_bloc.dart';

/// Registers all dependencies for the Kora AI Coach feature.
void initCoachInjection(GetIt sl) {
  if (!sl.isRegistered<CoachLocalDataSource>()) {
    sl.registerLazySingleton<CoachLocalDataSource>(
      () => CoachLocalDataSourceImpl(
        preferencesService: sl.isRegistered<AppPreferencesService>()
            ? sl<AppPreferencesService>()
            : null,
      ),
    );
  }

  if (!sl.isRegistered<CoachRemoteDataSource>()) {
    sl.registerLazySingleton<CoachRemoteDataSource>(
      () => CoachRemoteDataSourceImpl(
        aiApiClient: sl.isRegistered<KoraAiApiClient>()
            ? sl<KoraAiApiClient>()
            : null,
      ),
    );
  }

  if (!sl.isRegistered<CoachRepository>()) {
    sl.registerLazySingleton<CoachRepository>(
      () => CoachRepositoryImpl(
        remoteDataSource: sl<CoachRemoteDataSource>(),
        localDataSource: sl<CoachLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<SendCoachMessageUseCase>()) {
    sl.registerLazySingleton<SendCoachMessageUseCase>(
      () => SendCoachMessageUseCase(sl<CoachRepository>()),
    );
  }

  if (!sl.isRegistered<GetCoachThreadsUseCase>()) {
    sl.registerLazySingleton<GetCoachThreadsUseCase>(
      () => GetCoachThreadsUseCase(sl<CoachRepository>()),
    );
  }

  if (!sl.isRegistered<SaveCoachThreadUseCase>()) {
    sl.registerLazySingleton<SaveCoachThreadUseCase>(
      () => SaveCoachThreadUseCase(sl<CoachRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteCoachThreadUseCase>()) {
    sl.registerLazySingleton<DeleteCoachThreadUseCase>(
      () => DeleteCoachThreadUseCase(sl<CoachRepository>()),
    );
  }

  if (!sl.isRegistered<CoachChatBloc>()) {
    sl.registerFactory<CoachChatBloc>(
      () => CoachChatBloc(
        sendCoachMessageUseCase: sl<SendCoachMessageUseCase>(),
        getCoachThreadsUseCase: sl<GetCoachThreadsUseCase>(),
        saveCoachThreadUseCase: sl<SaveCoachThreadUseCase>(),
        deleteCoachThreadUseCase: sl<DeleteCoachThreadUseCase>(),
        preferencesService: sl.isRegistered<AppPreferencesService>()
            ? sl<AppPreferencesService>()
            : null,
      ),
    );
  }
}
