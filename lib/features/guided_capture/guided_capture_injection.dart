import 'package:get_it/get_it.dart';
import 'package:kora/features/guided_capture/data/datasources/mlkit_face_analyzer_datasource.dart';
import 'package:kora/features/guided_capture/data/repositories/face_capture_repository_impl.dart';
import 'package:kora/features/guided_capture/domain/repositories/face_capture_repository.dart';
import 'package:kora/features/guided_capture/domain/usecases/analyze_face_frame_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/dispose_capture_session_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/evaluate_capture_readiness_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/set_screen_brightness_usecase.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_bloc.dart';

/// Registers all dependencies for the guided capture feature.
void initGuidedCaptureInjection(GetIt sl) {
  // Datasources
  if (!sl.isRegistered<MlkitFaceAnalyzerDataSource>()) {
    sl.registerLazySingleton<MlkitFaceAnalyzerDataSource>(
      MlkitFaceAnalyzerDataSource.new,
    );
  }

  // Repositories
  if (!sl.isRegistered<FaceCaptureRepository>()) {
    sl.registerLazySingleton<FaceCaptureRepository>(
      () => FaceCaptureRepositoryImpl(dataSource: sl()),
    );
  }

  // Usecases
  if (!sl.isRegistered<AnalyzeFaceFrameUseCase>()) {
    sl.registerLazySingleton(() => AnalyzeFaceFrameUseCase(sl()));
  }

  if (!sl.isRegistered<EvaluateCaptureReadinessUseCase>()) {
    sl.registerLazySingleton(EvaluateCaptureReadinessUseCase.new);
  }

  if (!sl.isRegistered<SetMaxScreenBrightnessUseCase>()) {
    sl.registerLazySingleton(() => SetMaxScreenBrightnessUseCase(sl()));
  }

  if (!sl.isRegistered<RestoreScreenBrightnessUseCase>()) {
    sl.registerLazySingleton(() => RestoreScreenBrightnessUseCase(sl()));
  }

  if (!sl.isRegistered<DisposeCaptureSessionUseCase>()) {
    sl.registerLazySingleton(() => DisposeCaptureSessionUseCase(sl()));
  }

  // BLoC
  if (!sl.isRegistered<GuidedCaptureBloc>()) {
    sl.registerFactory(
      () => GuidedCaptureBloc(
        analyzeFaceFrame: sl(),
        evaluateUseCase: sl(),
        setMaxScreenBrightness: sl(),
        restoreScreenBrightness: sl(),
        disposeCaptureSession: sl(),
      ),
    );
  }
}
