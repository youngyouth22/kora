import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Ligne d'information (icône teintée + titre + sous-titre), conçue pour être
/// empilée dans une carte groupée avec des séparateurs.
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

  /// Rule title.
  final String title;

  /// Rule explanation.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary700.withValues(alpha: 0.09),
            ),
            child: Icon(icon, size: 21, color: AppColors.primary700),
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
                  style: AppTypography.bodyMRegular.copyWith(
                    fontSize: 13,
                    height: 1.35,
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
