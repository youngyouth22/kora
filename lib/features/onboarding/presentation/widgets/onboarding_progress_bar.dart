import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Accessible progress bar for multi-step onboarding sequences.
///
/// Complies with Kora Rules Article 6:
/// - Semantic labels for screen readers.
/// - Minimum contrast standards.
/// - Text scaling support.
class OnboardingProgressBar extends StatelessWidget {
  /// Creates an [OnboardingProgressBar].
  const OnboardingProgressBar({
    required this.currentStep,
    required this.totalSteps,
    this.title,
    super.key,
  });

  /// The active 1-indexed step (e.g., 1 for step 1 of 6).
  final int currentStep;

  /// Total steps in this section.
  final int totalSteps;

  /// Optional section title displayed alongside the counter.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0
        ? (currentStep / totalSteps).clamp(0.0, 1.0)
        : 0.0;

    return Semantics(
      label: 'Progress: step $currentStep of $totalSteps',
      value: '${(progress * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: AppTypography.bodyMBold.copyWith(
                      color: AppColors.baseColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                '$currentStep of $totalSteps',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              width: double.infinity,
              color: AppColors.grey300,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
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
