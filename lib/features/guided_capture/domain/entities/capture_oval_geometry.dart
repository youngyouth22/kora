import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// Resolved oval bounds, expressed in the same logical pixel space as the
/// viewport that was used to compute them.
class OvalBounds extends Equatable {
  /// Creates an [OvalBounds].
  const OvalBounds({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
  });

  /// Horizontal center of the oval.
  final double centerX;

  /// Vertical center of the oval.
  final double centerY;

  /// Horizontal radius of the oval (middle of the tick ring).
  final double radiusX;

  /// Vertical radius of the oval (middle of the tick ring).
  final double radiusY;

  @override
  List<Object?> get props => [centerX, centerY, radiusX, radiusY];
}

/// Single source of truth for the face guide oval.
///
/// Both the painter (what the user sees) and the readiness evaluation (what
/// the detector checks) resolve the oval through [resolve], guaranteeing that
/// "my head is inside the oval" on screen means the same thing for the
/// algorithm.
abstract final class CaptureOvalGeometry {
  /// Horizontal center as a fraction of the viewport width.
  static const double centerXFraction = 0.5;

  /// Vertical center as a fraction of the viewport height.
  static const double centerYFraction = 0.45;

  /// Preferred horizontal radius as a fraction of the viewport width.
  static const double radiusXFraction = 0.41;

  /// Ratio between vertical and horizontal radius (design: 462 / 380).
  static const double verticalStretch = 1.216;

  /// Maximum vertical radius as a fraction of viewport height, preventing
  /// the oval from colliding with the top/bottom overlays on wide screens.
  static const double maxRadiusYFraction = 0.30;

  /// Resolves the oval for a viewport of [width] x [height].
  static OvalBounds resolve(double width, double height) {
    final radiusX = math.min(
      width * radiusXFraction,
      height * maxRadiusYFraction / verticalStretch,
    );
    return OvalBounds(
      centerX: width * centerXFraction,
      centerY: height * centerYFraction,
      radiusX: radiusX,
      radiusY: radiusX * verticalStretch,
    );
  }
}
