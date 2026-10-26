import 'package:flutter/material.dart';

import '../models/adaptive_nav_destination.dart';
import '../transitions/bottom_bar_transition.dart';

/// Bottom navigation bar with animated transition support and customizable styling.
class DisappearingCustomBottomBar extends StatelessWidget {
  /// Creates a [DisappearingCustomBottomBar].
  const DisappearingCustomBottomBar({
    required this.barAnimation,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.destinations,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.height = 70.0,
    this.iconSize = 24.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    super.key,
  });

  /// The animation driving the bottom bar appearance/disappearance.
  final Animation<double> barAnimation;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback function triggered when a destination is selected.
  final ValueChanged<int> onItemSelected;

  /// The list of navigation destinations to display.
  final List<AdaptiveNavDestination> destinations;

  /// Background color of the bottom bar.
  final Color? backgroundColor;

  /// Tint color for active/selected items.
  final Color? selectedColor;

  /// Tint color for inactive/unselected items.
  final Color? unselectedColor;

  /// Border color for the top border divider.
  final Color? borderColor;

  /// Total height of the bottom bar. Defaults to 70.0.
  final double height;

  /// Icon rendering size. Defaults to 24.0.
  final double iconSize;

  /// Custom text style for selected labels.
  final TextStyle? selectedLabelStyle;

  /// Custom text style for unselected labels.
  final TextStyle? unselectedLabelStyle;

  Widget _buildItem(
    BuildContext context,
    AdaptiveNavDestination item,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = item.index == selectedIndex;
    final itemColor = isSelected ? activeColor : inactiveColor;
    final iconDescriptor =
        isSelected && item.selectedIcon != null ? item.selectedIcon : item.icon;

    Widget iconWidget = AdaptiveNavIcon(
      icon: iconDescriptor,
      color: itemColor,
      size: iconSize,
    );

    if (item.badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(top: -4, right: -6, child: item.badge!),
        ],
      );
    }

    final defaultTextStyle = Theme.of(context).textTheme.labelSmall ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);

    final effectiveStyle = isSelected
        ? (selectedLabelStyle ??
            defaultTextStyle.copyWith(
              color: activeColor,
              fontWeight: FontWeight.w600,
            ))
        : (unselectedLabelStyle ??
            defaultTextStyle.copyWith(color: inactiveColor));

    return Expanded(
      child: Semantics(
        label: item.semanticLabel ?? item.title,
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: () => onItemSelected(item.index),
          splashColor: activeColor.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 4),
              Text(
                item.title,
                style: effectiveStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.surface;
    final effectiveActiveColor = selectedColor ?? theme.colorScheme.primary;
    final effectiveInactiveColor =
        unselectedColor ?? theme.colorScheme.onSurfaceVariant;
    final effectiveBorderColor =
        borderColor ?? theme.dividerColor.withAlpha(120);

    return BottomBarTransition(
      animation: barAnimation,
      backgroundColor: effectiveBgColor,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveBgColor,
          border: Border(
            top: BorderSide(
              color: effectiveBorderColor,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomAppBar(
            padding: EdgeInsets.zero,
            color: Colors.transparent,
            elevation: 0,
            height: height,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: destinations
                  .map((item) => _buildItem(
                        context,
                        item,
                        effectiveActiveColor,
                        effectiveInactiveColor,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
