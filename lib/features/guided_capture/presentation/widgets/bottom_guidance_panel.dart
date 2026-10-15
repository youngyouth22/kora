import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Bottom overlay presenting live guidance copy, readiness indicators,
/// and shutter trigger.
class BottomGuidancePanel extends StatelessWidget {
  /// Creates a [BottomGuidancePanel].
  const BottomGuidancePanel({
    required this.message,
    required this.isPositionOk,
    required this.isLightOk,
    required this.isAngleOk,
    required this.canManualCapture,
    required this.onManualCapture,
    super.key,
  });

  /// Contextual user guidance message.
  final String message;

  /// Whether face positioning is valid.
  final bool isPositionOk;

  /// Whether lighting is optimal.
  final bool isLightOk;

  /// Whether angles are straight.
  final bool isAngleOk;

  /// Whether manual shutter button is interactive.
  final bool canManualCapture;

  /// Callback when user taps shutter button.
  final VoidCallback onManualCapture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single guidance message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Semantics(
              liveRegion: true,
              label: message,
              child: Container(
                key: ValueKey<String>(message),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppGreyColors.shade1050.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.captureGuidanceText.copyWith(
                    color: AppGreyColors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Three quality metric chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IndicatorChip(label: 'Position', isOk: isPositionOk),
              const SizedBox(width: 10),
              _IndicatorChip(label: 'Light', isOk: isLightOk),
              const SizedBox(width: 10),
              _IndicatorChip(label: 'Angle', isOk: isAngleOk),
            ],
          ),
          const SizedBox(height: 22),

          // Shutter trigger button
          Semantics(
            label: canManualCapture
                ? 'Capture photo'
                : 'Capture photo disabled, align face and lighting first',
            button: true,
            enabled: canManualCapture,
            child: GestureDetector(
              onTap: canManualCapture ? onManualCapture : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: canManualCapture ? 1.0 : 0.35,
                child: Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: canManualCapture
                          ? AppPrimaryColors.shade600
                          : AppGreyColors.white,
                      width: 3.5,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppGreyColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  const _IndicatorChip({required this.label, required this.isOk});

  final String label;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label metric ${isOk ? "verified" : "pending"}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isOk
              ? AppPrimaryColors.shade600.withValues(alpha: 0.92)
              : AppGreyColors.shade1050.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOk
                ? Colors.transparent
                : AppGreyColors.white.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 15,
              color: AppGreyColors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.captureIndicatorChipText.copyWith(
                color: AppGreyColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
