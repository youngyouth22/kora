import 'package:equatable/equatable.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// A barcode / QR code detected in a live camera frame.
class DetectedBarcode extends Equatable {
  /// Creates a [DetectedBarcode].
  const DetectedBarcode({
    required this.value,
    this.normalizedBox,
  });

  /// Raw decoded value.
  final String value;

  /// Location of the code normalized to `[0, 1]` relative to the upright
  /// camera frame (portrait). Null when the detector gave no usable box.
  final ScannerBoundingBox? normalizedBox;

  @override
  List<Object?> get props => [value, normalizedBox];
}
