// ignore_for_file: document_ignores

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/home/presentation/widgets/streak_detail_bottom_sheet.dart';

/// Data model representing a single day in the weekly streak bar.
class StreakDay {
  /// Creates a [StreakDay].
  const StreakDay({
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
    this.label = 'Day',
  });

  /// Day number (1 to 7).
  final int dayNumber;

  /// Whether this day has been completed in the streak.
  final bool isCompleted;

  /// Whether this day corresponds to today / current active day.
  final bool isToday;

  /// Label shown above the number (defaults to 'Day').
  final String label;

  /// Semantic label for accessibility.
  String get semanticLabel {
    if (isCompleted) {
      return '$label $dayNumber, completed';
    }
    if (isToday) {
      return '$label $dayNumber, today, active streak';
    }
    return '$label $dayNumber, upcoming';
  }
}

/// A responsive 7-day horizontal streak bar matching the Kora design system.
///
/// Displays:
/// - Completed days: Mint pastel filled circle with emerald checkmark icon.
/// - Active today: Clean elevated white circle with green text and mint glow.
/// - Upcoming days: Subtle soft grey circular indicators with grey text.
class DayStreakBar extends StatelessWidget {
  /// Creates a [DayStreakBar].
  const DayStreakBar({
    super.key,
    this.days,
    this.onDayTap,
  });

  /// List of days to display (defaults to standard 7-day streak with
  /// Day 1 completed and Day 2 active).
  final List<StreakDay>? days;

  /// Optional callback invoked when a day item is tapped.
  final ValueChanged<StreakDay>? onDayTap;

  /// Generates the standard 7-day week matching the current weekday.
  static List<StreakDay> buildCurrentWeekDays({List<bool>? completedDays}) {
    final todayWeekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    return List.generate(7, (i) {
      final dayNum = i + 1;
      final isCompleted =
          completedDays != null && i < completedDays.length && completedDays[i];
      final isToday = dayNum == todayWeekday;
      return StreakDay(
        dayNumber: dayNum,
        isCompleted: isCompleted,
        isToday: isToday,
      );
    });
  }

  /// Default 7-day week sample matching the design.
  static const List<StreakDay> defaultDays = [
    StreakDay(dayNumber: 1, isCompleted: true, isToday: false),
    StreakDay(dayNumber: 2, isCompleted: false, isToday: true),
    StreakDay(dayNumber: 3, isCompleted: false, isToday: false),
    StreakDay(dayNumber: 4, isCompleted: false, isToday: false),
    StreakDay(dayNumber: 5, isCompleted: false, isToday: false),
    StreakDay(dayNumber: 6, isCompleted: false, isToday: false),
    StreakDay(dayNumber: 7, isCompleted: false, isToday: false),
  ];

  @override
  Widget build(BuildContext context) {
    final dayList = days ?? defaultDays;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            // Responsively adjust inter-circle gap on compact screens
            final gap = availableWidth < 350 ? 5.0 : 8.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < dayList.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildDayCircle(context, dayList[i]),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCircle(BuildContext context, StreakDay day) {
    final BoxDecoration decoration;
    final Widget child;

    if (day.isCompleted) {
      // Completed day: Soft mint filled circle, emerald checkmark
      decoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary200,
      );
      child = const Center(
        child: Icon(
          Icons.check_rounded,
          size: 22,
          color: AppColors.primary700,
        ),
      );
    } else if (day.isToday) {
      // Active day: White circle with soft mint diffuse glow and green text
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppGreyColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary300.withAlpha(90),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      );
      child = Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day.label,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.primary700,
                    fontSize: 11,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${day.dayNumber}',
                  style: AppTypography.h6Regular.copyWith(
                    color: AppColors.primary700,
                    fontSize: 19,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Upcoming days: Soft light grey circle with muted grey text
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey200.withAlpha(160),
      );
      child = Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day.label,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey600,
                    fontSize: 11,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${day.dayNumber}',
                  style: AppTypography.h6Regular.copyWith(
                    color: AppColors.grey600,
                    fontSize: 19,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: day.semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (onDayTap != null) {
              onDayTap!(day);
            } else {
              unawaited(StreakDetailBottomSheet.show(context));
            }
          },
          child: Container(
            decoration: decoration,
            child: child,
          ),
        ),
      ),
    );
  }
}
