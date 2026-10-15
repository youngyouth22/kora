import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// A reusable primary call-to-action button adhering to the Kora
/// design system.
///
/// Features built-in loading indicator support, disabled states, optional
/// icons, default linear gradient styling ([AppGradients.primary]),
/// customizable gradients, solid background color overrides, and an explicit
/// [isDisabled] toggle, while preserving the Material ripple/splash effect and
/// design tokens.
class PrimaryButton extends StatelessWidget {
  /// Creates a [PrimaryButton].
  ///
  /// * [text] is the required label displayed on the button.
  /// * [onPressed] is executed on tap. When null, the button is disabled.
  /// * [isLoading] toggles a progress indicator and disables tap interactions.
  /// * [isDisabled] explicitly disables the button: removes gradients and
  ///   borders, applies [AppPrimaryColors.shade100], preserves label text
  ///   color, and blocks tap interactions.
  /// * [icon] optionally places an icon alongside the label.
  /// * [iconAlignment] controls whether the icon appears before or after the
  ///   text.
  /// * [backgroundColor] overrides the background with a solid color,
  ///   canceling any default or explicit gradient.
  /// * [textColor] overrides default label and icon color.
  /// * [gradient] customizes the background gradient. Defaults to
  ///   [AppGradients.primary] when [backgroundColor] is null and not disabled.
  /// * [borderRadius], [height], and [width] customize button geometry.
  /// * [textStyle] overrides the typography token.
  /// * [side] configures an optional border outline (e.g. 1px width).
  const PrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.gradient,
    this.borderRadius = 100,
    this.height = 46,
    this.width = double.infinity,
    this.textStyle,
    this.iconAlignment,
    this.side,
  });

  /// The text to display on the button.
  final String text;

  /// The callback to execute when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is explicitly disabled.
  final bool isDisabled;

  /// An optional icon to display next to the text.
  final Widget? icon;

  /// An optional solid background color. When provided, it cancels any
  /// default or explicit [gradient].
  final Color? backgroundColor;

  /// The text color of the button.
  final Color? textColor;

  /// An optional background gradient (e.g. [LinearGradient]).
  /// Defaults to [AppGradients.primary] when [backgroundColor] is null.
  final Gradient? gradient;

  /// The border radius of the button.
  final double borderRadius;

  /// The height of the button.
  final double height;

  /// The width of the button.
  final double width;

  /// The text style of the button.
  final TextStyle? textStyle;

  /// The border side of the button.
  final BorderSide? side;

  /// The alignment of the icon relative to the button label.
  final IconAlignment? iconAlignment;

  @override
  Widget build(BuildContext context) {
    final effectivelyDisabled = isDisabled || (onPressed == null && !isLoading);
    final hasSolidBackground = backgroundColor != null;
    final effectiveGradient = (hasSolidBackground || effectivelyDisabled)
        ? null
        : (gradient ?? AppGradients.primary);
    final effectiveBackgroundColor =
        backgroundColor ?? AppPrimaryColors.shade600;
    final effectiveTextColor = textColor ?? AppGreyColors.white;
    final effectiveSide = effectivelyDisabled
        ? null
        : side ?? const BorderSide(color: AppPrimaryColors.shade500);

    Widget button = ElevatedButton.icon(
      onPressed: effectivelyDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveGradient != null
            ? Colors.transparent
            : effectiveBackgroundColor,
        foregroundColor: effectiveTextColor,
        disabledBackgroundColor: AppPrimaryColors.shade100,
        disabledForegroundColor: effectiveTextColor,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        side: effectiveSide,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: effectiveSide ?? BorderSide.none,
        ),
        elevation: 0,
      ),
      icon: icon,
      iconAlignment: iconAlignment,
      label: isLoading
          ? const CircularProgressIndicator()
          : Text(
              text,
              style:
                  textStyle ??
                  AppTypography.bodyXlSemiBold.copyWith(
                    color: effectiveTextColor,
                  ),
            ),
    );

    if (effectiveGradient != null) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: button,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}

/// Preview for [PrimaryButton] with default gradient.
@Preview(name: 'Default Gradient Button', group: 'UI Components')
Widget primaryButtonPreview() {
  return const PrimaryButton(
    text: 'Main Button',
  );
}

/// Preview for [PrimaryButton] in disabled state.
@Preview(name: 'Disabled Button', group: 'UI Components')
Widget disabledPrimaryButtonPreview() {
  return const PrimaryButton(
    text: 'Disabled Button',
    isDisabled: true,
  );
}

/// Preview for [PrimaryButton] with an overridden solid background.
@Preview(name: 'Solid Color Button', group: 'UI Components')
Widget solidPrimaryButtonPreview() {
  return const PrimaryButton(
    text: 'Solid Button',
    backgroundColor: AppColors.error,
  );
}

/// Preview for [PrimaryButton] with custom gradient and border.
@Preview(name: 'Custom Gradient & Border Button', group: 'UI Components')
Widget customGradientPrimaryButtonPreview() {
  return const PrimaryButton(
    text: 'Custom Gradient',
    gradient: LinearGradient(
      colors: [AppPrimaryColors.shade400, AppPrimaryColors.shade800],
    ),
    side: BorderSide(
      color: AppPrimaryColors.shade900,
    ),
  );
}
