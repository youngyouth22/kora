import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/routine/domain/entities/routine_compatibility_notice.dart';

/// Minimalist flat banner showing active ingredient compatibility or synergy
/// insights for the current routine period.
class RoutineCompatibilityBanner extends StatelessWidget {
  /// Creates a [RoutineCompatibilityBanner].
  const RoutineCompatibilityBanner({
    required this.notice,
    super.key,
  });

  /// Compatibility insight to render.
  final RoutineCompatibilityNotice notice;

  @override
  Widget build(BuildContext context) {
    final isCaution = notice.severity == CompatibilitySeverity.caution;
    final bgColor = isCaution ? AppColors.secondary50 : AppColors.primary50;
    final borderColor = isCaution
        ? AppColors.secondary200
        : AppColors.primary200;
    final iconColor = isCaution ? AppColors.secondary700 : AppColors.primary700;
    final titleColor = isCaution
        ? AppColors.secondary900
        : AppColors.primary900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              isCaution
                  ? Icons.info_outline_rounded
                  : Icons.auto_awesome_outlined,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: AppTypography.bodyXsBold.copyWith(
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notice.message,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey900,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
