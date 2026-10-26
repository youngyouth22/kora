import 'dart:math' as math;
import 'dart:ui';

import 'package:kora/core/constants/product_scanner_constants.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';

/// Pure geometry for the product scanner camera screen.
///
/// Computes, in full-screen coordinates, the viewfinder region (between the
/// top bar and the bottom controls) and a viewfinder frame that is ALWAYS
/// centered in that region, with symmetric room reserved above (guidance
/// hint) and below (mode selector) so nothing overlaps the frame.
class ScannerLayout {
  /// Creates a [ScannerLayout].
  const ScannerLayout({required this.regionRect, required this.frameRect});

  /// Computes the layout for the given screen and safe-area insets.
  factory ScannerLayout.compute({
    required Size screenSize,
    required double topInset,
    required double bottomInset,
    required bool isBarcode,
  }) {
    final regionTop = topInset + ProductScannerConstants.topBarHeight;
    final regionBottom = math.max(
      regionTop,
      screenSize.height - bottomInset - ProductScannerConstants.bottomBarHeight,
    );
    final region = Rect.fromLTRB(0, regionTop, screenSize.width, regionBottom);

    const reserve =
        ProductScannerConstants.frameAccessoryGap +
        ProductScannerConstants.segmentedControlHeight;
    final maxHeight = math.max(0, region.height - 2 * reserve).toDouble();
    final maxWidth = math
        .max(
          0,
          screenSize.width - 2 * ProductScannerConstants.frameAccessoryGap,
        )
        .toDouble();

    final double width;
    final double height;
    if (isBarcode) {
      width =
          (screenSize.width * ProductScannerConstants.barcodeFrameWidthFactor)
              .clamp(
                ProductScannerConstants.barcodeFrameMinWidth,
                ProductScannerConstants.barcodeFrameMaxWidth,
              );
      height =
          (screenSize.height * ProductScannerConstants.barcodeFrameHeightFactor)
              .clamp(
                ProductScannerConstants.barcodeFrameMinHeight,
                ProductScannerConstants.barcodeFrameMaxHeight,
              );
    } else {
      width =
          (screenSize.width * ProductScannerConstants.productFrameWidthFactor)
              .clamp(
                ProductScannerConstants.productFrameMinWidth,
                ProductScannerConstants.productFrameMaxWidth,
              );
      height =
          (screenSize.height * ProductScannerConstants.productFrameHeightFactor)
              .clamp(
                ProductScannerConstants.productFrameMinHeight,
                ProductScannerConstants.productFrameMaxHeight,
              );
    }

    return ScannerLayout(
      regionRect: region,
      frameRect: Rect.fromCenter(
        center: region.center,
        width: math.min(width, maxWidth),
        height: math.min(height, maxHeight),
      ),
    );
  }

  /// Area between the top bar and the bottom controls.
  final Rect regionRect;

  /// Viewfinder frame, centered in [regionRect].
  final Rect frameRect;

  /// Y coordinate where the mode selector starts (just below the frame).
  double get segmentedTop =>
      frameRect.bottom + ProductScannerConstants.frameAccessoryGap;

  /// Y coordinate where the guidance hint ends (just above the frame).
  double get hintBottom =>
      frameRect.top - ProductScannerConstants.frameAccessoryGap;

  /// Maps a box normalized against the upright camera frame onto the screen,
  /// assuming the preview is rendered with `BoxFit.cover` full-screen.
  ///
  /// [previewAspectRatio] is the upright preview width / height.
  static Rect? mapNormalizedToScreen({
    required ScannerBoundingBox? box,
    required Size screenSize,
    required double previewAspectRatio,
  }) {
    if (box == null || previewAspectRatio <= 0 || screenSize.isEmpty) {
      return null;
    }
    final double displayWidth;
    final double displayHeight;
    if (screenSize.aspectRatio > previewAspectRatio) {
      displayWidth = screenSize.width;
      displayHeight = screenSize.width / previewAspectRatio;
    } else {
      displayHeight = screenSize.height;
      displayWidth = screenSize.height * previewAspectRatio;
    }
    final dx = (screenSize.width - displayWidth) / 2;
    final dy = (screenSize.height - displayHeight) / 2;
    return Rect.fromLTRB(
      dx + box.left * displayWidth,
      dy + box.top * displayHeight,
      dx + box.right * displayWidth,
      dy + box.bottom * displayHeight,
    );
  }

  /// Region cut out of the frozen preview around a detected code.
  ///
  /// Pads the detection, clamps it to the screen and falls back to
  /// [fallback] (the viewfinder) when the detection is missing or tiny.
  static Rect barcodeSourceRect({
    required Rect? detected,
    required Rect fallback,
    required Size screenSize,
  }) {
    if (detected == null ||
        detected.shortestSide <
            ProductScannerConstants.barcodeMinReliableSide) {
      return fallback;
    }
    final padX =
        detected.width * ProductScannerConstants.barcodeCropPaddingFactor +
        ProductScannerConstants.barcodeCropPadding;
    final padY =
        detected.height * ProductScannerConstants.barcodeCropPaddingFactor +
        ProductScannerConstants.barcodeCropPadding;
    final padded = Rect.fromLTRB(
      detected.left - padX,
      detected.top - padY,
      detected.right + padX,
      detected.bottom + padY,
    ).intersect(Offset.zero & screenSize);
    if (padded.width <= 0 || padded.height <= 0) return fallback;
    return padded;
  }

  /// Destination of the lifted crop: centered on the viewfinder, enlarged
  /// (up to [ProductScannerConstants.barcodeMaxZoom]) when small and shrunk
  /// when it would not fit. Aspect ratio is preserved.
  static Rect barcodeTargetRect({
    required Rect source,
    required Rect frame,
    required Size screenSize,
  }) {
    final maxHeight =
        screenSize.height * ProductScannerConstants.barcodeMaxCropHeightFactor;
    final fit = math.min(frame.width / source.width, maxHeight / source.height);
    final scale = math.min(ProductScannerConstants.barcodeMaxZoom, fit);
    return Rect.fromCenter(
      center: frame.center,
      width: source.width * scale,
      height: source.height * scale,
    );
  }
}
