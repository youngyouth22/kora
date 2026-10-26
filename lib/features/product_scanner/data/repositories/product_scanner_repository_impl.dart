import 'package:camera/camera.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_barcode_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_text_ocr_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/product_remote_datasource.dart';
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
  });

  /// Text OCR data source.
  final MlkitTextOcrDataSource ocrDataSource;

  /// Barcode detector data source.
  final MlkitBarcodeDataSource barcodeDataSource;

  /// Remote catalog data source.
  final ProductRemoteDataSource remoteDataSource;

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

    final backendResponse = await remoteDataSource.searchProductByOcrText(
      rawText: recognized.text,
      lines: lines,
      imagePath: imagePath,
    );

    return ScannedProductResult(
      imagePath: imagePath,
      extractedRawText: recognized.text,
      detectedLines: lines,
      sourceMode: ScanSourceMode.productPhoto,
      backendProductData: backendResponse,
    );
  }

  @override
  Future<ScannedProductResult> searchByBarcode({
    required String barcode,
    String? capturedImagePath,
  }) async {
    final backendResponse = await remoteDataSource.searchProductByBarcode(
      barcode: barcode,
      imagePath: capturedImagePath,
    );

    return ScannedProductResult(
      imagePath: capturedImagePath ?? '',
      extractedRawText: barcode,
      detectedLines: [barcode],
      sourceMode: ScanSourceMode.barcode,
      barcodeValue: barcode,
      backendProductData: backendResponse,
    );
  }

  @override
  Future<void> dispose() async {
    await ocrDataSource.dispose();
    await barcodeDataSource.dispose();
  }
}
