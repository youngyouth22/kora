import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/domain/repositories/face_capture_repository.dart';
import 'package:kora/features/guided_capture/domain/usecases/analyze_face_frame_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/dispose_capture_session_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/evaluate_capture_readiness_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/set_screen_brightness_usecase.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_bloc.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_event.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_state.dart';

class _FakeFaceCaptureRepository implements FaceCaptureRepository {
  _FakeFaceCaptureRepository({required this.returnResult});

  FaceAnalysisResult returnResult;
  bool isBrightnessBoosted = false;
  bool isDisposed = false;

  @override
  Future<FaceAnalysisResult> analyzeFrame(CameraFrameInput frame) async {
    return returnResult;
  }

  @override
  Future<void> setMaxScreenBrightness() async {
    isBrightnessBoosted = true;
  }

  @override
  Future<void> restoreScreenBrightness() async {
    isBrightnessBoosted = false;
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
  }
}

void main() {
  late _FakeFaceCaptureRepository repository;
  late GuidedCaptureBloc bloc;

  const viewport = CaptureDimensions(width: 390, height: 844);
  const alignedAnalysis = FaceAnalysisResult(
    hasFace: true,
    faceBoundingBox: CaptureBoundingBox(
      left: 267,
      top: 635,
      width: 546,
      height: 546,
    ),
    imageSize: CaptureDimensions(width: 1080, height: 1920),
    pitch: -3,
    normalizedBrightness: 0.50,
  );

  final frame = CameraFrameInput(
    planeBytes: [Uint8List(10)],
    bytesPerRow: const [10],
    width: 1080,
    height: 1920,
    sensorOrientation: 90,
    isFrontCamera: true,
  );

  setUp(() {
    repository = _FakeFaceCaptureRepository(
      returnResult: const FaceAnalysisResult(
        hasFace: false,
        imageSize: CaptureDimensions(width: 1080, height: 1920),
        normalizedBrightness: 0.50,
      ),
    );

    bloc = GuidedCaptureBloc(
      analyzeFaceFrame: AnalyzeFaceFrameUseCase(repository),
      evaluateUseCase: const EvaluateCaptureReadinessUseCase(),
      setMaxScreenBrightness: SetMaxScreenBrightnessUseCase(repository),
      restoreScreenBrightness: RestoreScreenBrightnessUseCase(repository),
      disposeCaptureSession: DisposeCaptureSessionUseCase(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('GuidedCaptureBloc Tests', () {
    test('initial state has CaptureStatus.initial', () {
      expect(bloc.state.status, CaptureStatus.initial);
      expect(bloc.state.hasFace, isFalse);
      expect(bloc.state.isAllQualityMet, isFalse);
      expect(bloc.state.countdownProgress, 0);
    });

    test('InitializeCaptureSessionEvent transitions to scanning', () async {
      bloc.add(const InitializeCaptureSessionEvent());
      await pumpEventQueue();

      expect(bloc.state.status, CaptureStatus.scanning);
    });

    test('NoFaceTimeoutTriggeredEvent updates guidance message', () async {
      bloc.add(const NoFaceTimeoutTriggeredEvent());
      await pumpEventQueue();

      expect(bloc.state.isNoFaceTimeout, isTrue);
      expect(
        bloc.state.guidanceMessage,
        "We can't see your face — check the camera",
      );
    });

    test(
      'CameraFrameReceivedEvent throttles 1 in 3 frames and transitions to '
      'countdown when aligned',
      () async {
        repository.returnResult = alignedAnalysis;

        // Frame 1: ignored by frameCounter % 3
        bloc.add(CameraFrameReceivedEvent(frame, viewportSize: viewport));
        await pumpEventQueue();
        expect(bloc.state.hasFace, isFalse);

        // Frame 2: ignored
        bloc.add(CameraFrameReceivedEvent(frame, viewportSize: viewport));
        await pumpEventQueue();
        expect(bloc.state.hasFace, isFalse);

        // Frame 3: processed!
        bloc.add(CameraFrameReceivedEvent(frame, viewportSize: viewport));
        await pumpEventQueue();

        expect(bloc.state.hasFace, isTrue);
        expect(bloc.state.isAllQualityMet, isTrue);
        expect(bloc.state.status, CaptureStatus.countdown);
        expect(bloc.state.alignmentScore, 1);
      },
    );

    test(
      'CountdownTickedEvent with progress 1.0 triggers readyToTakePhoto',
      () async {
        repository.returnResult = alignedAnalysis;

        // Send 3 frames to reach countdown state
        bloc
          ..add(CameraFrameReceivedEvent(frame, viewportSize: viewport))
          ..add(CameraFrameReceivedEvent(frame, viewportSize: viewport))
          ..add(CameraFrameReceivedEvent(frame, viewportSize: viewport));
        await pumpEventQueue();

        expect(bloc.state.status, CaptureStatus.countdown);

        bloc.add(const CountdownTickedEvent(1));
        await pumpEventQueue();

        expect(bloc.state.status, CaptureStatus.readyToTakePhoto);
        expect(bloc.state.countdownProgress, 1);
      },
    );

    test(
      'TriggerPhotoCaptureEvent manually advances to readyToTakePhoto',
      () async {
        repository.returnResult = alignedAnalysis;

        bloc
          ..add(CameraFrameReceivedEvent(frame, viewportSize: viewport))
          ..add(CameraFrameReceivedEvent(frame, viewportSize: viewport))
          ..add(CameraFrameReceivedEvent(frame, viewportSize: viewport));
        await pumpEventQueue();

        bloc.add(const TriggerPhotoCaptureEvent());
        await pumpEventQueue();

        expect(bloc.state.status, CaptureStatus.readyToTakePhoto);
      },
    );

    test('ResetCaptureSessionEvent resets state to scanning', () async {
      bloc.add(const ResetCaptureSessionEvent());
      await pumpEventQueue();

      expect(bloc.state.status, CaptureStatus.scanning);
      expect(bloc.state.countdownProgress, 0);
    });
  });
}
