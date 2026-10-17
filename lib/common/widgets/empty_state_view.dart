import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';

/// A reusable empty and error state view adhering to the Kora design system.
///
/// Features customizable illustrations, icons, titles, messages, and up to two
/// action buttons (primary CTA and secondary cancel/alternative CTA).
class EmptyStateView extends StatelessWidget {
  /// Creates an [EmptyStateView].
  const EmptyStateView({
    required this.title,
    required this.message,
    super.key,
    this.illustration,
    this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.padding = const EdgeInsets.all(24),
  });

  /// Primary headline for the state.
  final String title;

  /// Explanatory message for the user describing what happened and next steps.
  final String message;

  /// Optional custom illustration widget (e.g. mascot or SVG image).
  final Widget? illustration;

  /// Optional icon displayed inside a styled circular container if no
  /// illustration is provided.
  final IconData? icon;

  /// Label text for the main call to action.
  final String? primaryActionLabel;

  /// Callback executed when the primary CTA is tapped.
  final VoidCallback? onPrimaryAction;

  /// Label text for the secondary dismiss or alternative action.
  final String? secondaryActionLabel;

  /// Callback executed when the secondary CTA is tapped.
  final VoidCallback? onSecondaryAction;

  /// Internal padding for the container. Defaults to 24dp.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (illustration != null)
                          illustration!
                        else if (icon != null)
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              color: AppColors.neutral300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                icon,
                                size: 48,
                                color: AppColors.baseColor,
                                semanticLabel: title,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.h4Bold.copyWith(
                            color: AppColors.baseColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLRegular.copyWith(
                            color: AppColors.baseColor.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (primaryActionLabel != null) ...[
                          Semantics(
                            button: true,
                            label: primaryActionLabel,
                            child: PrimaryButton(
                              text: primaryActionLabel!,
                              height: 52,
                              onPressed: onPrimaryAction,
                            ),
                          ),
                        ],
                        if (secondaryActionLabel != null) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            button: true,
                            label: secondaryActionLabel,
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: TextButton(
                                onPressed: onSecondaryAction,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.baseColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Text(
                                  secondaryActionLabel!,
                                  style: AppTypography.bodyLMedium.copyWith(
                                    color: AppColors.baseColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
