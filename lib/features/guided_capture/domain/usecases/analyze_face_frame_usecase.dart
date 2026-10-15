import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/domain/repositories/face_capture_repository.dart';

/// Usecase to analyze a live camera frame using ML Kit.
class AnalyzeFaceFrameUseCase {
  /// Creates an [AnalyzeFaceFrameUseCase].
  const AnalyzeFaceFrameUseCase(this._repository);

  final FaceCaptureRepository _repository;

  /// Executes facial frame detection.
  Future<FaceAnalysisResult> call(CameraFrameInput frame) {
    return _repository.analyzeFrame(frame);
  }
}
