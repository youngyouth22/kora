// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';

/// A minimalist, modern flat card widget adhering to Kora's design identity:
/// 0 elevation, no drop shadows, 1dp subtle border, and 16dp rounded corners.
class KoraCard extends StatelessWidget {
  /// Creates a [KoraCard].
  const KoraCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.grey50,
    this.borderColor = AppColors.grey300,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onTap,
    this.margin,
  });

  /// The child widget placed inside the card.
  final Widget child;

  /// Internal padding for content. Defaults to 16dp.
  final EdgeInsetsGeometry padding;

  /// Card surface color. Defaults to clean white [AppColors.grey50].
  final Color backgroundColor;

  /// Border outline color. Defaults to subtle [AppColors.grey300].
  final Color borderColor;

  /// Border radius geometry. Defaults to 16dp.
  final BorderRadiusGeometry borderRadius;

  /// Optional tap handler making the card interactable.
  final VoidCallback? onTap;

  /// Optional outer margin.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius is BorderRadius
              ? borderRadius as BorderRadius
              : BorderRadius.circular(16),
          child: content,
        ),
      );
    }

    return content;
  }
}
