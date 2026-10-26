import 'package:flutter/material.dart';

import '../models/adaptive_nav_destination.dart';
import '../transitions/nav_rail_transition.dart';

/// Navigation rail with animated transition and responsive layout adaptation
/// (compact without labels on medium screens, extended with labels on large screens).
class DisappearingNavigationRail extends StatelessWidget {
  /// Creates a [DisappearingNavigationRail] widget.
  const DisappearingNavigationRail({
    required this.railAnimation,
    required this.selectedIndex,
    required this.isExtended,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.dividerColor,
    this.leading,
    this.trailing,
    this.onSettingsPressed,
    this.settingsIcon,
    this.settingsLabel = 'Settings',
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    super.key,
  });

  /// The animation driving the navigation rail transition.
  final Animation<double> railAnimation;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Whether the rail is extended with labels (large screen)
  /// or compact without labels (medium screen).
  final bool isExtended;

  /// Callback function triggered when a navigation destination is tapped.
  final ValueChanged<int> onDestinationSelected;

  /// The list of navigation destinations to display.
  final List<AdaptiveNavDestination> destinations;

  /// Background color of the navigation rail.
  final Color? backgroundColor;

  /// Tint color for selected destinations and labels.
  final Color? selectedColor;

  /// Tint color for unselected destinations and labels.
  final Color? unselectedColor;

  /// Color used for the selection indicator pill.
  final Color? indicatorColor;

  /// Divider color between the rail and body.
  final Color? dividerColor;

  /// Optional leading widget at the top of the rail.
  final Widget? leading;

  /// Optional custom trailing widget at the bottom of the rail.
  final Widget? trailing;

  /// Callback function triggered when the settings action is pressed.
  final VoidCallback? onSettingsPressed;

  /// Optional custom settings icon (defaults to [Icons.settings_outlined]).
  final dynamic settingsIcon;

  /// Label for settings action. Defaults to 'Settings'.
  final String settingsLabel;

  /// Custom text style for selected labels.
  final TextStyle? selectedLabelStyle;

  /// Custom text style for unselected labels.
  final TextStyle? unselectedLabelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.surface;
    final effectiveActiveColor = selectedColor ?? theme.colorScheme.primary;
    final effectiveInactiveColor =
        unselectedColor ?? theme.colorScheme.onSurfaceVariant;
    final effectiveIndicatorColor =
        indicatorColor ?? effectiveActiveColor.withAlpha(28);
    final effectiveDividerColor =
        dividerColor ?? theme.dividerColor.withAlpha(120);

    final defaultTextStyle = theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

    final effectiveSelectedStyle = selectedLabelStyle ??
        defaultTextStyle.copyWith(
          color: effectiveActiveColor,
          fontWeight: FontWeight.w600,
        );

    final effectiveUnselectedStyle = unselectedLabelStyle ??
        defaultTextStyle.copyWith(color: effectiveInactiveColor);

    return NavRailTransition(
      animation: railAnimation,
      backgroundColor: effectiveBgColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            backgroundColor: effectiveBgColor,
            extended: isExtended,
            labelType: isExtended ? null : NavigationRailLabelType.none,
            onDestinationSelected: onDestinationSelected,
            groupAlignment: -1,
            indicatorColor: effectiveIndicatorColor,
            leading: leading ?? const SizedBox(height: 12),
            selectedLabelTextStyle: effectiveSelectedStyle,
            unselectedLabelTextStyle: effectiveUnselectedStyle,
            destinations: destinations.map((destination) {
              final isSel = destination.index == selectedIndex;
              final iconDesc = isSel && destination.selectedIcon != null
                  ? destination.selectedIcon
                  : destination.icon;

              return NavigationRailDestination(
                icon: AdaptiveNavIcon(
                  icon: iconDesc,
                  color: effectiveInactiveColor,
                  size: 24,
                ),
                selectedIcon: AdaptiveNavIcon(
                  icon: iconDesc,
                  color: effectiveActiveColor,
                  size: 24,
                ),
                label: Text(destination.title),
                padding: const EdgeInsets.symmetric(vertical: 6),
              );
            }).toList(),
            trailing: trailing ??
                (onSettingsPressed != null
                    ? Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: isExtended
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: InkWell(
                                      key: const Key(
                                        'nav_rail_settings_extended_button',
                                      ),
                                      onTap: onSettingsPressed,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            AdaptiveNavIcon(
                                              icon: settingsIcon ??
                                                  Icons.settings_outlined,
                                              color: effectiveInactiveColor,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              settingsLabel,
                                              style: effectiveUnselectedStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    key: const Key(
                                      'nav_rail_settings_compact_button',
                                    ),
                                    onPressed: onSettingsPressed,
                                    tooltip: settingsLabel,
                                    icon: AdaptiveNavIcon(
                                      icon: settingsIcon ??
                                          Icons.settings_outlined,
                                      color: effectiveInactiveColor,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    : null),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: effectiveDividerColor,
          ),
        ],
      ),
    );
  }
}
