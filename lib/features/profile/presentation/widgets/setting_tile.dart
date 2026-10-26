import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';

/// A reusable setting row item with leading icon, label, and trailing arrow.
class SettingTile extends StatelessWidget {
  /// Creates a [SettingTile].
  const SettingTile({
    required this.title,
    required this.onTap,
    super.key,
    this.icon,
    this.leading,
    this.trailing,
    this.subtitle,
    this.iconColor = AppGreyColors.shade700,
    this.titleColor = AppGreyColors.shade1050,
  });

  /// The icon displayed at the leading position if [leading] is not provided.
  final IconData? icon;

  /// Optional custom leading widget. Overrides [icon] if provided.
  final Widget? leading;

  /// Optional custom trailing widget. If null, displays the right chevron
  /// arrow.
  final Widget? trailing;

  /// The primary title text of the setting.
  final String title;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Color for [icon]. Defaults to [AppGreyColors.shade700].
  final Color iconColor;

  /// Color for [title]. Defaults to [AppGreyColors.shade1050].
  final Color titleColor;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (icon != null) {
      leadingWidget = Icon(
        icon,
        size: 20,
        color: iconColor,
      );
    }

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: leadingWidget,
        title: Text(
          title,
          style: AppTypography.bodyMRegular.copyWith(
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
              )
            : null,
        trailing:
            trailing ??
            SvgPicture.asset(
              ImageResources.arrowRight,
              width: 20,
              colorFilter: const ColorFilter.mode(
                AppGreyColors.shade600,
                BlendMode.srcIn,
              ),
            ),
        onTap: onTap,
      ),
    );
  }
}
