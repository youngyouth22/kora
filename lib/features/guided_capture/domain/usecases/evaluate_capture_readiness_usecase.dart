import 'dart:math' as math;

import 'package:kora/features/guided_capture/domain/entities/capture_oval_geometry.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

/// Pure algorithmic use case evaluating live scan frame quality and readiness.
///
/// The detected face is projected into the on-screen viewport (accounting for
/// the "cover" crop of the camera preview and front-camera mirroring) and
/// compared against the very same oval the user sees, resolved through
/// [CaptureOvalGeometry].
class EvaluateCaptureReadinessUseCase {
  /// Creates an [EvaluateCaptureReadinessUseCase].
  const EvaluateCaptureReadinessUseCase();

  /// Minimum face box width relative to the oval width ("Move closer").
  static const double minOvalFill = 0.55;

  /// Maximum face box width relative to the oval width ("Move back").
  static const double maxOvalFill = 0.95;

  /// Expected downward offset of the face box center relative to the oval
  /// center, in oval-radius units. ML Kit boxes span eyebrows→chin, so their
  /// center sits slightly below the center of the whole head.
  static const double faceCenterVerticalBias = 0.10;

  /// Maximum allowed distance (oval-radius units) between the face box
  /// center and its expected position.
  static const double centerTolerance = 0.25;

  /// Maximum allowed absolute yaw rotation degrees.
  static const double maxYaw = 10;

  /// Minimum allowed pitch tilt degrees.
  static const double minPitch = -15;

  /// Maximum allowed pitch tilt degrees.
  static const double maxPitch = 5;

  /// Minimum probability for an eye to be considered open.
  /// Value is set conservatively to avoid false positives in low light
  /// or with hooded/squinted eyes.
  static const double minEyeOpenProbability = 0.20;

  /// Maximum ratio of inner vertical lip gap relative to mouth width for mouth
  /// to be considered closed / resting (contour-based).
  static const double maxMouthOpenRatio = 0.25;

  /// Minimum mean luminance of the central region.
  ///
  /// Camera auto-exposure pulls a well-lit face towards mid-grey (~0.45), so
  /// only a genuinely dark scene stays under this value.
  static const double minBrightness = 0.25;

  /// Maximum mean luminance of the central region.
  static const double maxBrightness = 0.88;

  /// Maximum share of blown-out pixels before reporting glare.
  static const double maxHighlightClipping = 0.30;

  /// Upper bound of a partial (not yet valid) criterion score, so the ring
  /// only completes when every criterion is truly met.
  static const double maxPartialScore = 0.75;

  /// Angle excess (degrees) at which the angle partial score reaches zero.
  static const double angleScoreFalloff = 20;

  /// Distance excess (oval-radius units) at which centering score hits zero.
  static const double centerScoreFalloff = 1;

  /// Number of criteria averaged into the alignment score.
  static const int criteriaCount = 4;

