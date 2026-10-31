import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';

/// Card displaying a single concern's current `raw_score`, baseline comparison,
/// mini horizontal progress bar, and 8-week sparkline on the "By concern" tab.
class ProgressConcernMetricCard extends StatelessWidget {
  /// Creates a [ProgressConcernMetricCard].
  const ProgressConcernMetricCard({
    required this.concernType,
    required this.currentScore,
    required this.baselineScore,
    required this.delta,
    required this.isStable,
    required this.sparklineValues,
    required this.onTap,
    super.key,
  });

  /// Reference concern metadata (`public.concern_types`).
  final ProgressConcernType concernType;

  /// Latest whole-face `raw_score` (`0..100`).
  final double currentScore;

  /// Baseline whole-face `raw_score` (`0..100`).
  final double baselineScore;

  /// Signed score variation (`currentScore - baselineScore`).
  final int delta;

  /// Whether [delta] is within the noise threshold (`±3 pts`).
  final bool isStable;

  /// Historical score values for the inline mini sparkline.
  final List<double> sparklineValues;

  /// Opens `/progress/concern/:type`.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scoreInt = currentScore.round();

    return Semantics(
      button: true,
      label:
          '${concernType.label}, score $scoreInt out of 100, '
          'baseline ${baselineScore.round()}',
      child: KoraCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scoreInt >= 70
                    ? AppColors.primary50
                    : AppColors.secondary50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: scoreInt >= 70
                      ? AppColors.primary200
                      : AppColors.secondary200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$scoreInt',
                style: AppTypography.bodyLBold.copyWith(
                  color: scoreInt >= 70
                      ? AppColors.primary900
                      : AppColors.secondary900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          concernType.label,
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (concernType.isHeadline) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: Text(
                            'HEADLINE',
                            style: AppTypography.bodyXsBold.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Baseline ${baselineScore.toStringAsFixed(1)} → '
                    'Now ${currentScore.toStringAsFixed(1)}',
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (currentScore / 100.0).clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scoreInt >= 70
                            ? AppColors.primary700
                            : AppColors.secondary600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (sparklineValues.length >= 2) ...[
              SizedBox(
                width: 44,
                height: 24,
                child: CustomPaint(
                  painter: _MiniSparklinePainter(values: sparklineValues),
                ),
              ),
              const SizedBox(width: 10),
            ],
            KoraDeltaPill(delta: delta, isStable: isStable),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.grey600,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  const _MiniSparklinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var minV = values.first;
    var maxV = values.first;
    for (final v in values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final range = (maxV - minV) < 4.0 ? 4.0 : (maxV - minV);

    final paint = Paint()
      ..color = AppColors.primary700
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (size.width * i) / (values.length - 1);
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y.clamp(2.0, size.height - 2.0));
      } else {
        path.lineTo(x, y.clamp(2.0, size.height - 2.0));
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
