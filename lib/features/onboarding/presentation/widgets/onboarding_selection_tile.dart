import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Accessible option tile for selection in onboarding questionnaires.
///
/// Ensures touch target >= 48dp, contrast >= 4.5:1, and distinct state cues.
class OnboardingSelectionTile extends StatelessWidget {
  /// Creates an [OnboardingSelectionTile].
  const OnboardingSelectionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.showCheckmark = false,
    this.leading,
    super.key,
  });

  /// Primary label of this option.
  final String label;

  /// Optional descriptive subtitle.
  final String? subtitle;

  /// Whether this option is currently selected.
  final bool isSelected;

  /// Callback when tapped.
  final VoidCallback onTap;

  /// Whether to show checkmark.
  final bool showCheckmark;

  /// Optional leading widget.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label${subtitle != null ? ', $subtitle' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppGreyColors.white,
            border: Border.all(
              color: isSelected
                  ? AppPrimaryColors.shade500
                  : AppGreyColors.shade400,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.transparent
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 20),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: subtitle == null
                          ? AppTypography.bodyLRegular.copyWith(
                              color: AppGreyColors.shade1050,
                            )
                          : AppTypography.h6Medium.copyWith(
                              color: AppGreyColors.shade1050,
                            ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTypography.bodyMRegular.copyWith(
                          color: AppGreyColors.shade950,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (showCheckmark) ...[
                const SizedBox(width: 20),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AppColors.primary700
                      : AppColors.neutral700,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
