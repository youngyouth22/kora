import 'package:equatable/equatable.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';

/// Status enum for the skin analysis flow.
enum SkinAnalysisStatus {
  /// Initial idle state.
  initial,

  /// Preprocessing and optimizing the HD image in an isolate.
  preprocessing,

  /// Sending image and awaiting YouCam AI algorithm detection.
  analyzing,

  /// Parsing detection masks, scores, and generating comprehensive report.
  buildingReport,

  /// Analysis finished successfully and result is available.
  success,

  /// Analysis failed with an error message.
  failure,
}

/// State representing the progress and outcome of the skin analysis.
class SkinAnalysisState extends Equatable {
  /// Creates a [SkinAnalysisState].
  const SkinAnalysisState({
    this.status = SkinAnalysisStatus.initial,
    this.currentStepIndex = 0,
    this.isTakingLonger = false,
    this.result,
    this.preprocessedPath,
    this.errorMessage,
  });

  /// Current lifecycle status.
  final SkinAnalysisStatus status;

  /// Active step index:
  /// - 0: Optimizing & uploading HD image
  /// - 1: Analysing scan results
  /// - 2: Building scan report
  final int currentStepIndex;

  /// Whether the process has taken more than 20 seconds.
  final bool isTakingLonger;

  /// Final report when [status] is [SkinAnalysisStatus.success].
  final SkinAnalysisResult? result;

  /// Path to the optimized HD image.
  final String? preprocessedPath;

  /// Error description when [status] is [SkinAnalysisStatus.failure].
  final String? errorMessage;

  /// Returns a copy of [SkinAnalysisState] with updated fields.
  SkinAnalysisState copyWith({
    SkinAnalysisStatus? status,
    int? currentStepIndex,
    bool? isTakingLonger,
    SkinAnalysisResult? result,
    String? preprocessedPath,
    String? errorMessage,
  }) {
    return SkinAnalysisState(
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isTakingLonger: isTakingLonger ?? this.isTakingLonger,
      result: result ?? this.result,
      preprocessedPath: preprocessedPath ?? this.preprocessedPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentStepIndex,
    isTakingLonger,
    result,
    preprocessedPath,
    errorMessage,
  ];
}
