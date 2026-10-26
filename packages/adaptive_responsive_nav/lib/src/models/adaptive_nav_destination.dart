import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Destination item for adaptive responsive navigation (bottom bar & nav rail).
class AdaptiveNavDestination {
  /// Creates an [AdaptiveNavDestination].
  const AdaptiveNavDestination({
    required this.index,
    required this.title,
    required this.icon,
    this.selectedIcon,
    this.tooltip,
    this.semanticLabel,
    this.badge,
  });

  /// Index representing this destination in the navigation hierarchy.
  final int index;

  /// Human-readable title/label for this destination.
  final String title;

  /// Icon descriptor. Can be a String asset path (SVG or raster image),
  /// an [IconData], or a [Widget].
  final dynamic icon;

  /// Optional icon descriptor when this destination is active/selected.
  final dynamic selectedIcon;

  /// Optional tooltip message for hover and long-press accessibility.
  final String? tooltip;

  /// Optional accessible label used by screen readers.
  final String? semanticLabel;

  /// Optional badge widget displayed alongside or over the icon.
  final Widget? badge;
}

/// Backward compatibility alias for [AdaptiveNavDestination].
typedef BottomBarModel = AdaptiveNavDestination;

/// Helper widget to render diverse icon representations consistently.
class AdaptiveNavIcon extends StatelessWidget {
  /// Creates an [AdaptiveNavIcon].
  const AdaptiveNavIcon({
    required this.icon,
    this.color,
    this.size = 24.0,
    super.key,
  });

  /// The icon descriptor ([IconData], SVG/raster asset path [String], or [Widget]).
  final dynamic icon;

  /// The tint color applied to the icon.
  final Color? color;

  /// The rendered icon width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final rawIcon = icon;
    if (rawIcon is IconData) {
      return Icon(rawIcon, size: size, color: color);
    }

    if (rawIcon is String) {
      if (rawIcon.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          rawIcon,
          width: size,
          height: size,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        );
      }
      return Image.asset(
        rawIcon,
        width: size,
        height: size,
        color: color,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image_rounded, size: size, color: color),
      );
    }

    if (rawIcon is Widget) {
      return rawIcon;
    }

    return Icon(Icons.circle, size: size, color: color);
  }
}
