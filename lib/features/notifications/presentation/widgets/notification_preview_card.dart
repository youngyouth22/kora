import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Interactive UI preview card showcasing how the weekly skin scan notification
/// appears on the user's lock screen or notification drawer.
class NotificationPreviewCard extends StatelessWidget {
  /// Creates a [NotificationPreviewCard].
  const NotificationPreviewCard({
    this.title = 'Time for your weekly scan',
    this.body = '30 seconds, same spot as last time.',
    super.key,
  });

  /// Notification title text to preview.
  final String title;

  /// Notification body text to preview.
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neutral600.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.baseColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.neutral50,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'KORA',
                style: AppTypography.bodySSemiBold.copyWith(
                  color: AppColors.grey700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.grey600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'now',
                style: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.bodyMSemiBold.copyWith(
              color: AppColors.grey1050,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.bodySRegular.copyWith(
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}
