import 'package:get_it/get_it.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/features/skin_analysis/data/datasources/image_preprocessor_datasource.dart';
import 'package:kora/features/skin_analysis/data/datasources/skin_analysis_remote_datasource.dart';
import 'package:kora/features/skin_analysis/data/repositories/skin_analysis_repository_impl.dart';
import 'package:kora/features/skin_analysis/domain/repositories/scan_record_repository.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';
import 'package:kora/features/skin_analysis/domain/usecases/analyze_skin_usecase.dart';
import 'package:kora/features/skin_analysis/domain/usecases/preprocess_skin_image_usecase.dart';
import 'package:kora/features/skin_analysis/domain/usecases/save_scan_record_usecase.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';

/// Registers all dependencies for the skin analysis feature.
void initSkinAnalysisInjection(GetIt sl) {
  // Datasources
  if (!sl.isRegistered<ImagePreprocessorDataSource>()) {
    sl.registerLazySingleton<ImagePreprocessorDataSource>(
      ImagePreprocessorDataSourceImpl.new,
    );
  }

  if (!sl.isRegistered<SkinAnalysisRemoteDataSource>()) {
    sl.registerLazySingleton<SkinAnalysisRemoteDataSource>(
      () => SkinAnalysisRemoteDataSourceImpl(
        aiApiClient: sl.isRegistered<KoraAiApiClient>()
            ? sl<KoraAiApiClient>()
            : null,
      ),
    );
  }

  // Repositories
  if (!sl.isRegistered<SkinAnalysisRepository>()) {
    sl.registerLazySingleton<SkinAnalysisRepository>(
      () => SkinAnalysisRepositoryImpl(
        preprocessorDataSource: sl(),
        remoteDataSource: sl(),
      ),
    );
  }

  // Usecases
  if (!sl.isRegistered<PreprocessSkinImageUseCase>()) {
    sl.registerLazySingleton(
      () => PreprocessSkinImageUseCase(sl()),
    );
  }

  if (!sl.isRegistered<AnalyzeSkinUseCase>()) {
    sl.registerLazySingleton(
      () => AnalyzeSkinUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SaveScanRecordUseCase>()) {
    sl.registerLazySingleton(
      () => SaveScanRecordUseCase(sl<ScanRecordRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<SkinAnalysisBloc>()) {
    sl.registerFactory(
      () => SkinAnalysisBloc(
        preprocessUseCase: sl(),
        analyzeUseCase: sl(),
        saveScanUseCase: sl.isRegistered<SaveScanRecordUseCase>()
            ? sl<SaveScanRecordUseCase>()
            : null,
      ),
    );
  }
}
