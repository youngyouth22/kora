import 'package:flutter/material.dart';

import '../animations/bar_animations.dart';

/// Animated transition widget encapsulating bottom navigation bar appearance.
class BottomBarTransition extends StatefulWidget {
  /// Creates a [BottomBarTransition] widget.
  const BottomBarTransition({
    required this.animation,
    required this.backgroundColor,
    required this.child,
    super.key,
  });

  /// The animation driving the bar transition.
  final Animation<double> animation;

  /// Background color applied behind the transitioning bar.
  final Color backgroundColor;

  /// The child bottom bar widget to transition.
  final Widget child;

  @override
  State<BottomBarTransition> createState() => _BottomBarTransitionState();
}

class _BottomBarTransitionState extends State<BottomBarTransition> {
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(covariant BottomBarTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _initAnimations();
    }
  }

  void _initAnimations() {
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(OffsetAnimation(parent: widget.animation));

    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(parent: widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        if (_heightAnimation.value <= 0.0) {
          return const SizedBox.shrink();
        }

        final content = Align(
          alignment: Alignment.topLeft,
          heightFactor: _heightAnimation.value,
          child: FractionalTranslation(
            translation: _offsetAnimation.value,
            child: widget.child,
          ),
        );

        if (_heightAnimation.value < 1.0) {
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
