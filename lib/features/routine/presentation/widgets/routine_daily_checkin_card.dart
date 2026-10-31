import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';

/// Minimalist card displaying today's `public.checkins` status and opening the
/// daily check-in screen when tapped.
class RoutineDailyCheckinCard extends StatelessWidget {
  /// Creates a [RoutineDailyCheckinCard].
  const RoutineDailyCheckinCard({
    required this.checkin,
    required this.onTap,
    super.key,
  });

  /// Today's check-in entity if logged.
  final SkinCheckin? checkin;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCheckin = checkin != null;

    return KoraCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: hasCheckin ? AppColors.primary50 : AppColors.neutral300,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasCheckin ? AppColors.primary200 : AppColors.grey300,
              ),
            ),
            child: Icon(
              hasCheckin
                  ? Icons.sentiment_satisfied_alt_rounded
                  : Icons.add_reaction_outlined,
              color: hasCheckin ? AppColors.primary700 : AppColors.grey800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Daily Skin Check-in',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    if (hasCheckin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary200),
                        ),
                        child: Text(
                          checkin!.skinFeelLabel,
                          style: AppTypography.bodyXsSemiBold.copyWith(
                            color: AppColors.primary800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasCheckin
                      ? (checkin!.note?.isNotEmpty ?? false
                            ? checkin!.note!
                            : 'Logged for today · Tap to update')
                      : 'How does your skin feel today? 2 taps to log.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.grey600,
          ),
        ],
      ),
    );
  }
}
