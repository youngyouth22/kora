import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';

/// Segmented step indicator with animated expansion for the active step,
/// matching Kora's primary color palette.
class OnboardingStepIndicator extends StatelessWidget {
  /// Creates an [OnboardingStepIndicator].
  const OnboardingStepIndicator({
    required this.currentStep,
    this.totalSteps = 3,
    this.onStepTapped,
    this.alignment = MainAxisAlignment.start,
    super.key,
  });

  /// The active step index (0-based).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  /// Optional callback when a step dot is tapped.
  final ValueChanged<int>? onStepTapped;

  /// Alignment of the dots (e.g. [MainAxisAlignment.start] for left-aligned).
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${currentStep + 1} of $totalSteps',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          return GestureDetector(
            onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isActive ? 22.0 : 6.0,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary700 : AppColors.neutral600,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
