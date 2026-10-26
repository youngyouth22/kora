import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_themes.dart';
import 'package:kora/common/app_typography.dart';

/// Reusable and optimized text input field adhering to the Kora design system.
///
/// Features automatic password visibility toggling, accessibility semantics,
/// error styling, and design token integration with [AppThemes.lightTheme].
class AppTextField extends StatefulWidget {
  /// Creates an [AppTextField].
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.isPassword = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.semanticLabel,
    this.fillColor,
    this.autovalidateMode,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// An optional initial value when [controller] is null.
  final String? initialValue;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Configures how the platform keyboard will capitalize characters.
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  final TextStyle? style;

  /// Whether this text field should auto-focus on appearance.
  final bool autofocus;

  /// Whether the text can be changed.
  final bool readOnly;

  /// Whether to hide the text being edited (e.g. for passwords).
  final bool obscureText;

  /// When true, renders an eye toggle icon and manages visibility.
  final bool isPassword;

  /// Whether to enable autocorrection.
  final bool autocorrect;

  /// Whether to show suggestions.
  final bool enableSuggestions;

  /// The maximum number of lines for the text field.
  final int? maxLines;

  /// The minimum number of lines for the text field.
  final int? minLines;

  /// The maximum number of characters allowed.
  final int? maxLength;

  /// Called when the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the text field is tapped.
  final GestureTapCallback? onTap;

  /// Called when the user submits editing.
  final VoidCallback? onEditingComplete;

  /// Called when the user submits field.
  final ValueChanged<String>? onFieldSubmitted;

  /// An optional method to call with the final value when the form is saved.
  final FormFieldSetter<String>? onSaved;

  /// An optional method that validates an input.
  final FormFieldValidator<String>? validator;

  /// Optional input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field is enabled.
  final bool? enabled;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// Optional label displayed above or inside the field.
  final String? labelText;

  /// An optional leading widget placed inside the input border.
  final Widget? prefixIcon;

  /// An optional trailing widget placed inside the input border.
  final Widget? suffixIcon;

  /// The padding for the input content.
  final EdgeInsetsGeometry? contentPadding;

  /// Optional accessibility semantic label.
  final String? semanticLabel;

  /// Optional background fill color override.
  final Color? fillColor;

  /// Used to enable/disable auto validation and specify validation mode.
  final AutovalidateMode? autovalidateMode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword || widget.obscureText;
  }

  void _toggleObscurity() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSuffixIcon = widget.isPassword
        ? IconButton(
            icon: Icon(
              _obscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppGreyColors.shade700,
              size: 20,
            ),
            tooltip: _obscured ? 'Show password' : 'Hide password',
            onPressed: _toggleObscurity,
          )
        : widget.suffixIcon;

    final defaultTextStyle = AppTypography.bodyLRegular.copyWith(
      color: AppGreyColors.shade1050,
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.labelText ?? widget.hintText,
      textField: true,
      enabled: widget.enabled ?? true,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style ?? defaultTextStyle,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        obscureText: _obscured,
        autocorrect: !widget.isPassword && widget.autocorrect,
        enableSuggestions: !widget.isPassword && widget.enableSuggestions,
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onFieldSubmitted,
        onSaved: widget.onSaved,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorColor: AppPrimaryColors.shade600,
        autovalidateMode: widget.autovalidateMode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: effectiveSuffixIcon,
          fillColor: widget.fillColor,
          contentPadding: widget.contentPadding,
        ),
      ),
    );
  }
}
