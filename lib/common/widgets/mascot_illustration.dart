import 'package:flutter/material.dart';
import 'package:kora/common/constants/mascot_pose.dart';

/// A widget that displays the mascot illustration for a given [MascotPose].
///
/// Features smooth transitions between poses with gapless playback and
/// customizable sizing and fit options.
class MascotIllustration extends StatelessWidget {
  /// Creates a [MascotIllustration].
  ///
  /// * [pose] specifies the mascot pose illustration to display.
  /// * [size] defines both the width and height of the illustration.
  ///   Defaults to 120.0.
  /// * [fit] defines how the image should be inscribed into the box.
  ///   Defaults to [BoxFit.contain].
  const MascotIllustration({
    required this.pose,
    super.key,
    this.size = 120.0,
    this.fit = BoxFit.contain,
  });

  /// The pose variant of the mascot to render.
  final MascotPose pose;

  /// The size (both width and height) of the illustration in logical pixels.
  final double size;

  /// How the mascot image should be inscribed into the space allocated for it.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      pose.path,
      width: size,
      height: size,
      fit: fit,
      // Maintains smooth rendering during pose transitions
      // (e.g., from 'thinking' to 'success').
      gaplessPlayback: true,
    );
  }
}

/// Flight shuttle builder providing smooth, flicker-free scaling during
/// [Hero] transitions of mascot illustrations.
Widget mascotHeroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final toHero = toHeroContext.widget as Hero;
  return Material(
    type: MaterialType.transparency,
    child: FittedBox(
      child: toHero.child,
    ),
  );
}
