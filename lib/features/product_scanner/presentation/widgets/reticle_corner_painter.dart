import 'package:flutter/rendering.dart';

/// Paints 4 rounded L-shaped corner brackets filling the canvas.
class ReticleCornerPainter extends CustomPainter {
  /// Creates a [ReticleCornerPainter].
  const ReticleCornerPainter({
    required this.bracketLength,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.color,
  });

  /// Length of each bracket arm.
  final double bracketLength;

  /// Stroke width of the brackets.
  final double strokeWidth;

  /// Radius of the rounded corner joint.
  final double cornerRadius;

  /// Bracket color.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = strokeWidth / 2;
    final top = strokeWidth / 2;
    final right = size.width - (strokeWidth / 2);
    final bottom = size.height - (strokeWidth / 2);

    canvas
      ..drawPath(
        Path()
          ..moveTo(left, top + bracketLength)
          ..lineTo(left, top + cornerRadius)
          ..quadraticBezierTo(left, top, left + cornerRadius, top)
          ..lineTo(left + bracketLength, top),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(right - bracketLength, top)
          ..lineTo(right - cornerRadius, top)
          ..quadraticBezierTo(right, top, right, top + cornerRadius)
          ..lineTo(right, top + bracketLength),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(left, bottom - bracketLength)
          ..lineTo(left, bottom - cornerRadius)
          ..quadraticBezierTo(left, bottom, left + cornerRadius, bottom)
          ..lineTo(left + bracketLength, bottom),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(right - bracketLength, bottom)
          ..lineTo(right - cornerRadius, bottom)
          ..quadraticBezierTo(right, bottom, right, bottom - cornerRadius)
          ..lineTo(right, bottom - bracketLength),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant ReticleCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.bracketLength != bracketLength ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
