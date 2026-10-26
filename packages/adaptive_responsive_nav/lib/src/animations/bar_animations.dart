import 'package:flutter/animation.dart';

/// Reverse animation used for the disappearing bottom bar.
class BarAnimation extends ReverseAnimation {
  /// Creates a [BarAnimation] driving the bottom bar exit/entry.
  BarAnimation({required AnimationController parent})
      : super(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(0, 1 / 5),
            reverseCurve: const Interval(1 / 5, 4 / 5),
          ),
        );
}

/// Offset animation used for sliding navigation elements.
class OffsetAnimation extends CurvedAnimation {
  /// Creates an [OffsetAnimation].
  OffsetAnimation({required super.parent})
      : super(
          curve: const Interval(
            2 / 5,
            3 / 5,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            4 / 5,
            1,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

/// Rail animation used for the disappearing navigation rail.
class RailAnimation extends CurvedAnimation {
  /// Creates a [RailAnimation].
  RailAnimation({required super.parent})
      : super(
          curve: const Interval(0 / 5, 4 / 5),
          reverseCurve: const Interval(3 / 5, 1),
        );
}

/// Rail FAB animation used for floating action elements in navigation rail.
class RailFabAnimation extends CurvedAnimation {
  /// Creates a [RailFabAnimation].
  RailFabAnimation({required super.parent})
      : super(curve: const Interval(3 / 5, 1));
}

/// Scale animation used for navigation icon scaling.
class ScaleAnimation extends CurvedAnimation {
  /// Creates a [ScaleAnimation].
  ScaleAnimation({required super.parent})
      : super(
          curve: const Interval(
            3 / 5,
            4 / 5,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            3 / 5,
            1,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

/// Shape animation used for morphing container shapes.
class ShapeAnimation extends CurvedAnimation {
  /// Creates a [ShapeAnimation].
  ShapeAnimation({required super.parent})
      : super(
          curve: const Interval(
            2 / 5,
            3 / 5,
            curve: Curves.easeInOutCubicEmphasized,
          ),
        );
}

/// Size animation used for expanding and collapsing navigation dimensions.
class SizeAnimation extends CurvedAnimation {
  /// Creates a [SizeAnimation].
  SizeAnimation({required super.parent})
      : super(
          curve: const Interval(
            0 / 5,
            3 / 5,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            2 / 5,
            1,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}
