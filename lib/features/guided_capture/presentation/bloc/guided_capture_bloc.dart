// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/domain/usecases/analyze_face_frame_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/dispose_capture_session_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/evaluate_capture_readiness_usecase.dart';
import 'package:kora/features/guided_capture/domain/usecases/set_screen_brightness_usecase.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_event.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_state.dart';

/// BLoC orchestrating real-time face detection, frame evaluation,
/// and auto-shutter countdown.
class GuidedCaptureBloc extends Bloc<GuidedCaptureEvent, GuidedCaptureState> {
  /// Creates a [GuidedCaptureBloc].
  GuidedCaptureBloc({
    required AnalyzeFaceFrameUseCase analyzeFaceFrame,
    required EvaluateCaptureReadinessUseCase evaluateUseCase,
    required SetMaxScreenBrightnessUseCase setMaxScreenBrightness,
    required RestoreScreenBrightnessUseCase restoreScreenBrightness,
    required DisposeCaptureSessionUseCase disposeCaptureSession,
  }) : _analyzeFaceFrame = analyzeFaceFrame,
       _evaluateUseCase = evaluateUseCase,
       _setMaxScreenBrightness = setMaxScreenBrightness,
       _restoreScreenBrightness = restoreScreenBrightness,
       _disposeCaptureSession = disposeCaptureSession,
       super(const GuidedCaptureState()) {
    on<InitializeCaptureSessionEvent>(_onInitialize);
    on<CameraFrameReceivedEvent>(_onFrameReceived);
    on<NoFaceTimeoutTriggeredEvent>(_onNoFaceTimeout);
    on<CountdownTickedEvent>(_onCountdownTicked);
    on<TriggerPhotoCaptureEvent>(_onTriggerPhotoCapture);
    on<ResetCaptureSessionEvent>(_onReset);
  }

  final AnalyzeFaceFrameUseCase _analyzeFaceFrame;
  final EvaluateCaptureReadinessUseCase _evaluateUseCase;
  final SetMaxScreenBrightnessUseCase _setMaxScreenBrightness;
  final RestoreScreenBrightnessUseCase _restoreScreenBrightness;
  final DisposeCaptureSessionUseCase _disposeCaptureSession;

  int _frameCounter = 0;
  bool _isProcessingFrame = false;
  Timer? _noFaceTimer;
  Timer? _countdownTimer;

  void _onInitialize(
    InitializeCaptureSessionEvent event,
    Emitter<GuidedCaptureState> emit,
  ) {
    _startNoFaceTimer();
    emit(state.copyWith(status: CaptureStatus.scanning));
  }

