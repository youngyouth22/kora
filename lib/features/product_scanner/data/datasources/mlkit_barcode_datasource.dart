import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// Datasource wrapping Google ML Kit Barcode Scanning for live camera stream
/// and static images.
class MlkitBarcodeDataSource {
  /// Creates a [MlkitBarcodeDataSource].
  MlkitBarcodeDataSource({
    BarcodeScanner? barcodeScanner,
  }) : _barcodeScanner =
           barcodeScanner ??
           BarcodeScanner(
             formats: [
               BarcodeFormat.all,
             ],
           );

  final BarcodeScanner _barcodeScanner;

  /// Analyzes a live camera frame to detect barcodes.
  ///
  /// The returned box is normalized against the upright (portrait) frame,
  /// matching ML Kit's rotation-compensated coordinate space.
  Future<DetectedBarcode?> analyzeCameraFrame({
    required CameraImage image,
    required CameraDescription camera,
  }) async {
    final inputImage = _buildInputImage(image, camera);
    if (inputImage == null) return null;

    final isRotated =
        camera.sensorOrientation == 90 || camera.sensorOrientation == 270;
    final uprightWidth = (isRotated ? image.height : image.width).toDouble();
    final uprightHeight = (isRotated ? image.width : image.height).toDouble();

    final barcodes = await _barcodeScanner.processImage(inputImage);
    for (final barcode in barcodes) {
      final raw = barcode.rawValue ?? barcode.displayValue;
      if (raw != null && raw.trim().isNotEmpty) {
        return DetectedBarcode(
          value: raw.trim(),
          normalizedBox: normalizeBox(
            left: barcode.boundingBox.left,
            top: barcode.boundingBox.top,
            right: barcode.boundingBox.right,
            bottom: barcode.boundingBox.bottom,
            frameWidth: uprightWidth,
            frameHeight: uprightHeight,
          ),
        );
      }
    }
    return null;
  }

  /// Normalizes an absolute box to `[0, 1]` against the frame size.
  ///
  /// Returns null for an empty frame or a degenerate box.
  static ScannerBoundingBox? normalizeBox({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double frameWidth,
    required double frameHeight,
  }) {
    if (frameWidth <= 0 || frameHeight <= 0) return null;
    final l = (left / frameWidth).clamp(0.0, 1.0);
    final t = (top / frameHeight).clamp(0.0, 1.0);
    final r = (right / frameWidth).clamp(0.0, 1.0);
    final b = (bottom / frameHeight).clamp(0.0, 1.0);
    if (r <= l || b <= t) return null;
    return ScannerBoundingBox(left: l, top: t, right: r, bottom: b);
  }

  /// High-resolution barcode detection on saved image file.
  Future<String?> processHighResFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final barcodes = await _barcodeScanner.processImage(inputImage);
    for (final barcode in barcodes) {
      final raw = barcode.rawValue ?? barcode.displayValue;
      if (raw != null && raw.trim().isNotEmpty) {
        return raw.trim();
      }
    }
    return null;
  }

  InputImage? _buildInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final rawFormat = image.format.raw;
    if (rawFormat is! int) return null;
    final format = InputImageFormatValue.fromRawValue(rawFormat);
    if (format == null) return null;

    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Releases ML Kit barcode scanner resources.
  Future<void> dispose() async {
    await _barcodeScanner.close();
  }
}
