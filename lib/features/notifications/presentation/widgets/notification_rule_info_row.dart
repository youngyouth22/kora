import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Informative bullet row presenting one of Kora's enterprise
/// notification principles.
class NotificationRuleInfoRow extends StatelessWidget {
  /// Creates a [NotificationRuleInfoRow].
  const NotificationRuleInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Header text.
  final String title;

  /// Subtitle description text.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary700,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey700,
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
