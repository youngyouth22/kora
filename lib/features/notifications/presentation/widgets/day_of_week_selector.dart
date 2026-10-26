import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Interactive 7-day selector allowing the user to pick their weekly
/// scan ritual day.
class DayOfWeekSelector extends StatelessWidget {
  /// Creates a [DayOfWeekSelector].
  const DayOfWeekSelector({
    required this.selectedDay,
    required this.onDaySelected,
    super.key,
  });

  /// Currently selected day of week (1 = Monday, 7 = Sunday).
  final int selectedDay;

  /// Callback when a day is tapped.
  final ValueChanged<int> onDaySelected;

  static const List<({int day, String shortLabel, String fullLabel})> _days = [
    (day: DateTime.monday, shortLabel: 'M', fullLabel: 'Monday'),
    (day: DateTime.tuesday, shortLabel: 'T', fullLabel: 'Tuesday'),
    (day: DateTime.wednesday, shortLabel: 'W', fullLabel: 'Wednesday'),
    (day: DateTime.thursday, shortLabel: 'T', fullLabel: 'Thursday'),
    (day: DateTime.friday, shortLabel: 'F', fullLabel: 'Friday'),
    (day: DateTime.saturday, shortLabel: 'S', fullLabel: 'Saturday'),
    (day: DateTime.sunday, shortLabel: 'S', fullLabel: 'Sunday'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Scan Day',
          style: AppTypography.bodyMSemiBold.copyWith(
            color: AppColors.grey1050,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days.map((item) {
            final isSelected = selectedDay == item.day;
            return Semantics(
              button: true,
              selected: isSelected,
              label: '${item.fullLabel}, weekly scan day',
              child: InkWell(
                onTap: () => onDaySelected(item.day),
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 44,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary700
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary800
                          : AppColors.grey300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.shortLabel,
                        style: AppTypography.bodySBold.copyWith(
                          color: isSelected
                              ? AppColors.neutral50
                              : AppColors.grey900,
                        ),
                      ),
                      if (item.day == DateTime.sunday)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.neutral50
                                : AppColors.primary700,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
