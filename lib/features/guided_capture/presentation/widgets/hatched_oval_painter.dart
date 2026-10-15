import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/features/guided_capture/domain/entities/capture_oval_geometry.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';

/// Paints the hatched face-guide oval.
///
/// The ring is made of thin ticks evenly spaced along the ellipse perimeter
/// and drawn perpendicular to it.
/// - When positioning/aligning: only the sector pointing towards the face
///   lights up in emerald green, matching the user's head position.
/// - When all criteria are met: the whole ring turns full emerald green
///   and countdown completes.
class HatchedOvalPainter extends CustomPainter {
  /// Creates a [HatchedOvalPainter].
  const HatchedOvalPainter({
    required this.hasFace,
    required this.alignmentScore,
    required this.faceOffsetFromCenter,
    required this.isAllValid,
  });

  /// Whether a face is detected in frame.
  final bool hasFace;

  /// Alignment score [0.0 to 1.0].
  final double alignmentScore;

  /// Directional face offset relative to oval center.
  final FaceOffset faceOffsetFromCenter;

  /// True when all criteria (position, light, angle) are satisfied.
  final bool isAllValid;

  /// Target spacing between two ticks, in logical pixels.
  static const double tickSpacing = 3;

  /// Tick length relative to the horizontal radius (design: ~9 / 190).
  static const double tickLengthFactor = 0.05;

  /// Stroke width of an idle tick.
  static const double tickStrokeWidth = 1.1;

  /// Number of samples used to measure the ellipse perimeter.
  static const int perimeterSamples = 720;

  /// Color of ticks that are not yet filled (idle/white/light-grey).
  static const Color idleColor = AppGreyColors.shade400;

  /// Color of active face-aligned ticks.
  static const Color activeColor = AppPrimaryColors.shade500;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final oval = CaptureOvalGeometry.resolve(size.width, size.height);
    final rx = oval.radiusX;
    final ry = oval.radiusY;
    final halfTick = rx * tickLengthFactor / 2;

    // Cumulative arc length table, used to place ticks at equal distances.
    final cumulative = Float64List(perimeterSamples + 1);
    var previous = Offset(rx, 0);
    for (var i = 1; i <= perimeterSamples; i++) {
      final t = 2 * math.pi * i / perimeterSamples;
      final point = Offset(rx * math.cos(t), ry * math.sin(t));
      cumulative[i] = cumulative[i - 1] + (point - previous).distance;
      previous = point;
    }
    final perimeter = cumulative[perimeterSamples];
    final tickCount = math.max(1, (perimeter / tickSpacing).round());

    // Target angle of face relative to the center of the oval
    final targetAngle = math.atan2(
      faceOffsetFromCenter.dy,
      faceOffsetFromCenter.dx,
    );

    // Spread of the green sector around targetAngle
    // When isAllValid, halfSpread is pi (covers full 360 ring)
    final halfSpread = isAllValid
        ? math.pi
        : (alignmentScore.clamp(0.0, 1.0) * math.pi);

    final idle = Float32List(tickCount * 4);
    final active = Float32List(tickCount * 4);
    var idleIndex = 0;
    var activeIndex = 0;
    var segment = 0;

    for (var k = 0; k < tickCount; k++) {
      final target = perimeter * k / tickCount;
      while (segment < perimeterSamples - 1 &&
          cumulative[segment + 1] < target) {
        segment++;
      }
      final segmentLength = cumulative[segment + 1] - cumulative[segment];
      final fraction = segmentLength == 0
          ? 0.0
          : (target - cumulative[segment]) / segmentLength;
      final t = 2 * math.pi * (segment + fraction) / perimeterSamples;

      final cosT = math.cos(t);
      final sinT = math.sin(t);
      final x = oval.centerX + rx * cosT;
      final y = oval.centerY + ry * sinT;

      // Outward normal of the ellipse at t.
      final nx = ry * cosT;
      final ny = rx * sinT;
      final length = math.sqrt(nx * nx + ny * ny);
      final ux = nx / length * halfTick;
      final uy = ny / length * halfTick;

      // Determine if tick is within the active directional segment
      var isTickActive = false;
      if (hasFace && (alignmentScore > 0 || isAllValid)) {
        if (isAllValid) {
          isTickActive = true;
        } else {
          final angularDiff = _shortestAngularDistance(t, targetAngle);
          if (angularDiff <= halfSpread) {
            isTickActive = true;
          }
        }
      }

      final buffer = isTickActive ? active : idle;
      var index = isTickActive ? activeIndex : idleIndex;
      buffer[index++] = x - ux;
      buffer[index++] = y - uy;
      buffer[index++] = x + ux;
      buffer[index++] = y + uy;
      if (isTickActive) {
        activeIndex = index;
      } else {
        idleIndex = index;
      }
    }

    final paint = Paint()
      ..strokeWidth = tickStrokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    if (idleIndex > 0) {
      canvas.drawRawPoints(
        ui.PointMode.lines,
        Float32List.sublistView(idle, 0, idleIndex),
        paint..color = idleColor,
      );
    }
    if (activeIndex > 0) {
      canvas.drawRawPoints(
        ui.PointMode.lines,
        Float32List.sublistView(active, 0, activeIndex),
        paint
          ..color = activeColor
          ..strokeWidth = isAllValid ? 1.3 : tickStrokeWidth,
      );
    }
  }

  double _shortestAngularDistance(double a, double b) {
    var diff = (a - b) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return diff.abs();
  }

  @override
  bool shouldRepaint(covariant HatchedOvalPainter oldDelegate) {
    return oldDelegate.hasFace != hasFace ||
        oldDelegate.alignmentScore != alignmentScore ||
        oldDelegate.faceOffsetFromCenter != faceOffsetFromCenter ||
        oldDelegate.isAllValid != isAllValid;
  }
}
