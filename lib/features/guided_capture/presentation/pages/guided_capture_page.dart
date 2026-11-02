import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/di/injection.dart';
import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_bloc.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_event.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_state.dart';
import 'package:kora/features/guided_capture/presentation/widgets/bottom_guidance_panel.dart';
import 'package:kora/features/guided_capture/presentation/widgets/camera_unavailable_view.dart';
import 'package:kora/features/guided_capture/presentation/widgets/capture_oval_guide.dart';
import 'package:kora/features/guided_capture/presentation/widgets/capture_tips_sheet.dart';
import 'package:kora/features/guided_capture/presentation/widgets/demo_scan_picker.dart';
import 'package:kora/features/guided_capture/presentation/widgets/top_bar_controls.dart';

/// Main screen hosting live guided capture with front camera and face
/// alignment.
class GuidedCapturePage extends StatelessWidget {
  /// Creates a [GuidedCapturePage].
  const GuidedCapturePage({
    required this.onCaptureSuccess,
    this.sessionState,
    super.key,
  });

  /// Called with the high-resolution photo. The returned future should
  /// complete when the user comes back to this screen (e.g. after review),
  /// at which point scanning resumes.
  final Future<void> Function(XFile capturedPhoto) onCaptureSuccess;

  /// Optional injected session state for first-scan guidance detection.
  final AppSessionState? sessionState;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GuidedCaptureBloc>(
      create: (_) =>
          sl<GuidedCaptureBloc>()..add(const InitializeCaptureSessionEvent()),
      child: _GuidedCaptureView(
        onCaptureSuccess: onCaptureSuccess,
        sessionState: sessionState,
      ),
    );
  }
}

class _GuidedCaptureView extends StatefulWidget {
  const _GuidedCaptureView({
    required this.onCaptureSuccess,
    this.sessionState,
  });

  final Future<void> Function(XFile capturedPhoto) onCaptureSuccess;
  final AppSessionState? sessionState;

  @override
  State<_GuidedCaptureView> createState() => _GuidedCaptureViewState();
}