  Future<void> _onFrameReceived(
    CameraFrameReceivedEvent event,
    Emitter<GuidedCaptureState> emit,
  ) async {
    if (state.status == CaptureStatus.readyToTakePhoto) return;

    // Analyze 1 frame out of 3 for smooth 30fps stream efficiency (< 30ms)
    _frameCounter++;
    if (_frameCounter % 3 != 0 || _isProcessingFrame) return;

    _isProcessingFrame = true;
    try {
      final analysis = await _analyzeFaceFrame(event.frame);
      final evaluation = _evaluateUseCase(
        analysis,
        viewportSize: event.viewportSize,
      );

      // Latched for the whole session: switching the screen back and forth
      // changes the light falling on the face and makes the check flicker.
      // The original brightness is restored when the session closes.
      if (evaluation.shouldBoostBrightness) {
        await _setMaxScreenBrightness();
      }
      if (isClosed) return;

      if (!evaluation.hasFace) {
        _stopCountdown();
        if (_noFaceTimer == null || !_noFaceTimer!.isActive) {
          _startNoFaceTimer();
        }

        emit(
          state.copyWith(
            status: CaptureStatus.scanning,
            hasFace: false,
            isPositionOk: false,
            isLightOk: evaluation.isLightOk,
            isAngleOk: false,
            alignmentScore: 0,
            faceOffsetFromCenter: FaceOffset.zero,
            countdownProgress: 0,
            guidanceMessage: state.isNoFaceTimeout
                ? "We can't see your face — check the camera"
                : evaluation.guidanceMessage,
          ),
        );
      } else {
        _noFaceTimer?.cancel();

        if (evaluation.isAllValid) {
          _startCountdownIfNeeded();
        } else {
          _stopCountdown();
        }

        emit(
          state.copyWith(
            status: evaluation.isAllValid
                ? CaptureStatus.countdown
                : CaptureStatus.scanning,
            hasFace: true,
            isNoFaceTimeout: false,
            isPositionOk: evaluation.isPositionOk,
            isLightOk: evaluation.isLightOk,
            isAngleOk: evaluation.isAngleOk,
            guidanceMessage: evaluation.guidanceMessage,
            alignmentScore: evaluation.alignmentScore,
            faceOffsetFromCenter: evaluation.faceOffsetFromCenter,
            countdownProgress: evaluation.isAllValid
                ? state.countdownProgress
                : 0,
          ),
        );
      }
    } on Exception catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CaptureStatus.error,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _startNoFaceTimer() {
    _noFaceTimer?.cancel();
    _noFaceTimer = Timer(const Duration(seconds: 8), () {
      if (!isClosed) add(const NoFaceTimeoutTriggeredEvent());
    });
  }

  void _onNoFaceTimeout(
    NoFaceTimeoutTriggeredEvent event,
    Emitter<GuidedCaptureState> emit,
  ) {
    if (!state.hasFace) {
      emit(
        state.copyWith(
          isNoFaceTimeout: true,
          guidanceMessage: "We can't see your face — check the camera",
        ),
      );
    }
  }

  void _startCountdownIfNeeded() {
    if (_countdownTimer != null && _countdownTimer!.isActive) return;

    const intervalMs = 40; // 20 steps of 40ms = 800ms
    const totalMs = 800;
    var elapsed = 0;

    _countdownTimer = Timer.periodic(
      const Duration(milliseconds: intervalMs),
      (timer) {
        elapsed += intervalMs;
        final progress = (elapsed / totalMs).clamp(0.0, 1.0);
        if (!isClosed) {
          add(CountdownTickedEvent(progress));
        }
        if (progress >= 1.0) {
          timer.cancel();
        }
      },
    );
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _onCountdownTicked(
    CountdownTickedEvent event,
    Emitter<GuidedCaptureState> emit,
  ) {
    if (!state.isAllQualityMet) {
      _stopCountdown();
      emit(
        state.copyWith(
          status: CaptureStatus.scanning,
          countdownProgress: 0,
        ),
      );
      return;
    }

    if (event.progress >= 1.0) {
      emit(
        state.copyWith(
          countdownProgress: 1,
          status: CaptureStatus.readyToTakePhoto,
        ),
      );
    } else {
      emit(
        state.copyWith(
          countdownProgress: event.progress,
          status: CaptureStatus.countdown,
        ),
      );
    }
  }

  void _onTriggerPhotoCapture(
    TriggerPhotoCaptureEvent event,
    Emitter<GuidedCaptureState> emit,
  ) {
    if (state.isAllQualityMet) {
      _stopCountdown();
      emit(state.copyWith(status: CaptureStatus.readyToTakePhoto));
    }
  }

  void _onReset(
    ResetCaptureSessionEvent event,
    Emitter<GuidedCaptureState> emit,
  ) {
    _stopCountdown();
    _frameCounter = 0;
    _startNoFaceTimer();
    emit(const GuidedCaptureState(status: CaptureStatus.scanning));
  }

  @override
  Future<void> close() async {
    _noFaceTimer?.cancel();
    _countdownTimer?.cancel();
    await _restoreScreenBrightness();
    await _disposeCaptureSession();
    return super.close();
  }
}
