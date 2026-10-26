import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Reusable selectable card displaying a scan category option in the
/// "Make a New Scan" bottom sheet.
class ScanOptionCard extends StatelessWidget {
  /// Creates a [ScanOptionCard].
  const ScanOptionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageWidget,
    super.key,
  });

  /// Main title of the scan option (e.g., 'Face', 'Cosmetics & Food').
  final String title;

  /// Explanatory guidance text below the title.
  final String subtitle;

  /// Optional custom illustration or image. Falls back to a [Placeholder].
  final Widget? imageWidget;

  /// Tap callback executing the destination action.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary100.withValues(alpha: 0.5),
          highlightColor: AppColors.primary50,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.grey400,
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child:
                        imageWidget ??
                        const Placeholder(
                          strokeWidth: 1.5,
                          color: AppColors.primary400,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h5Bold.copyWith(
                    color: AppGreyColors.shade1050,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey700,
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
