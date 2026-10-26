import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';

/// A reusable settings section that displays a category title and encapsulates
/// its items or content inside a styled [KoraCard].
class SettingSection extends StatelessWidget {
  /// Creates a [SettingSection].
  const SettingSection({
    required this.title,
    super.key,
    this.children,
    this.child,
    this.titleTextStyle,
    this.cardPadding = EdgeInsets.zero,
    this.cardBackgroundColor = AppColors.grey50,
    this.cardBorderColor = AppColors.grey300,
    this.spacing = 12,
  }) : assert(
         children != null || child != null,
         'Either children or child must be provided',
       );

  /// Header title for the section.
  final String title;

  /// Custom typography style for the section header title.
  /// If null, defaults to [AppTypography.bodyLMedium] with
  /// [AppGreyColors.shade600].
  final TextStyle? titleTextStyle;

  /// List of child widgets placed in a [Column] inside the card.
  final List<Widget>? children;

  /// Single child widget placed inside the card.
  final Widget? child;

  /// Internal padding for the [KoraCard]. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry cardPadding;

  /// Background color for the [KoraCard]. Defaults to [AppColors.grey50].
  final Color cardBackgroundColor;

  /// Border color for the [KoraCard]. Defaults to [AppColors.grey300].
  final Color cardBorderColor;

  /// Spacing between the title and the card. Defaults to 12.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style:
              titleTextStyle ??
              AppTypography.bodyLMedium.copyWith(
                color: AppGreyColors.shade600,
              ),
        ),
        SizedBox(height: spacing),
        KoraCard(
          padding: cardPadding,
          backgroundColor: cardBackgroundColor,
          borderColor: cardBorderColor,
          child:
              child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: children ?? const [],
              ),
        ),
      ],
    );
  }
}

/// Alias for [SettingSection].
typedef SettingsSection = SettingSection;
