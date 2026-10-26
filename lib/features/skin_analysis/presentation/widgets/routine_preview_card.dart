// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_report.dart';

/// Card widget presenting a recommended skincare routine step.
class RoutinePreviewCard extends StatelessWidget {
  /// Creates a [RoutinePreviewCard].
  const RoutinePreviewCard({required this.step, super.key});

  /// The routine step details.
  final RoutineStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppNeutralColors.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppPrimaryColors.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: AppTypography.bodySBold.copyWith(
                      color: AppPrimaryColors.shade800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.name,
                  style: AppTypography.bodyLSemiBold.copyWith(
                    color: AppGreyColors.shade1050,
                  ),
                ),
              ),
              _buildTimeBadge(step.timeOfDay),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.instruction,
            style: AppTypography.bodySRegular.copyWith(
              color: AppGreyColors.shade800,
              height: 1.4,
            ),
          ),
          if (step.why.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppNeutralColors.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppPrimaryColors.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.why,
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppGreyColors.shade700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (step.ingredientIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: step.ingredientIds.map((id) {
                final readable = id.replaceAll('_', ' ');
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppPrimaryColors.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppPrimaryColors.shade200),
                  ),
                  child: Text(
                    '#$readable',
                    style: AppTypography.bodyXsMedium.copyWith(
                      color: AppPrimaryColors.shade800,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeBadge(String timeOfDay) {
    String label;
    IconData icon;
    Color color;

    switch (timeOfDay.toLowerCase()) {
      case 'am':
        label = 'AM';
        icon = Icons.wb_sunny_outlined;
        color = AppSecondaryColors.shade600;
      case 'pm':
        label = 'PM';
        icon = Icons.nightlight_outlined;
        color = AppPrimaryColors.shade700;
      case 'both':
      default:
        label = 'AM & PM';
        icon = Icons.all_inclusive;
        color = AppPrimaryColors.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodyXsBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
