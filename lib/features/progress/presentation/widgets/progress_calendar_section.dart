// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';

/// Complete Calendar & Streak section (S02 in blueprint) backed by
/// `public.activity_days`, `public.streak_state`, and `public.milestones`.
class ProgressCalendarSection extends StatelessWidget {
  /// Creates a [ProgressCalendarSection].
  const ProgressCalendarSection({
    required this.activeMonth,
    required this.selectedDay,
    required this.activityDays,
    required this.streakState,
    required this.milestones,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
    required this.onScanInspectTap,
    super.key,
  });

  /// Active calendar month (`YYYY-MM-01`).
  final DateTime activeMonth;

  /// Selected day number (`1..31`).
  final int? selectedDay;

  /// Activity day records for [activeMonth].
  final List<ProgressActivityDay> activityDays;

  /// Current streak state (`public.streak_state`).
  final ProgressStreakState? streakState;

  /// Unlocked milestones (`public.milestones`).
  final List<ProgressMilestone> milestones;

  /// Navigates to the previous month.
  final VoidCallback onPreviousMonth;

  /// Navigates to the next month.
  final VoidCallback onNextMonth;

  /// Selects a specific day cell (`1..31`).
  final ValueChanged<int> onDaySelected;

  /// Opens `/scan/result/:scanId` when a scan day detail card is tapped.
  final ValueChanged<String> onScanInspectTap;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  ProgressActivityDay? _findActivity(int day) {
    for (final item in activityDays) {
      if (item.day.day == day &&
          item.day.month == activeMonth.month &&
          item.day.year == activeMonth.year) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(activeMonth.year, activeMonth.month);
    final nextMonth = DateTime(activeMonth.year, activeMonth.month + 1);
    final daysInMonth = nextMonth.difference(firstDayOfMonth).inDays;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday .. 7 = Sunday

    final activeCount = activityDays.where((a) => a.actions > 0).length;
    final scanCount = activityDays.where((a) => a.hadScan).length;
    final freezeCount = activityDays.where((a) => a.isFreeze).length;

    final selectedActivity = selectedDay != null
        ? _findActivity(selectedDay!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (streakState != null) ...[
          _StreakBannerCard(streakState: streakState!),
          const SizedBox(height: 14),
        ],
        KoraCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_monthNames[activeMonth.month - 1]} ${activeMonth.year}',
                    style: AppTypography.bodyLBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Previous month',
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: onPreviousMonth,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Next month',
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: onNextMonth,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                  return SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final dayNumber = index - firstWeekday + 2;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final activity = _findActivity(dayNumber);
                  final isScanDay = activity?.hadScan ?? false;
                  final isFreezeDay = activity?.isFreeze ?? false;
                  final isActive = (activity?.actions ?? 0) > 0;
                  final isSelected = selectedDay == dayNumber;

                  var cellColor = Colors.transparent;
                  var textColor = AppColors.grey900;
                  Border? cellBorder;

                  if (isSelected) {
                    cellBorder = Border.all(
                      color: AppColors.primary700,
                      width: 2,
                    );
                  } else if (isActive || isScanDay || isFreezeDay) {
                    cellBorder = Border.all(color: AppColors.grey300);
                  }

                  if (isScanDay) {
                    cellColor = AppColors.primary100;
                    textColor = AppColors.primary900;
                  } else if (isFreezeDay) {
                    cellColor = AppColors.secondary100;
                    textColor = AppColors.secondary900;
                  } else if (isActive) {
                    cellColor = AppColors.neutral300;
                  }

                  return GestureDetector(
                    onTap: () => onDaySelected(dayNumber),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(8),
                        border: cellBorder,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: AppTypography.bodyXsSemiBold.copyWith(
                              color: textColor,
                            ),
                          ),
                          if (isActive && !isScanDay)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary700,
                              ),
                            ),
                          if (isScanDay)
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 10,
                              color: AppColors.primary800,
                            ),
                          if (isFreezeDay)
                            const Icon(
                              Icons.ac_unit_rounded,
                              size: 10,
                              color: AppColors.secondary800,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem('Routine logged', AppColors.primary700),
                  _buildLegendItem('Weekly HD scan', AppColors.primary200),
                  _buildLegendItem('Freeze protected', AppColors.secondary300),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (selectedDay != null)
          _SelectedDayDetailCard(
            monthName: _monthNames[activeMonth.month - 1],
            year: activeMonth.year,
            dayNumber: selectedDay!,
            activity: selectedActivity,
            onScanInspectTap: onScanInspectTap,
          ),
        const SizedBox(height: 12),
        KoraCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMonthStat('$activeCount', 'Active days'),
              Container(width: 1, height: 32, color: AppColors.grey300),
              _buildMonthStat('$scanCount', 'Weekly scans'),
              Container(width: 1, height: 32, color: AppColors.grey300),
              _buildMonthStat('$freezeCount', 'Freeze used'),
            ],
          ),
        ),
        if (milestones.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Unlocked Milestones',
            style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
          ),
          const SizedBox(height: 10),
          ...milestones.map((m) => _MilestoneCard(milestone: m)),
        ],
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }

  Widget _buildMonthStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        Text(
          label,
          style: AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}

class _StreakBannerCard extends StatelessWidget {
  const _StreakBannerCard({required this.streakState});

  final ProgressStreakState streakState;

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      backgroundColor: AppColors.primary50,
      borderColor: AppColors.primary200,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary200),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_fire_department_outlined,
              color: AppColors.primary700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streakState.currentStreak}-Day Routine Streak · ${streakState.weeklyScanStreak}-Week Scan Streak',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Longest: ${streakState.longestStreak} days · ${streakState.freezesAvailable} Freezes banked · Weekly Joker ${streakState.weeklyJokerAvailable ? "ready" : "used"}',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey800,
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

class _SelectedDayDetailCard extends StatelessWidget {
  const _SelectedDayDetailCard({
    required this.monthName,
    required this.year,
    required this.dayNumber,
    required this.activity,
    required this.onScanInspectTap,
  });

  final String monthName;
  final int year;
  final int dayNumber;
  final ProgressActivityDay? activity;
  final ValueChanged<String> onScanInspectTap;

  @override
  Widget build(BuildContext context) {
    final hasScan = activity?.hadScan ?? false;
    final scanId = activity?.scanId;

    return KoraCard(
      backgroundColor: hasScan ? AppColors.primary50 : AppColors.grey50,
      borderColor: hasScan ? AppColors.primary200 : AppColors.grey300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName $dayNumber, $year',
                style: AppTypography.bodyLBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              if (hasScan && scanId != null)
                GestureDetector(
                  onTap: () => onScanInspectTap(scanId),
                  child: Text(
                    'Open Scan Report →',
                    style: AppTypography.bodyXsBold.copyWith(
                      color: AppColors.primary800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            activity?.summaryNote ?? 'No logged activity on this date. Fresh start — your history is intact.',
            style: AppTypography.bodySRegular.copyWith(
              color: AppColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.milestone});

  final ProgressMilestone milestone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: KoraCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary200),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.verified_outlined,
                size: 18,
                color: AppColors.primary700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  Text(
                    milestone.subtitle,
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
    );
  }
}
