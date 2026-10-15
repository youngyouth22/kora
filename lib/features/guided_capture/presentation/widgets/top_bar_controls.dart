import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Top overlay controls displaying help, ambient lighting pill,
/// and cancellation.
class TopBarControls extends StatelessWidget {
  /// Creates a [TopBarControls].
  const TopBarControls({
    required this.isLightOk,
    required this.isAllValid,
    required this.onCancel,
    required this.onHelp,
    super.key,
  });

  /// Whether ambient lighting is acceptable.
  final bool isLightOk;

  /// Whether all capture criteria are met.
  final bool isAllValid;

  /// Callback when user cancels capture session.
  final VoidCallback onCancel;

  /// Callback to present capture instructions modal.
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconButton(
            icon: Icons.help_rounded,
            semanticsLabel: 'Capture guide and instructions',
            onTap: onHelp,
          ),
          Semantics(
            label: isLightOk
                ? 'Lighting status optimal'
                : 'Lighting status low, adjust environment',
            child: Container(
              height: 40,
              width: 114,
              decoration: BoxDecoration(
                color: AppGreyColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppGreyColors.shade1050.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isLightOk ? 56 : 44,
                    height: 40,
                    decoration: BoxDecoration(
                      color: !isLightOk
                          ? AppErrorColors.shade50
                          : isAllValid
                          ? AppPrimaryColors.shade500
                          : AppPrimaryColors.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          size: 20,
                          color: isLightOk
                              ? AppGreyColors.shade1050
                              : AppSecondaryColors.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLightOk ? 'OK' : 'LOW',
                          style: AppTypography.capturePillText.copyWith(
                            color: AppGreyColors.shade1050,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.close_rounded,
            semanticsLabel: 'Close and cancel capture',
            onTap: onCancel,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            alignment: Alignment.center,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppGreyColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppGreyColors.shade1050, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
