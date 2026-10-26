import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../animations/bar_animations.dart';
import '../models/adaptive_nav_destination.dart';
import 'disappearing_custom_bottom_bar.dart';
import 'disappearing_navigation_rail.dart';

/// Responsive scaffold providing an animated adaptive navigation system.
///
/// Automatically switches between a bottom navigation bar on mobile/compact screens
/// and an animated navigation rail (compact or extended) on tablet/desktop screens.
/// Integrates seamlessly with `go_router` via [navigationShell] or custom state.
class AdaptiveResponsiveScaffold extends StatefulWidget {
  /// Creates an [AdaptiveResponsiveScaffold] with [StatefulNavigationShell] from `go_router`.
  const AdaptiveResponsiveScaffold({
    required this.destinations,
    this.navigationShell,
    this.body,
    this.selectedIndex,
    this.onDestinationSelected,
    this.onDestinationTap,
    this.compactBreakpoint = 840.0,
    this.mediumBreakpoint = 840.0,
    this.backgroundColor,
    this.bottomBarBackgroundColor,
    this.railBackgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.dividerColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.leading,
    this.trailing,
    this.onSettingsPressed,
    this.settingsIcon,
    this.settingsLabel = 'Settings',
    this.bottomBarHeight = 70.0,
    this.iconSize = 24.0,
    this.transitionDuration = const Duration(milliseconds: 300),
    super.key,
  }) : assert(
          navigationShell != null ||
              (body != null &&
                  selectedIndex != null &&
                  onDestinationSelected != null),
          'Provide either navigationShell OR (body, selectedIndex, onDestinationSelected)',
        );

  /// Stateful navigation shell from `go_router`.
  final StatefulNavigationShell? navigationShell;

  /// Custom body widget when not using [navigationShell].
  final Widget? body;

  /// Active tab index when not using [navigationShell].
  final int? selectedIndex;

  /// Callback when a tab is selected when not using [navigationShell].
  final ValueChanged<int>? onDestinationSelected;

  /// Optional interceptor callback before switching branches or tabs.
  /// Return `false` to prevent the scaffold from changing destination.
  final bool Function(int index)? onDestinationTap;

  /// List of navigation destinations.
  final List<AdaptiveNavDestination> destinations;

  /// Screen width below which the bottom bar is shown (default: 600.0).
  final double compactBreakpoint;

  /// Screen width at/above which the navigation rail is extended with labels (default: 840.0).
  final double mediumBreakpoint;

  /// Scaffold background color.
  final Color? backgroundColor;

  /// Bottom bar background color.
  final Color? bottomBarBackgroundColor;

  /// Navigation rail background color.
  final Color? railBackgroundColor;

  /// Active tint color.
  final Color? selectedColor;

  /// Inactive tint color.
  final Color? unselectedColor;

  /// Color of the rail indicator pill.
  final Color? indicatorColor;

  /// Divider border color.
  final Color? dividerColor;

  /// Text style for active destination labels.
  final TextStyle? selectedLabelStyle;

  /// Text style for inactive destination labels.
  final TextStyle? unselectedLabelStyle;

  /// Optional leading widget at top of navigation rail.
  final Widget? leading;

  /// Optional custom trailing widget at bottom of navigation rail.
  final Widget? trailing;

  /// Optional callback for settings action in navigation rail.
  final VoidCallback? onSettingsPressed;

  /// Settings icon descriptor.
  final dynamic settingsIcon;

  /// Settings action label.
  final String settingsLabel;

  /// Height of the bottom navigation bar.
  final double bottomBarHeight;

  /// Size of destination icons.
  final double iconSize;

  /// Duration of the transition animation.
  final Duration transitionDuration;

  @override
  State<AdaptiveResponsiveScaffold> createState() =>
      _AdaptiveResponsiveScaffoldState();
}

class _AdaptiveResponsiveScaffoldState extends State<AdaptiveResponsiveScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final BarAnimation _barAnimation;
  late final RailAnimation _railAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
      value: 0.0,
    );
    _barAnimation = BarAnimation(parent: _controller);
    _railAnimation = RailAnimation(parent: _controller);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width;
    final isRailMode = width >= widget.compactBreakpoint;
    final targetValue = isRailMode ? 1.0 : 0.0;

    if (!_initialized) {
      _initialized = true;
      _controller.value = targetValue;
    } else if (_controller.value != targetValue) {
      _controller.animateTo(targetValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _currentIndex =>
      widget.navigationShell?.currentIndex ?? widget.selectedIndex ?? 0;

  void _handleDestinationSelected(int index) {
    if (widget.onDestinationTap != null) {
      final allow = widget.onDestinationTap!(index);
      if (!allow) return;
    }
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
    } else {
      widget.onDestinationSelected?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isExtended = width >= widget.mediumBreakpoint;
    final effectiveBody = widget.navigationShell ?? widget.body!;

    return Scaffold(
      backgroundColor:
          widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
      extendBody: true,
      
      body: Row(
        children: [
          DisappearingNavigationRail(
            railAnimation: _railAnimation,
            selectedIndex: _currentIndex,
            isExtended: isExtended,
            onDestinationSelected: _handleDestinationSelected,
            destinations: widget.destinations,
            backgroundColor: widget.railBackgroundColor,
            selectedColor: widget.selectedColor,
            unselectedColor: widget.unselectedColor,
            indicatorColor: widget.indicatorColor,
            dividerColor: widget.dividerColor,
            leading: widget.leading,
            trailing: widget.trailing,
            onSettingsPressed: widget.onSettingsPressed,
            settingsIcon: widget.settingsIcon,
            settingsLabel: widget.settingsLabel,
            selectedLabelStyle: widget.selectedLabelStyle,
            unselectedLabelStyle: widget.unselectedLabelStyle,
          ),
          Expanded(child: effectiveBody),
        ],
      ),
      bottomNavigationBar: DisappearingCustomBottomBar(
        barAnimation: _barAnimation,
        selectedIndex: _currentIndex,
        onItemSelected: _handleDestinationSelected,
        destinations: widget.destinations,
        backgroundColor: widget.bottomBarBackgroundColor,
        selectedColor: widget.selectedColor,
        unselectedColor: widget.unselectedColor,
        borderColor: widget.dividerColor,
        height: widget.bottomBarHeight,
        iconSize: widget.iconSize,
        selectedLabelStyle: widget.selectedLabelStyle,
        unselectedLabelStyle: widget.unselectedLabelStyle,
      ),
    );
  }
}