  /// Evaluates the [analysis] against capture standards.
  ///
  /// [viewportSize] is the logical size of the full-screen preview. When
  /// omitted, the image itself is treated as the viewport.
  CaptureEvaluation call(
    FaceAnalysisResult analysis, {
    CaptureDimensions? viewportSize,
  }) {
    final brightness = analysis.normalizedBrightness;
    final isTooDark = brightness < minBrightness;
    final isTooBright =
        brightness > maxBrightness ||
        analysis.highlightClippingRatio > maxHighlightClipping;
    final isLightOk = !isTooDark && !isTooBright;

    final box = analysis.faceBoundingBox;
    final imgW = analysis.imageSize.width;
    final imgH = analysis.imageSize.height;

    if (!analysis.hasFace || box == null || imgW <= 0 || imgH <= 0) {
      return CaptureEvaluation(
        hasFace: false,
        isPositionOk: false,
        isLightOk: isLightOk,
        isAngleOk: false,
        guidanceMessage: isTooDark
            ? 'Need more light — turn towards a window'
            : 'Position your face inside the oval',
        alignmentScore: 0,
        shouldBoostBrightness: isTooDark,
      );
    }

    // Project the face box into viewport space (BoxFit.cover + mirroring).
    final vpW = viewportSize?.width ?? imgW;
    final vpH = viewportSize?.height ?? imgH;
    final scale = math.max(vpW / imgW, vpH / imgH);
    final cropX = (imgW * scale - vpW) / 2;
    final cropY = (imgH * scale - vpH) / 2;

    final imageCenterX = analysis.isFrontCamera
        ? imgW - box.centerX
        : box.centerX;
    final faceCenterX = imageCenterX * scale - cropX;
    final faceCenterY = box.centerY * scale - cropY;
    final faceWidth = box.width * scale;

    final oval = CaptureOvalGeometry.resolve(vpW, vpH);
    final dx = (faceCenterX - oval.centerX) / oval.radiusX;
    final dy = (faceCenterY - oval.centerY) / oval.radiusY;
    final faceOffset = FaceOffset(dx: dx, dy: dy);

    final biasedDy = dy - faceCenterVerticalBias;
    final centerDistance = math.sqrt(dx * dx + biasedDy * biasedDy);
    final ovalFill = faceWidth / (oval.radiusX * 2);

    final isCentered = centerDistance <= centerTolerance;
    final isTooSmall = ovalFill < minOvalFill;
    final isTooLarge = ovalFill > maxOvalFill;
    final isPositionOk = isCentered && !isTooSmall && !isTooLarge;

    final yawExcess = math.max(0, analysis.yaw.abs() - maxYaw);
    final pitchExcess = math.max(
      math.max(0, minPitch - analysis.pitch),
      math.max(0, analysis.pitch - maxPitch),
    );
    final angleExcess = math.max(yawExcess, pitchExcess).toDouble();
    final isAngleOk = angleExcess == 0;

    // Eyes open check: only flagged if BOTH eyes report definite closure
    // (< 0.20) or one eye is completely shut (< 0.10).
    final leftEye = analysis.leftEyeOpenProbability;
    final rightEye = analysis.rightEyeOpenProbability;
    final hasClosedEyes =
        (leftEye != null &&
            rightEye != null &&
            leftEye < minEyeOpenProbability &&
            rightEye < minEyeOpenProbability) ||
        (leftEye != null && leftEye < 0.10) ||
        (rightEye != null && rightEye < 0.10);

    // Mouth closed check: if ratio is available, must be <= 0.65
    final hasOpenMouth =
        analysis.mouthOpenRatio != null &&
        analysis.mouthOpenRatio! > maxMouthOpenRatio;

    final hasMultipleFaces = analysis.detectedFaceCount > 1;
    final isExpressionOk = !hasClosedEyes && !hasOpenMouth;
    final isEffectivePositionOk = isPositionOk && !hasMultipleFaces;
    final isEffectiveAngleOk = isAngleOk && isExpressionOk;

    final String message;
    if (hasMultipleFaces) {
      message = 'Only one person can be scanned at a time';
    } else if (hasClosedEyes) {
      message = 'Open your eyes';
    } else if (hasOpenMouth) {
      message = 'Close your mouth';
    } else if (!isLightOk) {
      message = isTooDark
          ? 'Need more light — turn towards a window'
          : 'Too much light — avoid direct glare';
    } else if (isTooSmall) {
      message = 'Move closer';
    } else if (isTooLarge) {
      message = 'Move back slightly';
    } else if (!isCentered) {
      message = 'Center your face in the oval';
    } else if (!isAngleOk) {
      message = 'Look straight';
    } else {
      message = 'Hold still...';
    }

    final centerScore = isCentered
        ? 1.0
        : _partial(
            1 - (centerDistance - centerTolerance) / centerScoreFalloff,
          );
    final sizeScore = !isTooSmall && !isTooLarge
        ? 1.0
        : _partial(
            isTooSmall ? ovalFill / minOvalFill : maxOvalFill / ovalFill,
          );
    final angleScore = isAngleOk
        ? 1.0
        : _partial(1 - angleExcess / angleScoreFalloff);
    final lightScore = isLightOk
        ? 1.0
        : _partial(
            isTooDark
                ? brightness / minBrightness
                : math.min(
                    maxBrightness / math.max(brightness, maxBrightness),
                    maxHighlightClipping /
                        math.max(
                          analysis.highlightClippingRatio,
                          maxHighlightClipping,
                        ),
                  ),
          );

    final alignmentScore =
        (centerScore + sizeScore + angleScore + lightScore) / criteriaCount;

    return CaptureEvaluation(
      hasFace: true,
      isPositionOk: isEffectivePositionOk,
      isLightOk: isLightOk,
      isAngleOk: isEffectiveAngleOk,
      guidanceMessage: message,
      alignmentScore: (hasMultipleFaces || !isExpressionOk)
          ? 0.35
          : alignmentScore,
      faceOffsetFromCenter: faceOffset,
      shouldBoostBrightness: isTooDark,
    );
  }

  double _partial(double value) => value.clamp(0.0, maxPartialScore);
}
