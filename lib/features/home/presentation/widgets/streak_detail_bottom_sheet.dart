// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';

/// Bottom sheet modal detailing current streak metrics (S03 in blueprint).
class StreakDetailBottomSheet extends StatefulWidget {
  /// Creates a [StreakDetailBottomSheet].
  const StreakDetailBottomSheet({
    this.currentStreak = 4,
    this.longestStreak = 12,
    this.freezesAvailable = 1,
    this.weeklyScanStreak = 2,
    this.weeklyJokerAvailable = true,
    super.key,
  });

  /// Current consecutive day streak count.
  final int currentStreak;

  /// Longest consecutive day streak achieved.
  final int longestStreak;

  /// Number of streak freezes currently owned (0 to 2).
  final int freezesAvailable;

  /// Consecutive weeks with completed scans.
  final int weeklyScanStreak;

  /// Whether the weekly joker is active.
  final bool weeklyJokerAvailable;

  /// Shows the sheet in [context].
  static Future<void> show(
    BuildContext context, {
    int currentStreak = 4,
    int longestStreak = 12,
    int freezesAvailable = 1,
    int weeklyScanStreak = 2,
    bool weeklyJokerAvailable = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreakDetailBottomSheet(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        freezesAvailable: freezesAvailable,
        weeklyScanStreak: weeklyScanStreak,
        weeklyJokerAvailable: weeklyJokerAvailable,
      ),
    );
  }

  @override
  State<StreakDetailBottomSheet> createState() =>
      _StreakDetailBottomSheetState();
}

class _StreakDetailBottomSheetState extends State<StreakDetailBottomSheet> {
  bool _streakReminders = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Your streak',
                style: AppTypography.h5SemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary50,
                  border: Border.all(color: AppColors.primary200, width: 2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currentStreak}',
                      style: AppTypography.h3Bold.copyWith(
                        color: AppColors.primary900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'days',
                      style: AppTypography.bodyXsMedium.copyWith(
                        color: AppColors.primary800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Longest streak: ${widget.longestStreak} days',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            KoraCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.ac_unit_rounded,
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
                          'Freezes: ${widget.freezesAvailable} of 2 available',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'A freeze protects one missed day. You earn one every 7 days.',
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KoraCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.secondary700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly scans: ${widget.weeklyScanStreak} weeks in a row',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.weeklyJokerAvailable
                              ? 'Weekly joker active · Covers 1 missed scan'
                              : 'Recharges after 4 consecutive weeks',
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Streak reminders (7:30 PM)',
                  style: AppTypography.bodyMRegular.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
                Switch.adaptive(
                  value: _streakReminders,
                  activeTrackColor: AppColors.primary700,
                  onChanged: (val) {
                    setState(() => _streakReminders = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Got it',
              height: 52,
              backgroundColor: AppColors.primary700,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
