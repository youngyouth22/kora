import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Bottom sheet content with tips for a good scan.
class CaptureTipsSheet extends StatelessWidget {
  /// Creates a [CaptureTipsSheet].
  const CaptureTipsSheet({super.key});

  /// Shows the tips sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppGreyColors.shade1000,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CaptureTipsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tips for a perfect scan',
              style: AppTypography.captureTipsTitle.copyWith(
                color: AppGreyColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• Face a window or natural light source.\n'
              '• Remove glasses and pull hair away from your forehead.\n'
              '• Look straight at the camera and hold still.',
              style: AppTypography.captureTipsBody.copyWith(
                color: AppGreyColors.white.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
