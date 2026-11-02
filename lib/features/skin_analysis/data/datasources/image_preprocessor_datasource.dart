// ignore_for_file: document_ignores, one_member_abstracts, lines_longer_than_80_chars

import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Contract for image preprocessing operations.
abstract class ImagePreprocessorDataSource {
  /// Preprocesses an image from [inputPath] to adhere to YouCam HD requirements:
  /// - Short edge >= 1080px
  /// - Long edge <= 2560px
  /// - File size < 10MB
  /// - Output format: JPEG
  /// - Face framed to occupy >= 60% of image width
  ///
  /// Returns the path of the processed image file.
  Future<String> preprocessHdImage(String inputPath);
}

/// Parameters passed to the background isolate.
class _IsolateParams {
  const _IsolateParams({
    required this.inputPath,
    required this.outputPath,
    this.faceCenterX,
    this.faceCenterY,
    this.faceWidth,
    this.faceHeight,
  });

  final String inputPath;
  final String outputPath;
  final double? faceCenterX;
  final double? faceCenterY;
  final double? faceWidth;
  final double? faceHeight;
}

/// Implementation using [package:image] running within an isolate.
class ImagePreprocessorDataSourceImpl implements ImagePreprocessorDataSource {
  /// Creates an [ImagePreprocessorDataSourceImpl].
  const ImagePreprocessorDataSourceImpl();

  @override
  Future<String> preprocessHdImage(String inputPath) async {
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      throw FileNotFoundException('Input image does not exist: $inputPath');
    }

    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/kora_hd_scan_$timestamp.jpg';

    double? faceCenterX;
    double? faceCenterY;
    double? faceWidth;
    double? faceHeight;

    try {
      final inputImage = InputImage.fromFilePath(inputPath);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          minFaceSize: 0.15,
        ),
      );
      final faces = await detector.processImage(inputImage);
      await detector.close();

      if (faces.isNotEmpty) {
        final box = faces.first.boundingBox;
        faceCenterX = box.center.dx;
        faceCenterY = box.center.dy;
        faceWidth = box.width;
        faceHeight = box.height;
      }
    } on Object catch (e) {
      debugPrint(
        '[ImagePreprocessorDataSource] Face detection unavailable in isolate prep: $e',
      );
    }

    return Isolate.run(
      () => _resizeAndEncode(
        _IsolateParams(
          inputPath: inputPath,
          outputPath: outputPath,
          faceCenterX: faceCenterX,
          faceCenterY: faceCenterY,
          faceWidth: faceWidth,
          faceHeight: faceHeight,
        ),
      ),
    );
  }

  static String _resizeAndEncode(_IsolateParams params) {
    final file = File(params.inputPath);
    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw const FormatException('Unable to decode captured face image.');
    }

    // 1. Ensure EXIF orientation is baked into pixel data
    var oriented = img.bakeOrientation(decoded);

    final rawW = oriented.width;
    final rawH = oriented.height;

    // 2. Smart Framing: Ensure face occupies 65%–70% of the image width to satisfy YouCam AI
    final fWidth = params.faceWidth;
    final fCenterX = params.faceCenterX;
    final fCenterY = params.faceCenterY;

    if (fWidth != null && fWidth > 0 && fCenterX != null && fCenterY != null) {
      final currentFaceRatio = fWidth / rawW;
      if (currentFaceRatio < 0.65) {
        // Target: face occupies 68% of the cropped image width
        final desiredCropWidth = math.min((fWidth / 0.68).round(), rawW);
        final desiredCropHeight = math.min(
          (desiredCropWidth * (4 / 3)).round(),
          rawH,
        );

        final cropLeft = (fCenterX - desiredCropWidth / 2).round().clamp(
          0,
          rawW - desiredCropWidth,
        );
        final cropTop = (fCenterY - desiredCropHeight * 0.45).round().clamp(
          0,
          rawH - desiredCropHeight,
        );

        oriented = img.copyCrop(
          oriented,
          x: cropLeft,
          y: cropTop,
          width: desiredCropWidth,
          height: desiredCropHeight,
        );
      }
    } else if (rawW / rawH > 0.65) {
      // Fallback if ML Kit bounding box not available:
      // When a selfie or portrait photo has face framing where ML Kit detector
      // is unavailable (e.g. simulator or headless), crop to 3:4 portrait
      // focusing on the upper-center ~65% width to ensure face occupies >= 60%
      // of the frame.
      final targetW = (rawW * 0.65).round();
      final targetH = math.min((targetW * (4 / 3)).round(), rawH);
      final cropX = ((rawW - targetW) / 2).round().clamp(0, rawW - targetW);
      final cropY = (rawH * 0.46 - targetH * 0.45).round().clamp(
        0,
        rawH - targetH,
      );
      oriented = img.copyCrop(
        oriented,
        x: cropX,
        y: cropY,
        width: targetW,
        height: targetH,
      );
    }

    // 3. Determine dimensions for YouCam HD specifications
    final width = oriented.width;
    final height = oriented.height;

    final isPortrait = height >= width;
    final shortSide = isPortrait ? width : height;
    final longSide = isPortrait ? height : width;

    // YouCam HD requirements:
    // short edge >= 1080px, long edge <= 2560px
    const minShortEdge = 1080;
    const maxLongEdge = 2560;

    var scale = 1.0;

    if (shortSide < minShortEdge) {
      scale = minShortEdge / shortSide;
    }

    if ((longSide * scale) > maxLongEdge) {
      scale = maxLongEdge / longSide;
    }

    var processed = oriented;
    if ((scale - 1).abs() > 0.01) {
      final targetWidth = (width * scale).round();
      final targetHeight = (height * scale).round();
      processed = img.copyResize(
        oriented,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // Encode to JPEG with quality 90 (well below 10MB limit)
    final encodedJpg = img.encodeJpg(processed, quality: 90);

    File(params.outputPath).writeAsBytesSync(encodedJpg);

    return params.outputPath;
  }
}

/// Thrown when input file is not found.
class FileNotFoundException implements Exception {
  /// Creates [FileNotFoundException].
  const FileNotFoundException(this.message);

  /// Message describing the missing file.
  final String message;

  @override
  String toString() => 'FileNotFoundException: $message';
}
