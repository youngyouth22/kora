import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// Evaluates a live camera frame to provide real-time centering and
/// quality guidance to the user.
class EvaluateProductFrameUseCase {
  /// Evaluates [data] and returns a [ProductFrameEvaluation].
  ProductFrameEvaluation call(RawOcrFrameData data) {
    // 1. Check lighting
    final isLightOk = data.normalizedBrightness >= 0.28;
    if (!isLightOk) {
      return const ProductFrameEvaluation(
        isLightOk: false,
        hasProductTextInFrame: false,
        isTextReadableAndCloseEnough: false,
        guidanceMessage: 'Too dark — turn on flash or add light',
      );
    }

    // 2. Check if product text is centered in viewfinder zone
    final imgW = data.imageWidth;
    final imgH = data.imageHeight;

    if (imgW <= 0 || imgH <= 0) {
      return const ProductFrameEvaluation(
        isLightOk: true,
        hasProductTextInFrame: false,
        isTextReadableAndCloseEnough: false,
        guidanceMessage: 'Place the product front label inside the frame',
      );
    }

    final targetZone = ScannerBoundingBox(
      left: imgW * 0.10,
      top: imgH * 0.18,
      right: imgW * 0.90,
      bottom: imgH * 0.80,
    );

    final blocksInZone = data.textBlockBoxes.where((box) {
      return targetZone.contains(box.centerX, box.centerY);
    }).toList();

    if (blocksInZone.isEmpty || data.fullText.trim().length < 5) {
      return const ProductFrameEvaluation(
        isLightOk: true,
        hasProductTextInFrame: false,
        isTextReadableAndCloseEnough: false,
        guidanceMessage: 'Place the product front label inside the frame',
      );
    }

    // 3. Check proximity and text density
    var minLeft = imgW;
    var maxRight = 0.0;
    var minTop = imgH;
    var maxBottom = 0.0;

    for (final box in blocksInZone) {
      if (box.left < minLeft) minLeft = box.left;
      if (box.right > maxRight) maxRight = box.right;
      if (box.top < minTop) minTop = box.top;
      if (box.bottom > maxBottom) maxBottom = box.bottom;
    }

    final textSpanWidthRatio = (maxRight - minLeft) / imgW;
    final textSpanHeightRatio = (maxBottom - minTop) / imgH;
    final cleanCharCount = data.fullText.replaceAll(RegExp(r'\s+'), '').length;

    final isCloseEnough =
        (textSpanWidthRatio >= 0.20 || textSpanHeightRatio >= 0.16) &&
        cleanCharCount >= 10;

    if (!isCloseEnough) {
      return const ProductFrameEvaluation(
        isLightOk: true,
        hasProductTextInFrame: true,
        isTextReadableAndCloseEnough: false,
        guidanceMessage: 'Move closer so the product name is clear',
      );
    }

    return const ProductFrameEvaluation(
      isLightOk: true,
      hasProductTextInFrame: true,
      isTextReadableAndCloseEnough: true,
      guidanceMessage: 'Hold still — ready to scan',
    );
  }
}
