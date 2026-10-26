import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Pre-configured time slot model for notification reminders.
enum ReminderSlotType {
  /// Morning ritual slot (9:00 AM).
  morning,

  /// Evening ritual slot (8:00 PM).
  evening,

  /// Custom user-selected slot.
  custom,
}

/// Interactive selector for choosing the weekly scan reminder time slot.
class TimeSlotSelector extends StatelessWidget {
  /// Creates a [TimeSlotSelector].
  const TimeSlotSelector({
    required this.selectedHour,
    required this.selectedMinute,
    required this.onTimeSelected,
    super.key,
  });

  /// Selected hour of day (0..23).
  final int selectedHour;

  /// Selected minute of hour (0..59).
  final int selectedMinute;

  /// Callback when a new time is picked.
  final void Function(int hour, int minute) onTimeSelected;

  ReminderSlotType get _activeSlot {
    if (selectedHour == 20 && selectedMinute == 0) {
      return ReminderSlotType.evening;
    }
    if (selectedHour == 9 && selectedMinute == 0) {
      return ReminderSlotType.morning;
    }
    return ReminderSlotType.custom;
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }

  Future<void> _pickCustomTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary700,
              onPrimary: AppColors.neutral50,
              surface: AppColors.scaffoldColor,
              onSurface: AppColors.grey1050,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSlot = _activeSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Reminder Time',
          style: AppTypography.bodyMSemiBold.copyWith(
            color: AppColors.grey1050,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Evening slot (Recommended)
            Expanded(
              child: _buildSlotCard(
                context: context,
                title: 'Evening',
                subtitle: '8:00 PM',
                badge: 'Recommended',
                isSelected: activeSlot == ReminderSlotType.evening,
                onTap: () => onTimeSelected(20, 0),
              ),
            ),
            const SizedBox(width: 10),
            // Morning slot
            Expanded(
              child: _buildSlotCard(
                context: context,
                title: 'Morning',
                subtitle: '9:00 AM',
                isSelected: activeSlot == ReminderSlotType.morning,
                onTap: () => onTimeSelected(9, 0),
              ),
            ),
            const SizedBox(width: 10),
            // Custom slot
            Expanded(
              child: _buildSlotCard(
                context: context,
                title: 'Custom',
                subtitle: activeSlot == ReminderSlotType.custom
                    ? _formatTime(selectedHour, selectedMinute)
                    : 'Pick time',
                isSelected: activeSlot == ReminderSlotType.custom,
                onTap: () => _pickCustomTime(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlotCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title at $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary50 : AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary700 : AppColors.grey300,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.bodyXsSemiBold.copyWith(
                      color: AppColors.primary800,
                      fontSize: 9,
                    ),
                  ),
                ),
              Text(
                title,
                style: AppTypography.bodySSemiBold.copyWith(
                  color: isSelected ? AppColors.primary900 : AppColors.grey1000,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: isSelected ? AppColors.primary700 : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
