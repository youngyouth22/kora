import 'package:equatable/equatable.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';

/// Screen steps of the product scanner flow.
enum ProductScannerStep {
  /// Step 1: Camera viewfinder with guidance brackets & segmented mode switch.
  cameraGuidance,

  /// Step 2a: Processing screen with pulsing laser line and backend lookup
  /// (product photo flow).
  processingImage,

  /// Step 2b: A barcode was locked on the live preview; the frozen crop is
  /// lifted & zoomed while the backend lookup runs.
  barcodeLocked,

  /// Step 3: Product successfully matched.
  completed,

  /// Step 4: Analysis or lookup failure.
  failure,
}

/// State representation for product scanner bloc.
class ProductScannerState extends Equatable {
  /// Creates a [ProductScannerState].
  const ProductScannerState({
    this.step = ProductScannerStep.cameraGuidance,
    this.mode = ScannerCaptureMode.productPhoto,
    this.scansLeft = 2,
    this.isFlashOn = false,
    this.isLightOk = true,
    this.hasTextInFrame = false,
    this.isReadyToCapture = false,
    this.consecutiveReadyFrames = 0,
    this.guidanceMessage = 'Place the product front label inside the frame',
    this.capturedImagePath,
    this.detectedBarcode,
    this.result,
    this.errorMessage,
  });

  /// Current step of the scanner flow.
  final ProductScannerStep step;

  /// Active capture mode (product photo or barcode).
  final ScannerCaptureMode mode;

  /// Number of scans remaining.
  final int scansLeft;

  /// Flash / torch enabled.
  final bool isFlashOn;

  /// Environment lighting status.
  final bool isLightOk;

  /// Text detected inside central target reticle.
  final bool hasTextInFrame;

  /// True when conditions are met for auto-capture.
  final bool isReadyToCapture;

  /// Count of consecutive stable frames ready for auto-capture.
  final int consecutiveReadyFrames;

  /// Live guidance message displayed in pill above bottom bar.
  final String guidanceMessage;

  /// Path to captured photo displayed in processing screen.
  final String? capturedImagePath;

  /// Barcode locked on the live preview (barcode flow only).
  final DetectedBarcode? detectedBarcode;

  /// Resolved product result.
  final ScannedProductResult? result;

  /// Error message when step is [ProductScannerStep.failure].
  final String? errorMessage;

  /// Returns a copy of [ProductScannerState] with updated fields.
  ///
  /// Pass [clearDetectedBarcode] to reset [detectedBarcode] to null.
  ProductScannerState copyWith({
    ProductScannerStep? step,
    ScannerCaptureMode? mode,
    int? scansLeft,
    bool? isFlashOn,
    bool? isLightOk,
    bool? hasTextInFrame,
    bool? isReadyToCapture,
    int? consecutiveReadyFrames,
    String? guidanceMessage,
    String? capturedImagePath,
    DetectedBarcode? detectedBarcode,
    bool clearDetectedBarcode = false,
    ScannedProductResult? result,
    String? errorMessage,
  }) {
    return ProductScannerState(
      step: step ?? this.step,
      mode: mode ?? this.mode,
      scansLeft: scansLeft ?? this.scansLeft,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isLightOk: isLightOk ?? this.isLightOk,
      hasTextInFrame: hasTextInFrame ?? this.hasTextInFrame,
      isReadyToCapture: isReadyToCapture ?? this.isReadyToCapture,
      consecutiveReadyFrames:
          consecutiveReadyFrames ?? this.consecutiveReadyFrames,
      guidanceMessage: guidanceMessage ?? this.guidanceMessage,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      detectedBarcode: clearDetectedBarcode
          ? null
          : detectedBarcode ?? this.detectedBarcode,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    step,
    mode,
    scansLeft,
    isFlashOn,
    isLightOk,
    hasTextInFrame,
    isReadyToCapture,
    consecutiveReadyFrames,
    guidanceMessage,
    capturedImagePath,
    detectedBarcode,
    result,
    errorMessage,
  ];
}
