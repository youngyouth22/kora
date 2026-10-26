import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/widgets/animated_viewfinder_frame.dart';
import 'package:kora/features/product_scanner/presentation/widgets/barcode_lock_overlay.dart';
import 'package:kora/features/product_scanner/presentation/widgets/cover_camera_preview.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_bottom_controls.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_guidance_pill.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_layout.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_mode_segmented_control.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_top_bar.dart';

/// Camera capture view: live preview, a viewfinder always centered between
/// the top bar and the bottom controls, the guidance hint above it, the
/// Product / Barcode selector below it, and the barcode lock-on overlay.
class CameraCaptureView extends StatelessWidget {
  /// Creates a [CameraCaptureView].
  const CameraCaptureView({
    required this.cameraController,
    required this.currentMode,
    required this.scansLeft,
    required this.isFlashOn,
    required this.isReadyToCapture,
    required this.hasTextInFrame,
    required this.guidanceMessage,
    required this.onModeChanged,
    required this.onToggleFlash,
    required this.onClose,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    required this.onHowToTap,
    this.lockedBarcode,
    super.key,
  });

  /// Active camera controller.
  final CameraController cameraController;

  /// Current capture mode (product photo or barcode).
  final ScannerCaptureMode currentMode;

  /// Remaining scan quota.
  final int scansLeft;

  /// Whether the torch/flash is enabled.
  final bool isFlashOn;

  /// True when criteria for capture/scan are met.
  final bool isReadyToCapture;

  /// True when text is detected inside frame in product mode.
  final bool hasTextInFrame;

  /// Real-time guidance prompt.
  final String guidanceMessage;

  /// Callback when user selects another capture mode.
  final ValueChanged<ScannerCaptureMode> onModeChanged;

  /// Callback when user toggles flash.
  final VoidCallback onToggleFlash;

  /// Callback when user taps close.
  final VoidCallback onClose;

  /// Callback when user taps gallery button.
  final VoidCallback onPickFromGallery;

  /// Callback when user taps shutter button.
  final VoidCallback onTakePhoto;

  /// Callback when user taps How to button.
  final VoidCallback onHowToTap;

  /// Barcode currently locked (plays the lock-on overlay when non-null).
  final DetectedBarcode? lockedBarcode;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenSize = media.size;
    final isBarcode = currentMode == ScannerCaptureMode.barcode;
    final layout = ScannerLayout.compute(
      screenSize: screenSize,
      topInset: media.padding.top,
      bottomInset: media.padding.bottom,
      isBarcode: isBarcode,
    );
    final duration = media.disableAnimations
        ? Duration.zero
        : ProductScannerConstants.frameMorphDuration;
    const curve = Curves.easeOutCubic;
    final locked = lockedBarcode;
    final preview = CoverCameraPreview(controller: cameraController);

    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        ColoredBox(color: AppColors.grey1050.withValues(alpha: 0.28)),

        // Scanning chrome — fades away when a barcode is locked.
        IgnorePointer(
          ignoring: locked != null,
          child: AnimatedOpacity(
            opacity: locked != null ? 0 : 1,
            duration: duration,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fromRect(
                  rect: layout.regionRect,
                  child: Center(
                    child: AnimatedViewfinderFrame(
                      mode: currentMode,
                      isReady: isReadyToCapture,
                      hasPartialText: hasTextInFrame,
                      size: layout.frameRect.size,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: duration,
                  curve: curve,
                  left: 24,
                  right: 24,
                  bottom: screenSize.height - layout.hintBottom,
                  child: Center(
                    child: ScannerGuidancePill(
                      message: guidanceMessage,
                      isReady: isReadyToCapture,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: duration,
                  curve: curve,
                  left: 0,
                  right: 0,
                  top: layout.segmentedTop,
                  child: Center(
                    child: ScannerModeSegmentedControl(
                      currentMode: currentMode,
                      onModeChanged: onModeChanged,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: ScannerBottomControls(
                      isBarcodeMode: isBarcode,
                      isReadyToCapture: isReadyToCapture,
                      onPickFromGallery: onPickFromGallery,
                      onTakePhoto: onTakePhoto,
                      onHowToTap: onHowToTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (locked != null)
          _buildLockOverlay(locked, layout, screenSize, preview),

        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: ScannerTopBar(
              scansLeft: scansLeft,
              isFlashOn: isFlashOn,
              showFlash: locked == null,
              onToggleFlash: onToggleFlash,
              onClose: onClose,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockOverlay(
    DetectedBarcode barcode,
    ScannerLayout layout,
    Size screenSize,
    Widget preview,
  ) {
    final detected = ScannerLayout.mapNormalizedToScreen(
      box: barcode.normalizedBox,
      screenSize: screenSize,
      previewAspectRatio: CoverCameraPreview.uprightAspectRatio(
        cameraController,
      ),
    );
    final source = ScannerLayout.barcodeSourceRect(
      detected: detected,
      fallback: layout.frameRect,
      screenSize: screenSize,
    );
    return BarcodeLockOverlay(
      key: ValueKey<String>(barcode.value),
      preview: preview,
      frameRect: layout.frameRect,
      sourceRect: source,
      targetRect: ScannerLayout.barcodeTargetRect(
        source: source,
        frame: layout.frameRect,
        screenSize: screenSize,
      ),
      barcodeValue: barcode.value,
    );
  }
}
