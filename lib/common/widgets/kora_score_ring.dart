// ignore_for_file: document_ignores

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Ring size variants per blueprint.
enum ScoreRingSize {
  /// Small inline badge.
  s(48, 4),

  /// Medium standard card ring.
  m(72, 6),

  /// Large hero display ring.
  l(110, 8);

  const ScoreRingSize(this.dimension, this.strokeWidth);

  /// Diameter of the ring in dp.
  final double dimension;

  /// Thickness of the stroke in dp.
  final double strokeWidth;
}

/// A modern, minimalist score ring without gradients or shadows.
class KoraScoreRing extends StatelessWidget {
  /// Creates a [KoraScoreRing].
  const KoraScoreRing({
    required this.score,
    super.key,
    this.size = ScoreRingSize.m,
    this.subtitle,
    this.ringColor,
    this.trackColor,
  });

  /// Numerical score value (0 to 100).
  final int score;

  /// Display variant sizing.
  final ScoreRingSize size;

  /// Optional text below or inside (for hero).
  final String? subtitle;

  /// Ring progress color override.
  final Color? ringColor;

  /// Background circle color override.
  final Color? trackColor;

  Color _resolveColor(int score) {
    if (score >= 70) return AppColors.primary700;
    if (score >= 50) return AppColors.secondary500;
    return AppColors.error400;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRingColor = ringColor ?? _resolveColor(score);
    final effectiveTrackColor = trackColor ?? AppColors.grey200;

    return Semantics(
      label: 'Skin score: $score out of 100',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.dimension,
            height: size.dimension,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size.dimension, size.dimension),
                  painter: _RingPainter(
                    progress: (score.clamp(0, 100)) / 100.0,
                    strokeWidth: size.strokeWidth,
                    progressColor: effectiveRingColor,
                    trackColor: effectiveTrackColor,
                  ),
                ),
                Text(
                  '$score',
                  style: size == ScoreRingSize.l
                      ? AppTypography.h3Bold.copyWith(color: AppColors.grey1050)
                      : size == ScoreRingSize.m
                      ? AppTypography.h4Bold.copyWith(color: AppColors.grey1050)
                      : AppTypography.bodyMBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
