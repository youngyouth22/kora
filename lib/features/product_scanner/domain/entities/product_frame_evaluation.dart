import 'package:equatable/equatable.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// Raw OCR frame analysis result before rule evaluation.
class RawOcrFrameData extends Equatable {
  /// Creates a [RawOcrFrameData].
  const RawOcrFrameData({
    required this.fullText,
    required this.textBlockBoxes,
    required this.imageWidth,
    required this.imageHeight,
    required this.normalizedBrightness,
  });

  /// Full text detected in frame.
  final String fullText;

  /// Bounding boxes of detected text blocks.
  final List<ScannerBoundingBox> textBlockBoxes;

  /// Frame image width.
  final double imageWidth;

  /// Frame image height.
  final double imageHeight;

  /// Normalized brightness [0.0 - 1.0].
  final double normalizedBrightness;

  @override
  List<Object?> get props => [
    fullText,
    textBlockBoxes,
    imageWidth,
    imageHeight,
    normalizedBrightness,
  ];
}

/// Evaluation state of the live camera frame for product capture guidance.
class ProductFrameEvaluation extends Equatable {
  /// Creates a [ProductFrameEvaluation].
  const ProductFrameEvaluation({
    required this.isLightOk,
    required this.hasProductTextInFrame,
    required this.isTextReadableAndCloseEnough,
    required this.guidanceMessage,
  });

  /// Whether lighting is adequate.
  final bool isLightOk;

  /// Whether text is detected within the central viewfinder target.
  final bool hasProductTextInFrame;

  /// Whether the text is large enough and has sufficient character density.
  final bool isTextReadableAndCloseEnough;

  /// Human-readable guidance message.
  final String guidanceMessage;

  /// Ready to capture when all conditions are satisfied.
  bool get isReadyToCapture =>
      isLightOk && hasProductTextInFrame && isTextReadableAndCloseEnough;

  @override
  List<Object?> get props => [
    isLightOk,
    hasProductTextInFrame,
    isTextReadableAndCloseEnough,
    guidanceMessage,
  ];
}
