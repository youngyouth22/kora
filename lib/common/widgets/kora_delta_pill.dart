// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// A minimalist status and variation indicator pill (e.g. "▲ +4", "▼ -3", "stable").
class KoraDeltaPill extends StatelessWidget {
  /// Creates a [KoraDeltaPill].
  const KoraDeltaPill({
    required this.delta,
    super.key,
    this.isStable = false,
  });

  /// Signed variation value. Positive means improvement.
  final int delta;

  /// Whether the variation is within the noise threshold (stable).
  final bool isStable;

  @override
  Widget build(BuildContext context) {
    final isImprovement = delta > 0;

    final Color bgColor;
    final Color textColor;
    final String label;

    if (isStable || delta == 0) {
      bgColor = AppColors.grey200;
      textColor = AppColors.grey800;
      label = 'stable';
    } else if (isImprovement) {
      bgColor = AppColors.primary100;
      textColor = AppColors.primary900;
      label = '▲ +$delta';
    } else {
      bgColor = AppColors.error100;
      textColor = AppColors.error700;
      label = '▼ $delta';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTypography.bodyXsSemiBold.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
