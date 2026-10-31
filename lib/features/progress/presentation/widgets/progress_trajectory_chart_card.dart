// ignore_for_file: document_ignores, lines_longer_than_80_chars, prefer_int_literals

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';

/// Data point plotted on a [ProgressTrajectoryChartCard].
class TrajectoryDataPoint {
  /// Creates a [TrajectoryDataPoint].
  const TrajectoryDataPoint({
    required this.label,
    required this.rawScore,
    required this.plottedScore,
    this.milestoneTag,
  });

  /// Short X-axis date label (e.g. `'Oct 9'`).
  final String label;

  /// Unsmoothed raw precision score (`0..100`).
  final double rawScore;

  /// Plotted score (either raw or smoothed moving average).
  final double plottedScore;

  /// Optional milestone marker (e.g. `'Retinol start'`).
  final String? milestoneTag;
}

/// Minimalist, zero-gradient, zero-shadow trajectory chart card.
///
/// Renders Y-axis reference lines, a subtle flat baseline noise band
/// (`±3 pts`), crisp polyline segments, hollow/filled data nodes, and an
/// accessible screen-reader trend summary (Article 6).
class ProgressTrajectoryChartCard extends StatelessWidget {
  /// Creates a [ProgressTrajectoryChartCard].
  const ProgressTrajectoryChartCard({
    required this.title,
    required this.subtitle,
    required this.delta,
    required this.points,
    this.isStable = false,
    this.noiseThreshold = 3.0,
    super.key,
  });

  /// Chart card header title (e.g. `'Overall Trajectory'`).
  final String title;

  /// Contextual subtitle beneath the header.
  final String subtitle;

  /// Signed score delta over the displayed time range.
  final int delta;

  /// Whether [delta] is within the noise band.
  final bool isStable;

  /// Configured noise threshold (`app_config.noise_by_concern`).
  final double noiseThreshold;

  /// Chronological points (oldest first) to plot.
  final List<TrajectoryDataPoint> points;

  String _buildSemanticSummary() {
    if (points.isEmpty) return '$title chart with no scan data.';
    final first = points.first;
    final last = points.last;
    final trendWord = isStable
        ? 'remained stable within the noise band'
        : (delta > 0
              ? 'improved by $delta points'
              : 'declined by $delta points');
    return '$title chart from ${first.label} (${first.rawScore.toStringAsFixed(1)}) '
        'to ${last.label} (${last.rawScore.toStringAsFixed(1)}). '
        'Score $trendWord.';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _buildSemanticSummary(),
      child: KoraCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyLBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                ),
                KoraDeltaPill(delta: delta, isStable: isStable),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 156,
              width: double.infinity,
              child: CustomPaint(
                painter: _FlatTrajectoryPainter(
                  points: points,
                  noiseThreshold: noiseThreshold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (points.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildAxisLabels(),
              ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      border: Border.all(color: AppColors.primary700),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Baseline noise band (±${noiseThreshold.toStringAsFixed(0)} pts) · Variations inside band are normal daily fluctuations.',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAxisLabels() {
    if (points.isEmpty) return const [];
    if (points.length <= 3) {
      return List.generate(points.length, (i) {
        final pt = points[i];
        final isLast = i == points.length - 1;
        return Text(
          pt.label,
          style: isLast
              ? AppTypography.bodyXsBold.copyWith(color: AppColors.primary800)
              : AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        );
      });
    }

    // Show start, midpoint, and end date labels to avoid horizontal overflow
    final indices = <int>{
      0,
      points.length ~/ 2,
      points.length - 1,
    }.toList()..sort();

    return indices.map((idx) {
      final pt = points[idx];
      final isLast = idx == points.length - 1;
      return Text(
        pt.label,
        style: isLast
            ? AppTypography.bodyXsBold.copyWith(color: AppColors.primary800)
            : AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
      );
    }).toList();
  }
}

class _FlatTrajectoryPainter extends CustomPainter {
  const _FlatTrajectoryPainter({
    required this.points,
    required this.noiseThreshold,
  });

  final List<TrajectoryDataPoint> points;
  final double noiseThreshold;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final rawAndPlotted = <double>[
      for (final p in points) ...[p.rawScore, p.plottedScore],
    ];
    final minVal = (rawAndPlotted.reduce(math.min) - 6).clamp(0.0, 90.0);
    final maxVal = (rawAndPlotted.reduce(math.max) + 6).clamp(10.0, 100.0);
    final span = math.max(12.0, maxVal - minVal);

    const leftPad = 12.0;
    const rightPad = 12.0;
    const topPad = 14.0;
    const bottomPad = 14.0;
    final usableWidth = math.max(1.0, size.width - leftPad - rightPad);
    final usableHeight = math.max(1.0, size.height - topPad - bottomPad);

    double yForScore(double score) {
      final normalized = (score - minVal) / span;
      return topPad + usableHeight * (1.0 - normalized.clamp(0.0, 1.0));
    }

    double xForIndex(int index) {
      if (points.length == 1) return size.width / 2;
      return leftPad + (usableWidth * index) / (points.length - 1);
    }

    // 1. Flat baseline noise band around the initial baseline score
    final baselineScore = points.first.rawScore;
    final bandTop = yForScore(baselineScore + noiseThreshold);
    final bandBottom = yForScore(baselineScore - noiseThreshold);
    final bandRect = Rect.fromLTRB(0, bandTop, size.width, bandBottom);
    final bandPaint = Paint()
      ..color = AppColors.primary50
      ..style = PaintingStyle.fill;
    canvas.drawRect(bandRect, bandPaint);

    // 2. Horizontal reference lines (top, middle, bottom)
    final gridPaint = Paint()
      ..color = AppColors.grey300
      ..strokeWidth = 1;
    for (final ratio in const [0.15, 0.5, 0.85]) {
      final y = topPad + usableHeight * ratio;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Compute plotted coordinates
    final coords = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(xForIndex(i), yForScore(points[i].plottedScore)),
    ];

    // 4. Draw crisp trajectory line (zero gradient, zero shadow)
    if (coords.length > 1) {
      final linePaint = Paint()
        ..color = AppColors.primary700
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(coords.first.dx, coords.first.dy);
      for (var i = 1; i < coords.length; i++) {
        path.lineTo(coords[i].dx, coords[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // 5. Draw nodes
    final outerPaint = Paint()..color = AppColors.primary700;
    final latestOuterPaint = Paint()..color = AppColors.primary900;
    final innerPaint = Paint()..color = AppColors.grey50;

    for (var i = 0; i < coords.length; i++) {
      final pt = coords[i];
      final isLatest = i == coords.length - 1;
      canvas
        ..drawCircle(
          pt,
          isLatest ? 6.5 : 5.0,
          isLatest ? latestOuterPaint : outerPaint,
        )
        ..drawCircle(pt, isLatest ? 3.0 : 2.5, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlatTrajectoryPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.noiseThreshold != noiseThreshold;
  }
}
