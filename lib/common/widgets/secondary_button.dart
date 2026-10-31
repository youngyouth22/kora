import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// A reusable secondary outline action button adhering to the Kora
/// design system.
///
/// Features built-in loading indicator support, disabled states, optional
/// icons, default outline styling ([AppPrimaryColors.shade500]),
/// customizable border outlines, background color overrides, built-in
/// [Semantics] accessibility support, and an explicit [isDisabled] toggle.
class SecondaryButton extends StatelessWidget {
  /// Creates a [SecondaryButton].
  ///
  /// * [text] is the required label displayed on the button.
  /// * [onPressed] is executed on tap. When null, the button is disabled.
  /// * [isLoading] toggles a progress indicator and disables tap interactions.
  /// * [isDisabled] explicitly disables the button: removes borders,
  ///   applies [AppPrimaryColors.shade100] background, preserves label text
  ///   color, and blocks tap interactions.
  /// * [icon] optionally places an icon alongside the label.
  /// * [iconAlignment] controls whether the icon appears before or after the
  ///   text.
  /// * [backgroundColor] overrides the background (defaults to transparent).
  /// * [textColor] overrides default label and icon color
  ///   ([AppPrimaryColors.shade600]).
  /// * [borderRadius], [height], and [width] customize button geometry.
  /// * [textStyle] overrides the typography token.
  /// * [side] configures an optional border outline (defaults to 1px
  ///   [AppPrimaryColors.shade500]).
  /// * [semanticLabel] optional accessibility label overriding [text].
  const SecondaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 100,
    this.height = 46,
    this.width = double.infinity,
    this.textStyle,
    this.iconAlignment,
    this.side,
    this.semanticLabel,
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

  /// An optional solid background color. Defaults to [Colors.transparent].
  final Color? backgroundColor;

  /// The text and icon color of the button. Defaults to
  /// [AppPrimaryColors.shade600].
  final Color? textColor;

  /// The border radius of the button. Defaults to 100 (pill shape).
  final double borderRadius;

  /// The height of the button. Defaults to 46.
  final double height;

  /// The width of the button. Defaults to [double.infinity].
  final double width;

  /// The text style of the button. Defaults to [AppTypography.bodyXlSemiBold].
  final TextStyle? textStyle;

  /// The border side of the button. Defaults to 1px
  /// [AppPrimaryColors.shade500].
  final BorderSide? side;

  /// The alignment of the icon relative to the button label.
  final IconAlignment? iconAlignment;

  /// An optional semantic label for accessibility / screen readers.
  /// Defaults to [text].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectivelyDisabled = isDisabled || (onPressed == null && !isLoading);
    final effectiveTextColor = textColor ?? AppPrimaryColors.shade600;
    final effectiveSide = effectivelyDisabled
        ? BorderSide.none
        : side ?? const BorderSide(color: AppPrimaryColors.shade600);

    final Widget button = OutlinedButton.icon(
      onPressed: effectivelyDisabled || isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: effectiveTextColor,
        disabledBackgroundColor: AppPrimaryColors.shade100,
        disabledForegroundColor: effectiveTextColor,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        side: effectiveSide,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
      ),
      icon: icon,
      iconAlignment: iconAlignment,
      label: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: effectiveTextColor,
              ),
            )
          : Text(
              text,
              textAlign: TextAlign.center,
              style:
                  textStyle ??
                  AppTypography.bodyXlSemiBold.copyWith(
                    color: effectiveTextColor,
                  ),
            ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: !effectivelyDisabled && !isLoading,
      label: semanticLabel ?? text,
      child: SizedBox(
        width: width,
        height: height,
        child: button,
      ),
    );
  }
}

/// Preview for [SecondaryButton] with default outline.
@Preview(name: 'Default Secondary Button', group: 'UI Components')
Widget secondaryButtonPreview() {
  return const SecondaryButton(
    text: 'Secondary Action',
  );
}

/// Preview for [SecondaryButton] in disabled state.
@Preview(name: 'Disabled Secondary Button', group: 'UI Components')
Widget disabledSecondaryButtonPreview() {
  return const SecondaryButton(
    text: 'Disabled Button',
    isDisabled: true,
  );
}

/// Preview for [SecondaryButton] with an overridden solid background.
@Preview(name: 'Solid Secondary Button', group: 'UI Components')
Widget solidSecondaryButtonPreview() {
  return const SecondaryButton(
    text: 'Solid Button',
    backgroundColor: AppNeutralColors.shade200,
  );
}

/// Preview for [SecondaryButton] with custom border and text color.
@Preview(name: 'Custom Border Secondary Button', group: 'UI Components')
Widget customBorderSecondaryButtonPreview() {
  return const SecondaryButton(
    text: 'Custom Border',
    textColor: AppPrimaryColors.shade700,
    side: BorderSide(
      color: AppPrimaryColors.shade700,
    ),
  );
}
