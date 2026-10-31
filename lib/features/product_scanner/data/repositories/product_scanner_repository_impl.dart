import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/user_profile_repository.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_barcode_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_text_ocr_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/product_remote_datasource.dart';
import 'package:kora/features/product_scanner/data/models/skincare_report_model.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';

/// Production implementation of [ProductScannerRepository].
class ProductScannerRepositoryImpl implements ProductScannerRepository {
  /// Creates a [ProductScannerRepositoryImpl].
  ProductScannerRepositoryImpl({
    required this.ocrDataSource,
    required this.barcodeDataSource,
    required this.remoteDataSource,
    this.userProfileRepository,
  });

  /// Text OCR data source.
  final MlkitTextOcrDataSource ocrDataSource;

  /// Barcode detector data source.
  final MlkitBarcodeDataSource barcodeDataSource;

  /// Remote catalog data source.
  final ProductRemoteDataSource remoteDataSource;

  /// User profile repository for personalized scanning analysis.
  final UserProfileRepository? userProfileRepository;

  Future<UserSkinProfile?> _resolveUserProfile() async {
    final repo =
        userProfileRepository ??
        (GetIt.instance.isRegistered<UserProfileRepository>()
            ? GetIt.instance<UserProfileRepository>()
            : null);
    if (repo == null) return null;
    try {
      final res = await repo.getProfile(id: 'local-user');
      final resolved = res.fold((_) => null, (profile) => profile);
      return resolved;
    } on Object {
      return null;
    }
  }

  @override
  Future<RawOcrFrameData> analyzeLiveTextFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  }) {
    return ocrDataSource.analyzeCameraFrame(
      image: cameraImage as CameraImage,
      camera: cameraDescription as CameraDescription,
    );
  }

  @override
  Future<DetectedBarcode?> analyzeLiveBarcodeFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  }) {
    return barcodeDataSource.analyzeCameraFrame(
      image: cameraImage as CameraImage,
      camera: cameraDescription as CameraDescription,
    );
  }

  @override
  Future<ScannedProductResult> extractTextAndSearchBackend(
    String imagePath,
  ) async {
    final recognized = await ocrDataSource.processHighResFile(imagePath);
    final lines = <String>[];

    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final cleaned = line.text.trim();
        if (cleaned.isNotEmpty) {
          lines.add(cleaned);
        }
      }
    }

    final profile = await _resolveUserProfile();
    final backendResponse = await remoteDataSource.searchProductByOcrText(
      rawText: recognized.text,
      lines: lines,
      imagePath: imagePath,
      userProfile: profile,
    );

    final report = SkincareReportModel.fromJson(backendResponse).toEntity();

    return ScannedProductResult(
      imagePath: imagePath,
      extractedRawText: recognized.text,
      detectedLines: lines,
      sourceMode: ScanSourceMode.productPhoto,
      backendProductData: backendResponse,
      skincareReport: report,
    );
  }

  @override
  Future<ScannedProductResult> searchByBarcode({
    required String barcode,
    String? capturedImagePath,
  }) async {
    final profile = await _resolveUserProfile();
    final backendResponse = await remoteDataSource.searchProductByBarcode(
      barcode: barcode,
      imagePath: capturedImagePath,
      userProfile: profile,
    );

    final report = SkincareReportModel.fromJson(backendResponse).toEntity();

    return ScannedProductResult(
      imagePath: capturedImagePath ?? '',
      extractedRawText: barcode,
      detectedLines: [barcode],
      sourceMode: ScanSourceMode.barcode,
      barcodeValue: barcode,
      backendProductData: backendResponse,
      skincareReport: report,
    );
  }

  @override
  Future<void> dispose() async {
    await ocrDataSource.dispose();
    await barcodeDataSource.dispose();
  }
}
