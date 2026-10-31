import 'package:get_it/get_it.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/features/onboarding/domain/repositories/user_profile_repository.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_barcode_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_text_ocr_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/product_remote_datasource.dart';
import 'package:kora/features/product_scanner/data/repositories/product_scanner_repository_impl.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';
import 'package:kora/features/product_scanner/domain/usecases/evaluate_product_frame_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_and_search_product_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_barcode_usecase.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_bloc.dart';

/// Registers dependencies for the product scanner feature.
void initProductScannerInjection(GetIt sl) {
  // Data Sources
  if (!sl.isRegistered<MlkitTextOcrDataSource>()) {
    sl.registerLazySingleton<MlkitTextOcrDataSource>(
      MlkitTextOcrDataSource.new,
    );
  }
  if (!sl.isRegistered<MlkitBarcodeDataSource>()) {
    sl.registerLazySingleton<MlkitBarcodeDataSource>(
      MlkitBarcodeDataSource.new,
    );
  }
  if (!sl.isRegistered<ProductRemoteDataSource>()) {
    sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(
        aiApiClient: sl.isRegistered<KoraAiApiClient>()
            ? sl<KoraAiApiClient>()
            : null,
      ),
    );
  }

  // Repository
  if (!sl.isRegistered<ProductScannerRepository>()) {
    sl.registerLazySingleton<ProductScannerRepository>(
      () => ProductScannerRepositoryImpl(
        ocrDataSource: sl<MlkitTextOcrDataSource>(),
        barcodeDataSource: sl<MlkitBarcodeDataSource>(),
        remoteDataSource: sl<ProductRemoteDataSource>(),
        userProfileRepository: sl.isRegistered<UserProfileRepository>()
            ? sl<UserProfileRepository>()
            : null,
      ),
    );
  }

  // Usecases
  if (!sl.isRegistered<EvaluateProductFrameUseCase>()) {
    sl.registerLazySingleton<EvaluateProductFrameUseCase>(
      EvaluateProductFrameUseCase.new,
    );
  }
  if (!sl.isRegistered<ProcessAndSearchProductUseCase>()) {
    sl.registerLazySingleton<ProcessAndSearchProductUseCase>(
      () => ProcessAndSearchProductUseCase(sl<ProductScannerRepository>()),
    );
  }
  if (!sl.isRegistered<ProcessBarcodeUseCase>()) {
    sl.registerLazySingleton<ProcessBarcodeUseCase>(
      () => ProcessBarcodeUseCase(sl<ProductScannerRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<ProductScannerBloc>()) {
    sl.registerFactory<ProductScannerBloc>(
      () => ProductScannerBloc(
        repository: sl<ProductScannerRepository>(),
        evaluateFrameUseCase: sl<EvaluateProductFrameUseCase>(),
        processProductUseCase: sl<ProcessAndSearchProductUseCase>(),
        processBarcodeUseCase: sl<ProcessBarcodeUseCase>(),
      ),
    );
  }
}
