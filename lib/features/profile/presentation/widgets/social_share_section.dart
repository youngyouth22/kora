import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';
import 'package:kora/features/profile/presentation/widgets/setting_tile.dart';

/// Represents a platform item in [SocialShareSection].
class SocialShareItem {
  /// Creates a [SocialShareItem].
  const SocialShareItem({
    required this.label,
    required this.iconPath,
    this.onTap,
  });

  /// Label displayed below the icon.
  final String label;

  /// Asset path to the platform icon.
  final String iconPath;

  /// Callback when this platform item is tapped.
  final VoidCallback? onTap;
}

/// A composite section widget built on top of [SettingSection] presenting
/// social platform links and a share tile.
class SocialShareSection extends StatelessWidget {
  /// Creates a [SocialShareSection].
  const SocialShareSection({
    required this.title,
    super.key,
    this.shareTitle = 'Share Kora',
    this.items,
    this.onShareTap,
    this.onInstagramTap,
    this.onTikTokTap,
    this.onXTap,
    this.onSnapchatTap,
  });

  /// section header title.
  final String title;

  /// Title for the share row. Defaults to 'Share Kora'.
  final String shareTitle;

  /// Custom list of social items. If omitted, defaults to Instagram, TikTok,
  /// X, and Snapchat.
  final List<SocialShareItem>? items;

  /// Callback when the share row is tapped.
  final VoidCallback? onShareTap;

  /// Callback for Instagram tap when using default items.
  final VoidCallback? onInstagramTap;

  /// Callback for TikTok tap when using default items.
  final VoidCallback? onTikTokTap;

  /// Callback for X tap when using default items.
  final VoidCallback? onXTap;

  /// Callback for Snapchat tap when using default items.
  final VoidCallback? onSnapchatTap;

  List<SocialShareItem> _resolveItems() {
    final customItems = items;
    if (customItems != null) return customItems;
    return [
      SocialShareItem(
        label: 'Instagram',
        iconPath: ImageResources.instagramIcon,
        onTap: onInstagramTap,
      ),
      SocialShareItem(
        label: 'Tiktok',
        iconPath: ImageResources.tikTokIcon,
        onTap: onTikTokTap,
      ),
      SocialShareItem(
        label: 'X',
        iconPath: ImageResources.xIcon,
        onTap: onXTap,
      ),
      SocialShareItem(
        label: 'Snapchat',
        iconPath: ImageResources.snapchatIcon,
        onTap: onSnapchatTap,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final socialItems = _resolveItems();

    return SettingSection(
      title: title,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              for (final item in socialItems) _SocialPlatformButton(item: item),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.grey300,
        ),
        SettingTile(
          leading: SvgPicture.asset(
            ImageResources.shareIcon,
            width: 20,
            height: 20,
          ),
          title: shareTitle,
          trailing: SvgPicture.asset(
            ImageResources.goIcon,
            width: 20,
            height: 20,
          ),
          onTap: onShareTap ?? () {},
        ),
      ],
    );
  }
}

class _SocialPlatformButton extends StatelessWidget {
  const _SocialPlatformButton({required this.item});

  final SocialShareItem item;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: item.label,
        child: InkWell(
          onTap: item.onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  item.iconPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppGreyColors.shade1050,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
