import 'package:flutter/material.dart';

import '../animations/bar_animations.dart';

/// Animated transition widget encapsulating navigation rail appearance.
class NavRailTransition extends StatefulWidget {
  /// Creates a [NavRailTransition] widget.
  const NavRailTransition({
    required this.animation,
    required this.backgroundColor,
    required this.child,
    super.key,
  });

  /// The animation driving the navigation rail transition.
  final Animation<double> animation;

  /// The child navigation rail widget to transition.
  final Widget child;

  /// Background color applied behind the transitioning rail.
  final Color backgroundColor;

  @override
  State<NavRailTransition> createState() => _NavRailTransitionState();
}

class _NavRailTransitionState extends State<NavRailTransition> {
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _widthAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAnimations();
  }

  @override
  void didUpdateWidget(covariant NavRailTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _initAnimations();
    }
  }

  void _initAnimations() {
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    _offsetAnimation = Tween<Offset>(
      begin: isLtr ? const Offset(-1, 0) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(parent: widget.animation));

    _widthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(parent: widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        if (_widthAnimation.value <= 0.0) {
          return const SizedBox.shrink();
        }

        final content = Align(
          alignment: Alignment.topLeft,
          widthFactor: _widthAnimation.value,
          child: FractionalTranslation(
            translation: _offsetAnimation.value,
            child: widget.child,
          ),
        );

        if (_widthAnimation.value < 1.0) {
          return ClipRect(
            child: DecoratedBox(
              decoration: BoxDecoration(color: widget.backgroundColor),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}
