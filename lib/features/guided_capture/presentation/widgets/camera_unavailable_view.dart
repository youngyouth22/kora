import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';

/// Error state shown when the camera cannot be opened (permission denied,
/// no front camera, hardware busy).
class CameraUnavailableView extends StatelessWidget {
  /// Creates a [CameraUnavailableView].
  const CameraUnavailableView({
    required this.onRetry,
    required this.onClose,
    super.key,
  });

  /// Retries opening the camera.
  final VoidCallback onRetry;

  /// Leaves the capture screen.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                label: 'Close and cancel capture',
                button: true,
                child: IconButton(
                  onPressed: onClose,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppGreyColors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.no_photography_outlined,
              size: 56,
              color: AppGreyColors.white,
              semanticLabel: 'Camera unavailable',
            ),
            const SizedBox(height: 20),
            Text(
              "We couldn't open your camera",
              textAlign: TextAlign.center,
              style: AppTypography.captureTipsTitle.copyWith(
                color: AppGreyColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Allow camera access for Kora in your phone settings, '
              'then try again.',
              textAlign: TextAlign.center,
              style: AppTypography.captureTipsBody.copyWith(
                color: AppGreyColors.white.withValues(alpha: 0.70),
              ),
            ),
            const Spacer(),
            Semantics(
              button: true,
              label: 'Try opening the camera again',
              child: PrimaryButton(
                text: 'Try again',
                height: 52,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
