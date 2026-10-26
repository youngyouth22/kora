import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';

/// Scanner top bar: flash toggle, remaining quota and close button.
class ScannerTopBar extends StatelessWidget {
  /// Creates a [ScannerTopBar].
  const ScannerTopBar({
    required this.scansLeft,
    required this.isFlashOn,
    required this.onToggleFlash,
    required this.onClose,
    this.showFlash = true,
    super.key,
  });

  /// Remaining scan quota.
  final int scansLeft;

  /// Whether the torch is on.
  final bool isFlashOn;

  /// Toggles the torch.
  final VoidCallback onToggleFlash;

  /// Closes the scanner.
  final VoidCallback onClose;

  /// Whether the flash toggle is shown (hidden while a code is locked).
  final bool showFlash;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductScannerConstants.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedOpacity(
              opacity: showFlash ? 1 : 0,
              duration: ProductScannerConstants.frameMorphDuration,
              child: Semantics(
                button: true,
                label: isFlashOn ? 'Turn flash off' : 'Turn flash on',
                child: IconButton(
                  onPressed: showFlash ? onToggleFlash : null,
                  icon: Icon(
                    isFlashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: AppGreyColors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Text(
                '$scansLeft scan left',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLMedium.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Close product scanner',
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Material(
                    color: AppGreyColors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClose,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.grey1050,
                          size: 20,
                        ),
                      ),
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
