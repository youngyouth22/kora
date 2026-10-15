import 'package:equatable/equatable.dart';
import 'package:kora/features/guided_capture/domain/entities/camera_frame_input.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

/// Base event for live guided face capture flow.
sealed class GuidedCaptureEvent extends Equatable {
  /// Const constructor for sub-classes.
  const GuidedCaptureEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the capture session and starts timeout monitoring.
class InitializeCaptureSessionEvent extends GuidedCaptureEvent {
  /// Creates an [InitializeCaptureSessionEvent].
  const InitializeCaptureSessionEvent();
}

/// Dispatched whenever a new video frame is received from camera stream.
class CameraFrameReceivedEvent extends GuidedCaptureEvent {
  /// Creates a [CameraFrameReceivedEvent].
  const CameraFrameReceivedEvent(this.frame, {this.viewportSize});

  /// Captured frame input data.
  final CameraFrameInput frame;

  /// Logical size of the full-screen preview the oval is drawn on.
  final CaptureDimensions? viewportSize;

  @override
  List<Object?> get props => [frame, viewportSize];
}

/// Resets the session back to scanning (e.g. when returning from review).
class ResetCaptureSessionEvent extends GuidedCaptureEvent {
  /// Creates a [ResetCaptureSessionEvent].
  const ResetCaptureSessionEvent();
}

/// Triggered when no face has been detected for 8 continuous seconds.
class NoFaceTimeoutTriggeredEvent extends GuidedCaptureEvent {
  /// Creates a [NoFaceTimeoutTriggeredEvent].
  const NoFaceTimeoutTriggeredEvent();
}

/// Emitted by the 800ms countdown timer upon full alignment.
class CountdownTickedEvent extends GuidedCaptureEvent {
  /// Creates a [CountdownTickedEvent].
  const CountdownTickedEvent(this.progress);

  /// Normalized countdown progress [0.0 to 1.0].
  final double progress;

  @override
  List<Object?> get props => [progress];
}

/// User triggered manual photo capture via shutter button.
class TriggerPhotoCaptureEvent extends GuidedCaptureEvent {
  /// Creates a [TriggerPhotoCaptureEvent].
  const TriggerPhotoCaptureEvent();
}
