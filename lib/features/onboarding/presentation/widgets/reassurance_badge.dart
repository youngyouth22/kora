import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Reusable badge displaying reassurance items (e.g., Private, Science-based).
class ReassuranceBadge extends StatelessWidget {
  /// Creates a [ReassuranceBadge].
  const ReassuranceBadge({
    required this.label,
    required this.icon,
    super.key,
  });

  /// The text label to display.
  final String label;

  /// Icon visual aiding comprehension without relying solely on color.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Reassurance note: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neutral600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.baseColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