class _GuidedCaptureViewState extends State<_GuidedCaptureView>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  CameraDescription? _frontCamera;
  late final GuidedCaptureBloc _bloc;
  CaptureDimensions? _viewportSize;
  var _isInitializing = false;
  var _isCapturingPhoto = false;
  var _hasCameraError = false;
  var _isTutorialVisible = false;
  var _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<GuidedCaptureBloc>();
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
    unawaited(_initCamera());
  }

  Future<void> _showTutorialSheet() async {
    if (_isTutorialVisible || !mounted) return;
    final session =
        widget.sessionState ??
        (GetIt.instance.isRegistered<AppSessionState>()
            ? GetIt.instance<AppSessionState>()
            : null);
    session?.markCaptureTipsSeen();
    setState(() => _isTutorialVisible = true);
    _bloc.add(const ResetCaptureSessionEvent());
    await CaptureTipsSheet.show(context);
    if (mounted) {
      _bloc.add(const ResetCaptureSessionEvent());
      setState(() => _isTutorialVisible = false);
    }
  }

  void _handleClose(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing || _cameraController != null) return;
    _isInitializing = true;
    if (_hasCameraError && mounted) setState(() => _hasCameraError = false);

    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('noCamera', null);

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _frontCamera = camera;

      controller = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await controller.startImageStream(_onCameraImage);

      if (!mounted || _isDisposed) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } on Exception catch (e) {
      developer.log('Camera init failed: $e', name: 'kora.guided_capture');
      await controller?.dispose();
      if (mounted) setState(() => _hasCameraError = true);
    } finally {
      _isInitializing = false;
    }
  }

  void _onCameraImage(CameraImage image) {
    final camera = _frontCamera;
    if (!mounted || _isCapturingPhoto || camera == null || _isTutorialVisible) {
      return;
    }

    _bloc.add(
      CameraFrameReceivedEvent(
        CameraFrameInput(
          planeBytes: image.planes.map((p) => p.bytes).toList(growable: false),
          bytesPerRow: image.planes
              .map((p) => p.bytesPerRow)
              .toList(growable: false),
          width: image.width,
          height: image.height,
          sensorOrientation: camera.sensorOrientation,
          isFrontCamera: camera.lensDirection == CameraLensDirection.front,
          rawFormat: image.format.raw is int ? image.format.raw as int : null,
        ),
        viewportSize: _viewportSize,
      ),
    );
  }

  Future<void> _executeHighResCapture() async {
    final controller = _cameraController;
    if (_isCapturingPhoto || controller == null) return;
    _isCapturingPhoto = true;

    try {
      await HapticFeedback.mediumImpact();
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final photo = await controller.takePicture();
      if (!mounted) return;

      // Wait until the user comes back (e.g. "Retake"), then resume.
      await widget.onCaptureSuccess(photo);
      if (!mounted || _isDisposed || _cameraController != controller) return;
      _bloc.add(const ResetCaptureSessionEvent());
      if (!controller.value.isStreamingImages) {
        await controller.startImageStream(_onCameraImage);
      }
    } on Object catch (e) {
      developer.log('Capture failed: $e', name: 'kora.guided_capture');
      if (_isDisposed || !mounted) return;
      _bloc.add(const ResetCaptureSessionEvent());
      if (_cameraController == controller) {
        try {
          if (controller.value.isInitialized &&
              !controller.value.isStreamingImages) {
            await controller.startImageStream(_onCameraImage);
          }
        } on Object catch (_) {}
      }
    } finally {
      _isCapturingPhoto = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = _cameraController;
      if (controller == null || _isCapturingPhoto) return;
      // Detach before disposing so build() never touches a dead controller.
      setState(() => _cameraController = null);
      try {
        if (controller.value.isStreamingImages) {
          unawaited(controller.stopImageStream().catchError((_) {}));
        }
      } on Object catch (_) {}
      unawaited(controller.dispose());
    } else if (state == AppLifecycleState.resumed) {
      if (!_isDisposed && mounted) {
        unawaited(_initCamera());
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          unawaited(controller.stopImageStream().catchError((_) {}));
        }
      } on Object catch (_) {}
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _viewportSize = CaptureDimensions(width: size.width, height: size.height);
    final controller = _cameraController;

    return Scaffold(
      backgroundColor: AppGreyColors.shade1050,
      body: BlocConsumer<GuidedCaptureBloc, GuidedCaptureState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == CaptureStatus.readyToTakePhoto,
        listener: (context, state) => unawaited(_executeHighResCapture()),
        builder: (context, state) {
          Widget mainContent;
          if (_hasCameraError) {
            mainContent = CameraUnavailableView(
              onRetry: () => unawaited(_initCamera()),
              onClose: () => _handleClose(context),
            );
          } else if (controller == null || !controller.value.isInitialized) {
            mainContent = const Center(
              child: CircularProgressIndicator(color: AppGreyColors.white),
            );
          } else {
            mainContent = Stack(
              fit: StackFit.expand,
              children: [
                _FullScreenCameraPreview(controller: controller),
                if (!_isTutorialVisible)
                  CaptureOvalGuide(
                    hasFace: state.hasFace,
                    alignmentScore: state.alignmentScore,
                    faceOffsetFromCenter: state.faceOffsetFromCenter,
                    isAllValid: state.isAllQualityMet,
                  ),
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TopBarControls(
                        isLightOk: state.isLightOk,
                        isAllValid: state.isAllQualityMet,
                        onCancel: () => _handleClose(context),
                        onHelp: () => unawaited(_showTutorialSheet()),
                      ),
                      if (!_isTutorialVisible)
                        BottomGuidancePanel(
                          message: state.guidanceMessage,
                          isPositionOk: state.isPositionOk,
                          isLightOk: state.isLightOk,
                          isAngleOk: state.isAngleOk,
                          canManualCapture: state.isAllQualityMet,
                          onManualCapture: () => context
                              .read<GuidedCaptureBloc>()
                              .add(const TriggerPhotoCaptureEvent()),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              mainContent,
              if (kEnableDemoScanPicker && !_isTutorialVisible)
                Positioned(
                  left: 16,
                  bottom: 24,
                  child: SafeArea(
                    child: DemoScanPicker(
                      onCaptureDemoPhoto: (photo) async {
                        await widget.onCaptureSuccess(photo);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen camera preview using a "cover" fit, which is the exact
/// projection assumed by the readiness evaluation.
class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

    // previewSize is reported in landscape; the UI is locked to portrait.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.shortestSide,
          height: previewSize.longestSide,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
