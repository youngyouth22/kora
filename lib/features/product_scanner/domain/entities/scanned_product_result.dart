import 'package:equatable/equatable.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';

/// Source mode that produced the scan result.
enum ScanSourceMode {
  /// Captured photo with text recognition.
  productPhoto,

  /// Detected barcode / QR code.
  barcode,
}

/// Result of a completed product scan (either OCR label or barcode).
class ScannedProductResult extends Equatable {
  /// Creates a [ScannedProductResult].
  const ScannedProductResult({
    required this.imagePath,
    required this.extractedRawText,
    required this.detectedLines,
    required this.sourceMode,
    this.barcodeValue,
    this.backendProductData = const {},
    this.skincareReport,
  });

  /// Path to the captured or picked photo file.
  final String imagePath;

  /// Full extracted raw text.
  final String extractedRawText;

  /// Individual detected text lines.
  final List<String> detectedLines;

  /// Whether produced via OCR photo or barcode scan.
  final ScanSourceMode sourceMode;

  /// Raw barcode value if scanned via barcode mode.
  final String? barcodeValue;

  /// Structured backend product data (from database or mock).
  final Map<String, dynamic> backendProductData;

  /// Personalized AI skincare report from `POST /api/scan-product`.
  final SkincareReport? skincareReport;

  @override
  List<Object?> get props => [
    imagePath,
    extractedRawText,
    detectedLines,
    sourceMode,
    barcodeValue,
    backendProductData,
    skincareReport,
  ];
}
