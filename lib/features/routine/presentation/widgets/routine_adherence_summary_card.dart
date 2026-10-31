import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';

/// Minimalist flat summary card displaying today's routine progress,
/// rolling 7-day adherence, and a shortcut to the active experiment.
class RoutineAdherenceSummaryCard extends StatelessWidget {
  /// Creates a [RoutineAdherenceSummaryCard].
  const RoutineAdherenceSummaryCard({
    required this.completedSteps,
    required this.totalSteps,
    required this.weeklyAdherenceDays,
    required this.onExperimentTap,
    super.key,
  });

  /// Completed steps in current period.
  final int completedSteps;

  /// Total steps in current period.
  final int totalSteps;

  /// Number of days completed out of 7.
  final int weeklyAdherenceDays;

  /// Callback to navigate to active experiment detail.
  final VoidCallback onExperimentTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;
    final percentage = ((weeklyAdherenceDays / 7) * 100).round();

    return KoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary200),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppColors.primary700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adherence: $weeklyAdherenceDays of 7 days '
                      '($percentage%)',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    Text(
                      'High consistency keeps your experiment verdicts '
                      'reliable.',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: 'View active Retinol 0.3% experiment details',
            child: InkWell(
              onTap: onExperimentTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: AppColors.primary700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Test: Retinol 0.3% Emulsion · Day 12/42',
                        style: AppTypography.bodyXsMedium.copyWith(
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                    Text(
                      'View test',
                      style: AppTypography.bodyXsSemiBold.copyWith(
                        color: AppColors.primary700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary700,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
