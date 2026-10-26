import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// Available capture modes for the product scanner.
enum ScannerCaptureMode {
  /// Framing the product bottle/face with OCR guidance.
  productPhoto,

  /// Framing a barcode or QR code.
  barcode,
}

/// Base event for product scanner bloc.
sealed class ProductScannerEvent extends Equatable {
  const ProductScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on each streaming camera frame.
class LiveCameraFrameEvent extends ProductScannerEvent {
  /// Creates a [LiveCameraFrameEvent].
  const LiveCameraFrameEvent({
    required this.image,
    required this.camera,
  });

  /// The camera frame image.
  final CameraImage image;

  /// The active camera description.
  final CameraDescription camera;

  @override
  List<Object?> get props => [image, camera];
}

/// Dispatched when the user toggles the torch/flash.
class ToggleFlashTappedEvent extends ProductScannerEvent {
  /// Creates a [ToggleFlashTappedEvent].
  const ToggleFlashTappedEvent();
}

/// Dispatched when switching between Product and Barcode modes via segmented
/// control.
class ModeChangedEvent extends ProductScannerEvent {
  /// Creates a [ModeChangedEvent].
  const ModeChangedEvent(this.mode);

  /// Target capture mode.
  final ScannerCaptureMode mode;

  @override
  List<Object?> get props => [mode];
}

/// Dispatched when a photo is captured manually or picked from gallery.
class ImageCapturedOrPickedEvent extends ProductScannerEvent {
  /// Creates an [ImageCapturedOrPickedEvent].
  const ImageCapturedOrPickedEvent(this.imagePath);

  /// Path to the captured or picked image.
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Dispatched when a barcode is detected in the stream.
class BarcodeDetectedEvent extends ProductScannerEvent {
  /// Creates a [BarcodeDetectedEvent].
  const BarcodeDetectedEvent(this.barcode, {this.normalizedBox});

  /// Raw barcode string value.
  final String barcode;

  /// Normalized location of the code in the upright frame, if known.
  final ScannerBoundingBox? normalizedBox;

  @override
  List<Object?> get props => [barcode, normalizedBox];
}

/// Dispatched to navigate back to camera viewfinder from processing / error.
class BackToCameraEvent extends ProductScannerEvent {
  /// Creates a [BackToCameraEvent].
  const BackToCameraEvent();
}

/// Dispatched to retry scanning after a failure.
class RetryScanEvent extends ProductScannerEvent {
  /// Creates a [RetryScanEvent].
  const RetryScanEvent();
}
