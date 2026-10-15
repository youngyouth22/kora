import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:kora/features/guided_capture/data/datasources/frame_luminance_sampler.dart';
import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

/// Datasource wrapping Google ML Kit Face Detection and frame brightness
/// computation.
class MlkitFaceAnalyzerDataSource {
  /// Creates a [MlkitFaceAnalyzerDataSource].
  MlkitFaceAnalyzerDataSource({
    FaceDetector? faceDetector,
    FrameLuminanceSampler luminanceSampler = const FrameLuminanceSampler(),
  }) : _faceDetector =
           faceDetector ??
           FaceDetector(
             options: FaceDetectorOptions(
               enableTracking: true,
               enableClassification: true,
               enableLandmarks: true,
               enableContours: true,
               minFaceSize: 0.30,
             ),
           ),
       // Field is private to encapsulate sampling logic.
       // ignore: prefer_initializing_formals
       _luminanceSampler = luminanceSampler;

  final FaceDetector _faceDetector;
  final FrameLuminanceSampler _luminanceSampler;

  /// Analyzes a [CameraFrameInput] and returns facial landmarks & brightness.
  Future<FaceAnalysisResult> analyze(CameraFrameInput frame) async {
    final light = _computeLuminance(frame);
    final brightness = light.mean;
    final inputImage = _buildInputImage(frame);

    final isRotated =
        frame.sensorOrientation == 90 || frame.sensorOrientation == 270;
    final effectiveSize = isRotated
        ? CaptureDimensions(
            width: frame.height.toDouble(),
            height: frame.width.toDouble(),
          )
        : CaptureDimensions(
            width: frame.width.toDouble(),
            height: frame.height.toDouble(),
          );

    if (inputImage == null) {
      return FaceAnalysisResult(
        hasFace: false,
        imageSize: effectiveSize,
        normalizedBrightness: brightness,
        highlightClippingRatio: light.clippedRatio,
        isFrontCamera: frame.isFrontCamera,
        detectedFaceCount: 0,
      );
    }

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      return FaceAnalysisResult(
        hasFace: false,
        imageSize: effectiveSize,
        normalizedBrightness: brightness,
        highlightClippingRatio: light.clippedRatio,
        isFrontCamera: frame.isFrontCamera,
        detectedFaceCount: 0,
      );
    }

    // Prioritize primary (largest) face
    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height).compareTo(
        a.boundingBox.width * a.boundingBox.height,
      ),
    );
    final mainFace = faces.first;

    // Estimate vertical inner lip opening ratio relative to mouth width.
    // When mouth is closed, inner upper lip and lower lip touch (gap ~ 0).
    double? mouthRatio;
    final upperLipBottomContour =
        mainFace.contours[FaceContourType.upperLipBottom];
    final lowerLipTopContour = mainFace.contours[FaceContourType.lowerLipTop];
    final leftMouth = mainFace.landmarks[FaceLandmarkType.leftMouth];
    final rightMouth = mainFace.landmarks[FaceLandmarkType.rightMouth];

    if (upperLipBottomContour != null &&
        lowerLipTopContour != null &&
        upperLipBottomContour.points.isNotEmpty &&
        lowerLipTopContour.points.isNotEmpty &&
        leftMouth != null &&
        rightMouth != null) {
      final mouthWidth = (rightMouth.position.x - leftMouth.position.x).abs();
      // Midpoint of inner upper lip bottom and inner lower lip top
      final upperMidY = upperLipBottomContour
          .points[upperLipBottomContour.points.length ~/ 2]
          .y;
      final lowerMidY =
          lowerLipTopContour.points[lowerLipTopContour.points.length ~/ 2].y;
      final innerLipGap = (lowerMidY - upperMidY).abs();

      if (mouthWidth > 0) {
        mouthRatio = innerLipGap / mouthWidth;
      }
    }

    return FaceAnalysisResult(
      hasFace: true,
      faceBoundingBox: CaptureBoundingBox(
        left: mainFace.boundingBox.left,
        top: mainFace.boundingBox.top,
        width: mainFace.boundingBox.width,
        height: mainFace.boundingBox.height,
      ),
      imageSize: effectiveSize,
      yaw: mainFace.headEulerAngleY ?? 0,
      pitch: mainFace.headEulerAngleX ?? 0,
      roll: mainFace.headEulerAngleZ ?? 0,
      normalizedBrightness: brightness,
      highlightClippingRatio: light.clippedRatio,
      isFrontCamera: frame.isFrontCamera,
      detectedFaceCount: faces.length,
      leftEyeOpenProbability: mainFace.leftEyeOpenProbability,
      rightEyeOpenProbability: mainFace.rightEyeOpenProbability,
      mouthOpenRatio: mouthRatio,
    );
  }

  /// Measures the luminance of the central region of the frame.
  LuminanceStats _computeLuminance(CameraFrameInput frame) {
    if (frame.planeBytes.isEmpty) return LuminanceStats.neutral;
    return _luminanceSampler.sample(
      bytes: frame.planeBytes.first,
      width: frame.width,
      height: frame.height,
      bytesPerRow: frame.bytesPerRow.isNotEmpty ? frame.bytesPerRow.first : 0,
      layout: Platform.isIOS ? LumaLayout.bgra : LumaLayout.yPlane,
    );
  }

  /// Converts raw camera frame into ML Kit [InputImage].
  InputImage? _buildInputImage(CameraFrameInput frame) {
    final rotation = InputImageRotationValue.fromRawValue(
      frame.sensorOrientation,
    );
    if (rotation == null) return null;

    final format = frame.rawFormat != null
        ? InputImageFormatValue.fromRawValue(frame.rawFormat!)
        : null;
    if (format == null) return null;

    final allBytes = WriteBuffer();
    frame.planeBytes.forEach(allBytes.putUint8List);
    final bytes = allBytes.done().buffer.asUint8List();

    final bytesPerRow = frame.bytesPerRow.isNotEmpty
        ? frame.bytesPerRow.first
        : frame.width;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(frame.width.toDouble(), frame.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  /// Disposes ML Kit detector instance.
  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
