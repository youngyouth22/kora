import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/widgets/reticle_corner_painter.dart';

/// Animated camera viewfinder reticle frame with 4 L-shaped corner brackets.
///
/// Morphs between a tall product portrait frame and a wide barcode frame
/// when the user switches modes. Place it inside a [Center] so the size
/// animation always stays centered.
class AnimatedViewfinderFrame extends StatelessWidget {
  /// Creates an [AnimatedViewfinderFrame].
  const AnimatedViewfinderFrame({
    required this.mode,
    required this.isReady,
    required this.hasPartialText,
    this.size,
    super.key,
  });

  /// Active capture mode determining the target frame dimensions.
  final ScannerCaptureMode mode;

  /// Whether conditions are satisfied for auto-capture / valid barcode.
  final bool isReady;

  /// Whether partial text was detected in the viewfinder zone.
  final bool hasPartialText;

  /// Explicit frame size (from the screen layout). When null, a size is
  /// derived from the screen dimensions.
  final Size? size;

  Size _fallbackSize(Size screenSize) {
    if (mode == ScannerCaptureMode.barcode) {
      return Size(
        (screenSize.width * ProductScannerConstants.barcodeFrameWidthFactor)
            .clamp(
              ProductScannerConstants.barcodeFrameMinWidth,
              ProductScannerConstants.barcodeFrameMaxWidth,
            ),
        (screenSize.height * ProductScannerConstants.barcodeFrameHeightFactor)
            .clamp(
              ProductScannerConstants.barcodeFrameMinHeight,
              ProductScannerConstants.barcodeFrameMaxHeight,
            ),
      );
    }
    return Size(
      (screenSize.width * ProductScannerConstants.productFrameWidthFactor)
          .clamp(
            ProductScannerConstants.productFrameMinWidth,
            ProductScannerConstants.productFrameMaxWidth,
          ),
      (screenSize.height * ProductScannerConstants.productFrameHeightFactor)
          .clamp(
            ProductScannerConstants.productFrameMinHeight,
            ProductScannerConstants.productFrameMaxHeight,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = size ?? _fallbackSize(MediaQuery.sizeOf(context));
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final cornerColor = isReady
        ? AppColors.primary500
        : hasPartialText
        ? AppGreyColors.white
        : AppGreyColors.white.withValues(alpha: 0.90);

    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : ProductScannerConstants.frameMorphDuration,
      curve: Curves.easeOutCubic,
      width: target.width,
      height: target.height,
      child: CustomPaint(
        painter: ReticleCornerPainter(
          bracketLength: mode == ScannerCaptureMode.barcode ? 28 : 38,
          strokeWidth: 4,
          cornerRadius: 6,
          color: cornerColor,
        ),
      ),
    );
  }
}
