import 'package:kora/features/guided_capture/data/datasources/mlkit_face_analyzer_datasource.dart';
import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/domain/repositories/face_capture_repository.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Repository implementation handling ML Kit frame analysis and
/// display brightness.
class FaceCaptureRepositoryImpl implements FaceCaptureRepository {
  /// Creates a [FaceCaptureRepositoryImpl].
  FaceCaptureRepositoryImpl({
    required this.dataSource,
    ScreenBrightness? screenBrightness,
  }) : _screenBrightness = screenBrightness ?? ScreenBrightness();

  /// Underlying ML Kit face analyzer data source.
  final MlkitFaceAnalyzerDataSource dataSource;
  final ScreenBrightness _screenBrightness;
  bool _isBrightnessBoosted = false;

  @override
  Future<FaceAnalysisResult> analyzeFrame(CameraFrameInput frame) {
    return dataSource.analyze(frame);
  }

  @override
  Future<void> setMaxScreenBrightness() async {
    if (_isBrightnessBoosted) return;
    try {
      await _screenBrightness.setApplicationScreenBrightness(1);
      _isBrightnessBoosted = true;
    } on Exception catch (_) {}
  }

  @override
  Future<void> restoreScreenBrightness() async {
    if (!_isBrightnessBoosted) return;
    try {
      await _screenBrightness.resetApplicationScreenBrightness();
      _isBrightnessBoosted = false;
    } on Exception catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await restoreScreenBrightness();
    await dataSource.dispose();
  }
}
