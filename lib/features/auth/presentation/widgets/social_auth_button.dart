import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Reusable social authentication CTA button (Apple, Google, etc.).
class SocialAuthButton extends StatelessWidget {
  /// Creates a [SocialAuthButton].
  const SocialAuthButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isLoading = false,
  });

  /// Button label text.
  final String text;

  /// Leading icon widget.
  final Widget icon;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Background color override.
  final Color? backgroundColor;

  /// Text and icon tint override.
  final Color? textColor;

  /// Outline border color override.
  final Color? borderColor;

  /// Whether a loading spinner is active.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppGreyColors.white;
    final effectiveText = textColor ?? AppGreyColors.shade1050;
    final effectiveBorder = borderColor ?? AppGreyColors.shade400;

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: text,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: effectiveBg,
            foregroundColor: effectiveText,
            disabledBackgroundColor: AppGreyColors.shade200,
            side: BorderSide(color: effectiveBorder, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: AppTypography.bodyLMedium.copyWith(
                        color: effectiveText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
