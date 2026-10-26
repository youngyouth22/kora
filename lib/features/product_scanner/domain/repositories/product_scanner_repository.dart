import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';

/// Contract for product OCR and barcode scanning data sources.
abstract class ProductScannerRepository {
  /// Analyzes an incoming camera frame for text blocks and guidance.
  Future<RawOcrFrameData> analyzeLiveTextFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  });

  /// Analyzes an incoming camera frame for barcodes. Returns the first
  /// decoded code with its normalized location, or null if none.
  Future<DetectedBarcode?> analyzeLiveBarcodeFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  });

  /// Processes a captured high-res image and queries backend.
  Future<ScannedProductResult> extractTextAndSearchBackend(String imagePath);

  /// Searches backend by detected barcode value.
  Future<ScannedProductResult> searchByBarcode({
    required String barcode,
    String? capturedImagePath,
  });

  /// Releases ML Kit resources.
  Future<void> dispose();
}
