import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/image_resources.dart';

/// Camera viewfinder reticle frame with 4 L-shaped corner brackets.
class ViewfinderReticleFrame extends StatelessWidget {
  /// Creates a [ViewfinderReticleFrame].
  const ViewfinderReticleFrame({
    this.child,
    this.width = 210,
    this.height = 240,
    this.cornerLength = 26,
    this.strokeWidth = 3,
    this.cornerColor = AppColors.grey600,
    super.key,
  });

  /// The child widget displayed inside the reticle frame.
  final Widget? child;

  /// Width of the viewfinder area.
  final double width;

  /// Height of the viewfinder area.
  final double height;

  /// Length of each corner arm.
  final double cornerLength;

  /// Stroke width of the corner brackets.
  final double strokeWidth;

  /// Color of the corner brackets.
  final Color cornerColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(strokeWidth + 8),
            child:
                child ??
                Image.asset(
                  ImageResources.ceraveProduct,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Placeholder(
                    strokeWidth: 1.5,
                    color: AppColors.grey500,
                  ),
                ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CornerBracketPainter(
                length: cornerLength,
                strokeWidth: strokeWidth,
                color: cornerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({
    required this.length,
    required this.strokeWidth,
    required this.color,
  });

  final double length;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final halfStroke = strokeWidth / 2;

    // Top-Left corner
    final topLeft = Path()
      ..moveTo(halfStroke, length)
      ..lineTo(halfStroke, halfStroke)
      ..lineTo(length, halfStroke);
    canvas.drawPath(topLeft, paint);

    // Top-Right corner
    final topRight = Path()
      ..moveTo(size.width - length, halfStroke)
      ..lineTo(size.width - halfStroke, halfStroke)
      ..lineTo(size.width - halfStroke, length);
    canvas.drawPath(topRight, paint);

    // Bottom-Left corner
    final bottomLeft = Path()
      ..moveTo(halfStroke, size.height - length)
      ..lineTo(halfStroke, size.height - halfStroke)
      ..lineTo(length, size.height - halfStroke);
    canvas.drawPath(bottomLeft, paint);

    // Bottom-Right corner
    final bottomRight = Path()
      ..moveTo(size.width - length, size.height - halfStroke)
      ..lineTo(size.width - halfStroke, size.height - halfStroke)
      ..lineTo(size.width - halfStroke, size.height - length);
    canvas.drawPath(bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.length != length ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}
