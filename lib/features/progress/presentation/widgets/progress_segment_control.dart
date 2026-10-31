import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Minimalist flat segmented control + time range & smoothing filter bar for
/// the Progress screen. Zero drop shadows, zero gradients, 1dp crisp borders.
class ProgressSegmentControl extends StatelessWidget {
  /// Creates a [ProgressSegmentControl].
  const ProgressSegmentControl({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  /// Active segment index (`0` = Overall, `1` = By concern, `2` = Calendar).
  final int selectedIndex;

  /// Callback when a segment is tapped.
  final ValueChanged<int> onSelected;

  static const List<String> _segments = ['Overall', 'By concern', 'Calendar'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_segments.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${_segments[index]} tab',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(index),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.grey50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppColors.grey300)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _segments[index],
                    style: isSelected
                        ? AppTypography.bodySSemiBold.copyWith(
                            color: AppColors.primary900,
                          )
                        : AppTypography.bodySMedium.copyWith(
                            color: AppColors.grey700,
                          ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Time range filter chips (`4 wks`, `12 wks`, `All`) paired with the
/// moving-average `Smooth` toggle button.
class ProgressRangeFilterBar extends StatelessWidget {
  /// Creates a [ProgressRangeFilterBar].
  const ProgressRangeFilterBar({
    required this.selectedRange,
    required this.smoothEnabled,
    required this.onRangeSelected,
    required this.onSmoothToggled,
    super.key,
  });

  /// Active time range (`0` = 4 wks, `1` = 12 wks, `2` = All).
  final int selectedRange;

  /// Whether 3-point weighted moving average smoothing is enabled.
  final bool smoothEnabled;

  /// Callback when a range pill is tapped.
  final ValueChanged<int> onRangeSelected;

  /// Callback when the Smooth button is tapped.
  final VoidCallback onSmoothToggled;

  static const List<String> _labels = ['4 wks', '12 wks', 'All'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(_labels.length, (index) {
          final isSelected = selectedRange == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Time range ${_labels[index]}',
              child: GestureDetector(
                onTap: () => onRangeSelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary700 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary700
                          : AppColors.grey300,
                    ),
                  ),
                  child: Text(
                    _labels[index],
                    style: AppTypography.bodyXsSemiBold.copyWith(
                      color: isSelected ? AppColors.grey50 : AppColors.grey800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        Semantics(
          button: true,
          toggled: smoothEnabled,
          label: 'Toggle moving-average smoothing',
          child: GestureDetector(
            onTap: onSmoothToggled,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: smoothEnabled ? AppColors.primary50 : AppColors.grey50,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: smoothEnabled
                      ? AppColors.primary300
                      : AppColors.grey300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 14,
                    color: smoothEnabled
                        ? AppColors.primary700
                        : AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Smooth',
                    style: AppTypography.bodyXsSemiBold.copyWith(
                      color: smoothEnabled
                          ? AppColors.primary900
                          : AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
