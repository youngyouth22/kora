import 'package:flutter/material.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/presentation/widgets/hatched_oval_painter.dart';

/// Animated face-guide oval overlay.
///
/// Illuminates the hatched segment where the face is in contact or facing,
/// keeping the remaining ticks idle/light, and turns into a full emerald ring
/// once all quality standards are met.
class CaptureOvalGuide extends StatelessWidget {
  /// Creates a [CaptureOvalGuide].
  const CaptureOvalGuide({
    required this.hasFace,
    required this.alignmentScore,
    required this.faceOffsetFromCenter,
    required this.isAllValid,
    super.key,
  });

  /// Whether a face is currently detected.
  final bool hasFace;

  /// Alignment score [0.0 to 1.0] reported by the readiness evaluation.
  final double alignmentScore;

  /// Directional face offset relative to oval center.
  final FaceOffset faceOffsetFromCenter;

  /// Whether all capture criteria are met.
  final bool isAllValid;

  /// Duration of the score interpolation animation.
  static const Duration animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final percent = (alignmentScore * 100).round();

    return Semantics(
      label: isAllValid
          ? 'Face aligned, hold still'
          : 'Face alignment $percent percent',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: alignmentScore),
        duration: reduceMotion ? Duration.zero : animationDuration,
        curve: Curves.easeOut,
        builder: (context, animatedScore, _) => CustomPaint(
          size: Size.infinite,
          painter: HatchedOvalPainter(
            hasFace: hasFace,
            alignmentScore: animatedScore,
            faceOffsetFromCenter: faceOffsetFromCenter,
            isAllValid: isAllValid,
          ),
        ),
      ),
    );
  }
}
