import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Grande lecture de l'heure avec boutons -/+ (pas de 30 min), trois
/// préréglages rapides, et un rappel si l'heure tombe dans les heures calmes
/// (21 h - 8 h).
class TimeSlotSelector extends StatelessWidget {
  /// Creates a [TimeSlotSelector].
  const TimeSlotSelector({
    required this.selectedHour,
    required this.selectedMinute,
    required this.onTimeSelected,
    super.key,
  });

  /// Selected hour (0-23).
  final int selectedHour;

  /// Selected minute (0-59).
  final int selectedMinute;

  /// Called with the new (hour, minute).
  final void Function(int hour, int minute) onTimeSelected;

  static const _presets = <({String label, int hour, int minute})>[
    (label: 'Morning', hour: 8, minute: 0),
    (label: 'Midday', hour: 12, minute: 30),
    (label: 'Evening', hour: 20, minute: 0),
  ];

  static ({String time, String period}) _format(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return (time: '$h:${minute.toString().padLeft(2, '0')}', period: period);
  }

  bool get _inQuietHours => selectedHour >= 21 || selectedHour < 8;

  void _shift(int deltaMinutes) {
    unawaited(HapticFeedback.selectionClick());
    final total = selectedHour * 60 + selectedMinute + deltaMinutes;
    final wrapped = ((total % 1440) + 1440) % 1440;
    onTimeSelected(wrapped ~/ 60, wrapped % 60);
  }

  @override
  Widget build(BuildContext context) {
    final f = _format(selectedHour, selectedMinute);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withValues(alpha: 0.06),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                label: 'Earlier by 30 minutes',
                onTap: () => _shift(-30),
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  label: 'Reminder time ${f.time} ${f.period}',
                  excludeSemantics: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Row(
                      key: ValueKey('${f.time}${f.period}'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          f.time,
                          style: AppTypography.h4Bold.copyWith(
                            fontSize: 40,
                            height: 1.1,
                            letterSpacing: -1,
                            color: AppColors.grey1050,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          f.period,
                          style: AppTypography.bodyMSemiBold.copyWith(
                            fontSize: 16,
                            color: AppColors.primary700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                label: 'Later by 30 minutes',
                onTap: () => _shift(30),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < _presets.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _buildPreset(_presets[i])),
              ],
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _inQuietHours
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.bedtime_outlined,
                          size: 16,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This falls in quiet hours (9 PM – 8 AM). '
                            'Pick a time outside that window.',
                            style: AppTypography.bodyMRegular.copyWith(
                              fontSize: 12.5,
                              height: 1.35,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildPreset(({String label, int hour, int minute}) p) {
    final selected = p.hour == selectedHour && p.minute == selectedMinute;
    final f = _format(p.hour, p.minute);

    return Semantics(
      button: true,
      selected: selected,
      label: '${p.label}, ${f.time} ${f.period}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTimeSelected(p.hour, p.minute);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary700.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary700 : AppColors.grey200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                p.label,
                style: AppTypography.bodyMSemiBold.copyWith(
                  fontSize: 13,
                  color: selected ? AppColors.primary900 : AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${f.time} ${f.period}',
                style: AppTypography.bodyMRegular.copyWith(
                  fontSize: 11.5,
                  color: selected ? AppColors.primary700 : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary700.withValues(alpha: 0.08),
          ),
          child: Icon(icon, color: AppColors.primary700, size: 24),
        ),
      ),
    );
  }
}
