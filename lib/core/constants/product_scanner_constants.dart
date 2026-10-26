/// Layout, timing and geometry constants for the product scanner camera.
abstract final class ProductScannerConstants {
  /// Minimum time the "barcode locked" animation stays on screen before the
  /// result is revealed, so the lock-on feedback never flashes by.
  static const Duration minBarcodeLockDuration = Duration(milliseconds: 1400);

  /// Duration of the viewfinder morph between Product and Barcode modes.
  static const Duration frameMorphDuration = Duration(milliseconds: 300);

  /// Duration of the barcode lock-on sequence (snap + lift & zoom).
  static const Duration barcodeLockDuration = Duration(milliseconds: 750);

  /// Duration of one laser sweep over the locked barcode crop.
  static const Duration barcodeLaserSweepDuration = Duration(
    milliseconds: 1100,
  );

  /// Height reserved for the top bar (flash, quota, close).
  static const double topBarHeight = 64;

  /// Height reserved for the bottom controls row (gallery, shutter, how-to).
  static const double bottomBarHeight = 122;

  /// Height of the Product / Barcode segmented control.
  static const double segmentedControlHeight = 44;

  /// Vertical gap between the viewfinder and the segmented control / hint.
  static const double frameAccessoryGap = 20;

  /// Product mode viewfinder minimum / maximum width.
  static const double productFrameMinWidth = 240;

  /// Product mode viewfinder maximum width.
  static const double productFrameMaxWidth = 320;

  /// Product mode viewfinder minimum height.
  static const double productFrameMinHeight = 260;

  /// Product mode viewfinder maximum height.
  static const double productFrameMaxHeight = 400;

  /// Barcode mode viewfinder minimum width.
  static const double barcodeFrameMinWidth = 260;

  /// Barcode mode viewfinder maximum width.
  static const double barcodeFrameMaxWidth = 320;

  /// Barcode mode viewfinder minimum height.
  static const double barcodeFrameMinHeight = 130;

  /// Barcode mode viewfinder maximum height.
  static const double barcodeFrameMaxHeight = 160;

  /// Product frame width as a fraction of the screen width.
  static const double productFrameWidthFactor = 0.78;

  /// Product frame height as a fraction of the screen height.
  static const double productFrameHeightFactor = 0.48;

  /// Barcode frame width as a fraction of the screen width.
  static const double barcodeFrameWidthFactor = 0.82;

  /// Barcode frame height as a fraction of the screen height.
  static const double barcodeFrameHeightFactor = 0.20;

  /// Relative padding added around a detected barcode before cropping.
  static const double barcodeCropPaddingFactor = 0.12;

  /// Absolute padding (logical px) added around a detected barcode crop.
  static const double barcodeCropPadding = 10;

  /// Below this size (logical px) a detected box is considered unreliable
  /// and the viewfinder rectangle is used instead.
  static const double barcodeMinReliableSide = 24;

  /// Maximum zoom applied when enlarging a small barcode crop.
  static const double barcodeMaxZoom = 2;

  /// Maximum crop height as a fraction of the screen height.
  static const double barcodeMaxCropHeightFactor = 0.32;

  /// Corner radius of the lifted barcode crop.
  static const double barcodeCropRadius = 14;
}
