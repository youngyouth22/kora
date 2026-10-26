import 'package:equatable/equatable.dart';

/// Base abstract event for skin analysis flow.
abstract class SkinAnalysisEvent extends Equatable {
  /// Creates a [SkinAnalysisEvent].
  const SkinAnalysisEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers image preprocessing and execution of YouCam skin analysis.
class StartSkinAnalysisEvent extends SkinAnalysisEvent {
  /// Creates a [StartSkinAnalysisEvent].
  const StartSkinAnalysisEvent({
    required this.imagePath,
    this.useMock = true,
  });

  /// Path to the captured photo.
  final String imagePath;

  /// Whether to use fixture responses to conserve API credits.
  final bool useMock;

  @override
  List<Object?> get props => [imagePath, useMock];
}

/// Dispatched internally as analysis progresses to update the animated steps
/// UI.
class AnalysisProgressStepEvent extends SkinAnalysisEvent {
  /// Creates an [AnalysisProgressStepEvent].
  const AnalysisProgressStepEvent({required this.stepIndex});

  /// Step index:
  /// 0 = Optimizing & uploading HD image...
  /// 1 = Analysing scan results...
  /// 2 = Building scan report...
  final int stepIndex;

  @override
  List<Object?> get props => [stepIndex];
}

/// Dispatched when the analysis takes longer than 20 seconds.
class LongProcessingTimeoutTriggeredEvent extends SkinAnalysisEvent {
  /// Creates a [LongProcessingTimeoutTriggeredEvent].
  const LongProcessingTimeoutTriggeredEvent();
}

/// Resets the analysis state.
class ResetSkinAnalysisEvent extends SkinAnalysisEvent {
  /// Creates a [ResetSkinAnalysisEvent].
  const ResetSkinAnalysisEvent();
}
