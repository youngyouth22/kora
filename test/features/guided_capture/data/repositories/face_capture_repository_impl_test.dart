import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/data/datasources/mlkit_face_analyzer_datasource.dart';
import 'package:kora/features/guided_capture/data/repositories/face_capture_repository_impl.dart';
import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

class _FakeMlkitDatasource extends MlkitFaceAnalyzerDataSource {
  bool isDisposed = false;

  @override
  Future<FaceAnalysisResult> analyze(CameraFrameInput frame) async {
    return const FaceAnalysisResult(
      hasFace: false,
      imageSize: CaptureDimensions(width: 500, height: 500),
      normalizedBrightness: 0.75,
    );
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
  }
}

void main() {
  group('FaceCaptureRepositoryImpl Tests', () {
    test('delegates analyze to datasource and cleans up on dispose', () async {
      final dataSource = _FakeMlkitDatasource();
      final repository = FaceCaptureRepositoryImpl(dataSource: dataSource);

      final frame = CameraFrameInput(
        planeBytes: [Uint8List(5)],
        bytesPerRow: const [5],
        width: 500,
        height: 500,
        sensorOrientation: 0,
        isFrontCamera: true,
      );

      final result = await repository.analyzeFrame(frame);
      expect(result.hasFace, isFalse);
      expect(result.imageSize.width, 500);

      await repository.dispose();
      expect(dataSource.isDisposed, isTrue);
    });
  });
}
