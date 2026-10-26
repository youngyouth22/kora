import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';

/// Segmented mode control with a sliding frame indicator to switch between
/// Product Photo capture and Barcode / QR scan.
class ScannerModeSegmentedControl extends StatelessWidget {
  /// Creates a [ScannerModeSegmentedControl].
  const ScannerModeSegmentedControl({
    required this.currentMode,
    required this.onModeChanged,
    super.key,
  });

  /// The active scanner capture mode.
  final ScannerCaptureMode currentMode;

  /// Callback invoked when the user selects a mode.
  final ValueChanged<ScannerCaptureMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    const double width = 230;
    const double height = 44;
    final isBarcode = currentMode == ScannerCaptureMode.barcode;

    return Semantics(
      container: true,
      label: 'Scanner mode selector: Product or Barcode',
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.grey1050.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppGreyColors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Stack(
          children: [
            // Sliding active frame indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: isBarcode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey900.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary400,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Segment options row
            Row(
              children: [
                Expanded(
                  child: _SegmentItem(
                    label: 'Product',
                    icon: Icons.camera_alt_outlined,
                    isActive: !isBarcode,
                    onTap: () => onModeChanged(ScannerCaptureMode.productPhoto),
                  ),
                ),
                Expanded(
                  child: _SegmentItem(
                    label: 'Barcode',
                    icon: Icons.qr_code_scanner_rounded,
                    isActive: isBarcode,
                    onTap: () => onModeChanged(ScannerCaptureMode.barcode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? AppGreyColors.white : AppColors.grey500;
    final iconColor = isActive ? AppColors.primary400 : AppColors.grey500;

    return Semantics(
      button: true,
      selected: isActive,
      label: '$label mode',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style:
                        (isActive
                                ? AppTypography.bodySMedium
                                : AppTypography.bodySRegular)
                            .copyWith(color: textColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
