import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:kora/features/guided_capture/data/datasources/frame_luminance_sampler.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// Datasource wrapping Google ML Kit Text Recognition for real-time camera
/// stream and high-resolution captured photos.
class MlkitTextOcrDataSource {
  /// Creates a [MlkitTextOcrDataSource].
  MlkitTextOcrDataSource({
    TextRecognizer? textRecognizer,
    this.luminanceSampler = const FrameLuminanceSampler(),
  }) : _textRecognizer = textRecognizer ?? TextRecognizer();

  final TextRecognizer _textRecognizer;

  /// Luminance sampler instance.
  final FrameLuminanceSampler luminanceSampler;

  /// Analyzes a live camera frame to produce [RawOcrFrameData].
  Future<RawOcrFrameData> analyzeCameraFrame({
    required CameraImage image,
    required CameraDescription camera,
  }) async {
    final brightness = _computeBrightness(image);
    final inputImage = _buildInputImage(image, camera);

    final isRotated =
        camera.sensorOrientation == 90 || camera.sensorOrientation == 270;
    final effectiveWidth = isRotated
        ? image.height.toDouble()
        : image.width.toDouble();
    final effectiveHeight = isRotated
        ? image.width.toDouble()
        : image.height.toDouble();

    if (inputImage == null) {
      return RawOcrFrameData(
        fullText: '',
        textBlockBoxes: const [],
        imageWidth: effectiveWidth,
        imageHeight: effectiveHeight,
        normalizedBrightness: brightness,
      );
    }

    final recognizedText = await _textRecognizer.processImage(inputImage);

    final boxes = recognizedText.blocks
        .map((block) {
          final rect = block.boundingBox;
          return ScannerBoundingBox(
            left: rect.left,
            top: rect.top,
            right: rect.right,
            bottom: rect.bottom,
          );
        })
        .toList(growable: false);

    return RawOcrFrameData(
      fullText: recognizedText.text,
      textBlockBoxes: boxes,
      imageWidth: effectiveWidth,
      imageHeight: effectiveHeight,
      normalizedBrightness: brightness,
    );
  }

  /// High-resolution full OCR on saved image file.
  Future<RecognizedText> processHighResFile(String filePath) {
    final inputImage = InputImage.fromFilePath(filePath);
    return _textRecognizer.processImage(inputImage);
  }

  double _computeBrightness(CameraImage image) {
    if (image.planes.isEmpty) return 0.5;
    final plane = image.planes.first;
    final layout = Platform.isIOS ? LumaLayout.bgra : LumaLayout.yPlane;
    final stats = luminanceSampler.sample(
      bytes: plane.bytes,
      width: image.width,
      height: image.height,
      bytesPerRow: plane.bytesPerRow,
      layout: layout,
    );
    return stats.mean;
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

  /// Releases ML Kit text recognizer resources.
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
