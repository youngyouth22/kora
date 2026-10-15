import 'package:equatable/equatable.dart';

/// Pure Dart representation of a bounding box for face capture.
class CaptureBoundingBox extends Equatable {
  /// Creates a [CaptureBoundingBox].
  const CaptureBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Distance from left edge.
  final double left;

  /// Distance from top edge.
  final double top;

  /// Width of bounding box.
  final double width;

  /// Height of bounding box.
  final double height;

  /// Horizontal center coordinate.
  double get centerX => left + (width / 2);

  /// Vertical center coordinate.
  double get centerY => top + (height / 2);

  @override
  List<Object?> get props => [left, top, width, height];
}

/// Pure Dart dimensions representation.
class CaptureDimensions extends Equatable {
  /// Creates a [CaptureDimensions].
  const CaptureDimensions({
    required this.width,
    required this.height,
  });

  /// Width in pixels.
  final double width;

  /// Height in pixels.
  final double height;

  @override
  List<Object?> get props => [width, height];
}

/// Normalized directional offset of the face relative to the target oval
/// center.
class FaceOffset extends Equatable {
  /// Creates a [FaceOffset].
  const FaceOffset({this.dx = 0, this.dy = 0});

  /// Zero offset sentinel.
  static const FaceOffset zero = FaceOffset();

  /// Horizontal offset [-1.0 to 1.0].
  final double dx;

  /// Vertical offset [-1.0 to 1.0].
  final double dy;

  @override
  List<Object?> get props => [dx, dy];
}

/// Pure domain entity containing raw frame facial analysis metrics.
class FaceAnalysisResult extends Equatable {
  /// Creates a [FaceAnalysisResult].
  const FaceAnalysisResult({
    required this.hasFace,
    required this.imageSize,
    required this.normalizedBrightness,
    this.faceBoundingBox,
    this.yaw = 0,
    this.pitch = 0,
    this.roll = 0,
    this.isFrontCamera = true,
    this.highlightClippingRatio = 0,
    this.detectedFaceCount = 1,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.mouthOpenRatio,
  });

  /// Whether at least one face was detected.
  final bool hasFace;

  /// Bounding box of the primary detected face.
  final CaptureBoundingBox? faceBoundingBox;

  /// Effective dimensions of the processed frame.
  final CaptureDimensions imageSize;

  /// Yaw angle (head turn left/right).
  final double yaw;

  /// Pitch angle (head tilt up/down).
  final double pitch;

  /// Roll angle (lateral tilt).
  final double roll;

  /// Mean luminance [0.0 to 1.0] of the central region of the frame (where
  /// the face is expected).
  final double normalizedBrightness;

  /// Share [0.0 to 1.0] of central-region pixels that are blown out
  /// (near-white), used to detect direct glare.
  final double highlightClippingRatio;

  /// Total number of faces detected in the current frame.
  final int detectedFaceCount;

  /// Probability [0.0 to 1.0] that the left eye is open (if computed).
  final double? leftEyeOpenProbability;

  /// Probability [0.0 to 1.0] that the right eye is open (if computed).
  final double? rightEyeOpenProbability;

  /// Estimated ratio of vertical mouth opening relative to face height.
  final double? mouthOpenRatio;

  /// Whether the frame is from the front selfie camera.
  final bool isFrontCamera;

  @override
  List<Object?> get props => [
    hasFace,
    faceBoundingBox,
    imageSize,
    yaw,
    pitch,
    roll,
    normalizedBrightness,
    isFrontCamera,
    highlightClippingRatio,
    detectedFaceCount,
    leftEyeOpenProbability,
    rightEyeOpenProbability,
    mouthOpenRatio,
  ];
}

/// Result of business rule evaluation on capture readiness.
class CaptureEvaluation extends Equatable {
  /// Creates a [CaptureEvaluation].
  const CaptureEvaluation({
    required this.hasFace,
    required this.isPositionOk,
    required this.isLightOk,
    required this.isAngleOk,
    required this.guidanceMessage,
    required this.alignmentScore,
    required this.shouldBoostBrightness,
    this.faceOffsetFromCenter = FaceOffset.zero,
  });

  /// Whether face presence is confirmed.
  final bool hasFace;

  /// Whether face distance and centering are within tolerance.
  final bool isPositionOk;

  /// Whether lighting meets minimum and maximum thresholds.
  final bool isLightOk;

  /// Whether angles (yaw/pitch) are strictly centered.
  final bool isAngleOk;

  /// Single contextual guidance instruction for the user.
  final String guidanceMessage;

  /// Oval green arc lighting coverage score [0.0 to 1.0].
  final double alignmentScore;

  /// Directional face offset vector [-1.0 to +1.0].
  final FaceOffset faceOffsetFromCenter;

  /// Whether screen brightness should be temporarily boosted.
  final bool shouldBoostBrightness;

  /// Whether all capture quality criteria are fulfilled.
  bool get isAllValid => hasFace && isPositionOk && isLightOk && isAngleOk;

  @override
  List<Object?> get props => [
    hasFace,
    isPositionOk,
    isLightOk,
    isAngleOk,
    guidanceMessage,
    alignmentScore,
    faceOffsetFromCenter,
    shouldBoostBrightness,
  ];
}
