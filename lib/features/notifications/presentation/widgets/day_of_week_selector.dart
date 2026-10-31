import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Sept pilules de même largeur ; la pilule choisie se remplit et prend une
/// ombre colorée.
class DayOfWeekSelector extends StatelessWidget {
  /// Creates a [DayOfWeekSelector].
  const DayOfWeekSelector({
    required this.selectedDay,
    required this.onDaySelected,
    super.key,
  });

  /// Selected day, using [DateTime.monday] ... [DateTime.sunday].
  final int selectedDay;

  /// Called with the tapped day.
  final ValueChanged<int> onDaySelected;

  static const _days = <({int day, String short, String full})>[
    (day: DateTime.monday, short: 'Mon', full: 'Monday'),
    (day: DateTime.tuesday, short: 'Tue', full: 'Tuesday'),
    (day: DateTime.wednesday, short: 'Wed', full: 'Wednesday'),
    (day: DateTime.thursday, short: 'Thu', full: 'Thursday'),
    (day: DateTime.friday, short: 'Fri', full: 'Friday'),
    (day: DateTime.saturday, short: 'Sat', full: 'Saturday'),
    (day: DateTime.sunday, short: 'Sun', full: 'Sunday'),
  ];

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return Row(
      children: [
        for (var i = 0; i < _days.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _buildChip(_days[i], animDuration)),
        ],
      ],
    );
  }

  Widget _buildChip(
    ({int day, String short, String full}) d,
    Duration animDuration,
  ) {
    final selected = d.day == selectedDay;

    return Semantics(
      button: true,
      selected: selected,
      label: d.full,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onDaySelected(d.day);
        },
        child: AnimatedContainer(
          duration: animDuration,
          curve: Curves.easeOutCubic,
          height: 68,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary700 : AppColors.neutral50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary700 : AppColors.grey200,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary700.withValues(alpha: 0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: animDuration,
                style: AppTypography.bodyMSemiBold.copyWith(
                  fontSize: 13,
                  color: selected ? AppColors.neutral50 : AppColors.grey700,
                ),
                child: Text(d.short),
              ),
              const SizedBox(height: 8),
              AnimatedScale(
                scale: selected ? 1.0 : 0.0,
                duration: animDuration,
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral50,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
