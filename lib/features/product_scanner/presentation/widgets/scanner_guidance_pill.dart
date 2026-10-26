import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';

/// Real-time guidance hint displayed just above the viewfinder.
class ScannerGuidancePill extends StatelessWidget {
  /// Creates a [ScannerGuidancePill].
  const ScannerGuidancePill({
    required this.message,
    required this.isReady,
    super.key,
  });

  /// Guidance text.
  final String message;

  /// Whether the frame is ready (highlighted styling + icon).
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: AnimatedSwitcher(
        duration: ProductScannerConstants.frameMorphDuration,
        child: Container(
          key: ValueKey<String>(message),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isReady
                ? AppColors.primary600.withValues(alpha: 0.92)
                : AppColors.grey1050.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReady
                  ? AppColors.primary400
                  : AppGreyColors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReady) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppGreyColors.white,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppGreyColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
