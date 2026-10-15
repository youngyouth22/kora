import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

/// Contract for face capture image analysis and device hardware illumination.
abstract class FaceCaptureRepository {
  /// Analyzes a camera frame to detect facial presence, pose, and brightness.
  Future<FaceAnalysisResult> analyzeFrame(CameraFrameInput frame);

  /// Maximizes screen brightness during underexposed scanning conditions.
  Future<void> setMaxScreenBrightness();

  /// Restores device screen brightness to its original system setting.
  Future<void> restoreScreenBrightness();

  /// Releases ML Kit detector and platform resources.
  Future<void> dispose();
}
