import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';

/// Bottom controls row: gallery, shutter and "How to" guide.
class ScannerBottomControls extends StatelessWidget {
  /// Creates a [ScannerBottomControls].
  const ScannerBottomControls({
    required this.isBarcodeMode,
    required this.isReadyToCapture,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    required this.onHowToTap,
    super.key,
  });

  /// Whether barcode mode is active (affects shutter semantics).
  final bool isBarcodeMode;

  /// Highlights the shutter ring when the frame is ready.
  final bool isReadyToCapture;

  /// Opens the gallery picker.
  final VoidCallback onPickFromGallery;

  /// Triggers the shutter.
  final VoidCallback onTakePhoto;

  /// Opens the how-to guide.
  final VoidCallback onHowToTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductScannerConstants.bottomBarHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 16, 40, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              button: true,
              label: 'Pick photo from gallery',
              child: InkResponse(
                onTap: onPickFromGallery,
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.photo_outlined,
                    color: AppGreyColors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: isBarcodeMode
                  ? 'Capture barcode photo'
                  : 'Take product photo',
              child: GestureDetector(
                onTap: onTakePhoto,
                child: AnimatedContainer(
                  duration: ProductScannerConstants.frameMorphDuration,
                  width: 74,
                  height: 74,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isReadyToCapture
                          ? AppColors.primary500
                          : AppGreyColors.white.withValues(alpha: 0.40),
                      width: 3.5,
                    ),
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppGreyColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'How to scan guide',
              child: InkResponse(
                onTap: onHowToTap,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppGreyColors.white,
                              width: 1.6,
                            ),
                          ),
                          child: const Icon(
                            Icons.question_mark_rounded,
                            color: AppGreyColors.white,
                            size: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'How to',
                          style: AppTypography.bodySRegular.copyWith(
                            color: AppGreyColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
