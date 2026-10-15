import 'package:equatable/equatable.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

/// Status enum for guided capture workflow.
enum CaptureStatus {
  /// Session initializing.
  initial,

  /// Actively analyzing camera feed for face alignment.
  scanning,

  /// Quality criteria met; running 800ms auto-trigger countdown.
  countdown,

  /// Ready to snap high-resolution photo.
  readyToTakePhoto,

  /// Hardware or processing error occurred.
  error,
}

/// State representation for guided facial capture screen.
class GuidedCaptureState extends Equatable {
  /// Creates a [GuidedCaptureState].
  const GuidedCaptureState({
    this.status = CaptureStatus.initial,
    this.hasFace = false,
    this.isPositionOk = false,
    this.isLightOk = false,
    this.isAngleOk = false,
    this.guidanceMessage = 'Position your face inside the oval',
    this.alignmentScore = 0,
    this.faceOffsetFromCenter = FaceOffset.zero,
    this.countdownProgress = 0,
    this.isNoFaceTimeout = false,
    this.errorMessage,
  });

  /// Current workflow status.
  final CaptureStatus status;

  /// Whether a face is detected in frame.
  final bool hasFace;

  /// Whether position distance and centering meet requirements.
  final bool isPositionOk;

  /// Whether lighting meets thresholds.
  final bool isLightOk;

  /// Whether face angles are straight.
  final bool isAngleOk;

  /// Current contextual user guidance message.
  final String guidanceMessage;

  /// Oval green fill alignment score [0.0 to 1.0].
  final double alignmentScore;

  /// Directional offset of the face from oval center.
  final FaceOffset faceOffsetFromCenter;

  /// Countdown progress [0.0 to 1.0].
  final double countdownProgress;

  /// True if 8s timer expired without seeing a face.
  final bool isNoFaceTimeout;

  /// Optional error message.
  final String? errorMessage;

  /// True when all 4 capture criteria (face, position, light, angle) are met.
  bool get isAllQualityMet => hasFace && isPositionOk && isLightOk && isAngleOk;

  /// Creates a copy of this state with updated values.
  GuidedCaptureState copyWith({
    CaptureStatus? status,
    bool? hasFace,
    bool? isPositionOk,
    bool? isLightOk,
    bool? isAngleOk,
    String? guidanceMessage,
    double? alignmentScore,
    FaceOffset? faceOffsetFromCenter,
    double? countdownProgress,
    bool? isNoFaceTimeout,
    String? errorMessage,
  }) {
    return GuidedCaptureState(
      status: status ?? this.status,
      hasFace: hasFace ?? this.hasFace,
      isPositionOk: isPositionOk ?? this.isPositionOk,
      isLightOk: isLightOk ?? this.isLightOk,
      isAngleOk: isAngleOk ?? this.isAngleOk,
      guidanceMessage: guidanceMessage ?? this.guidanceMessage,
      alignmentScore: alignmentScore ?? this.alignmentScore,
      faceOffsetFromCenter: faceOffsetFromCenter ?? this.faceOffsetFromCenter,
      countdownProgress: countdownProgress ?? this.countdownProgress,
      isNoFaceTimeout: isNoFaceTimeout ?? this.isNoFaceTimeout,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    hasFace,
    isPositionOk,
    isLightOk,
    isAngleOk,
    guidanceMessage,
    alignmentScore,
    faceOffsetFromCenter,
    countdownProgress,
    isNoFaceTimeout,
    errorMessage,
  ];
}
