import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

/// Minimalist flat AM / PM segmented switcher with live step completion badges.
///
/// Zero drop shadows, zero gradients, 1dp crisp borders.
class RoutinePeriodSwitcher extends StatelessWidget {
  /// Creates a [RoutinePeriodSwitcher].
  const RoutinePeriodSwitcher({
    required this.selectedPeriod,
    required this.amCompleted,
    required this.amTotal,
    required this.pmCompleted,
    required this.pmTotal,
    required this.onPeriodSelected,
    super.key,
  });

  /// Active period ('am' or 'pm').
  final String selectedPeriod;

  /// Completed morning steps count.
  final int amCompleted;

  /// Total morning steps count.
  final int amTotal;

  /// Completed evening steps count.
  final int pmCompleted;

  /// Total evening steps count.
  final int pmTotal;

  /// Callback when the user selects a period tab.
  final ValueChanged<String> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          _PeriodTabButton(
            label: 'Morning',
            badgeText: '$amCompleted/$amTotal',
            icon: Icons.wb_sunny_outlined,
            isSelected: selectedPeriod == RoutinePeriod.am,
            onTap: () => onPeriodSelected(RoutinePeriod.am),
          ),
          const SizedBox(width: 4),
          _PeriodTabButton(
            label: 'Evening',
            badgeText: '$pmCompleted/$pmTotal',
            icon: Icons.nightlight_outlined,
            isSelected: selectedPeriod == RoutinePeriod.pm,
            onTap: () => onPeriodSelected(RoutinePeriod.pm),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabButton extends StatelessWidget {
  const _PeriodTabButton({
    required this.label,
    required this.badgeText,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String badgeText;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label routine, $badgeText completed',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.grey50 : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: AppColors.grey300) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.primary700 : AppColors.grey700,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: isSelected
                        ? AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          )
                        : AppTypography.bodyMRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary50 : AppColors.grey200,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary200
                          : AppColors.grey300,
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTypography.bodyXsSemiBold.copyWith(
                      color: isSelected
                          ? AppColors.primary800
                          : AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
