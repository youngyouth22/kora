// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_report.dart';

/// Styled chip displaying a profile attribute (skin type, goal, strength, sensitivity).
class ProfileChipView extends StatelessWidget {
  /// Creates a [ProfileChipView].
  const ProfileChipView({required this.chip, super.key});

  /// The profile chip entity.
  final ProfileChip chip;

  @override
  Widget build(BuildContext context) {
    final style = _styleForKind(chip.kind);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 16, color: style.accentColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chip.label,
                style: AppTypography.bodySSemiBold.copyWith(
                  color: style.textColor,
                  height: 1.1,
                ),
              ),
              if (chip.sublabel.isNotEmpty)
                Text(
                  chip.sublabel,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: style.sublabelColor,
                    height: 1.1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static _ChipStyle _styleForKind(String kind) {
    switch (kind) {
      case 'skin_type':
        return const _ChipStyle(
          backgroundColor: AppPrimaryColors.shade50,
          borderColor: AppPrimaryColors.shade200,
          accentColor: AppPrimaryColors.shade700,
          textColor: AppPrimaryColors.shade900,
          sublabelColor: AppPrimaryColors.shade600,
          icon: Icons.water_drop_outlined,
        );
      case 'goal':
        return const _ChipStyle(
          backgroundColor: AppSecondaryColors.shade50,
          borderColor: AppSecondaryColors.shade200,
          accentColor: AppSecondaryColors.shade700,
          textColor: AppSecondaryColors.shade900,
          sublabelColor: AppSecondaryColors.shade700,
          icon: Icons.track_changes_outlined,
        );
      case 'concern':
        return const _ChipStyle(
          backgroundColor: AppNeutralColors.shade400,
          borderColor: AppNeutralColors.shade600,
          accentColor: AppGreyColors.shade800,
          textColor: AppGreyColors.shade1050,
          sublabelColor: AppGreyColors.shade700,
          icon: Icons.verified_outlined,
        );
      case 'sensitivity':
      default:
        return const _ChipStyle(
          backgroundColor: AppNeutralColors.shade300,
          borderColor: AppNeutralColors.shade500,
          accentColor: AppPrimaryColors.shade600,
          textColor: AppGreyColors.shade1050,
          sublabelColor: AppGreyColors.shade700,
          icon: Icons.spa_outlined,
        );
    }
  }
}

class _ChipStyle {
  const _ChipStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.textColor,
    required this.sublabelColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color textColor;
  final Color sublabelColor;
  final IconData icon;
}
