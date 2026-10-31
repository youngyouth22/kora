// ignore_for_file: document_ignores

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_card_kit.dart';

/// Suivi d'une expérience produit : flacon sérum réel, courbe de clarté
/// aux couleurs de Kora, progression sur 28 jours et verdict IA émeraude.
class AnimatedProductExperimentCard extends StatelessWidget {
  /// Creates an [AnimatedProductExperimentCard].
  const AnimatedProductExperimentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final reduce = CardKit.reduceMotion(context);

    return ScaledCard(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: CardKit.decoration(radius: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête produit avec photo réelle du flacon sérum
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    ImageResources.onboardingSerumBottle,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Niacinamide 10%', style: CardKit.title(18)),
                      const SizedBox(height: 2),
                      Text(
                        '28-day experiment',
                        style: CardKit.label(12.5, color: AppColors.grey700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary200),
                  ),
                  child: Text(
                    'Day 14',
                    style: CardKit.label(
                      12,
                      color: AppColors.primary800,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).motion(
              reduce,
              (a) => a.fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            ),

            const SizedBox(height: 18),

            // Courbe de clarté
            Container(
              height: 132,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.primary50.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.primary100,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Skin clarity',
                        style: CardKit.label(12.5, color: AppColors.grey700),
                      ),
                      const Spacer(),
                      CountUp(
                        end: 24,
                        prefix: '+',
                        suffix: '%',
                        style: CardKit.title(18, color: AppColors.primary700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: reduce ? 1 : 0, end: 1),
                      duration: reduce
                          ? Duration.zero
                          : const Duration(milliseconds: 1800),
                      curve: Curves.easeInOutCubic,
                      builder: (context, t, _) => CustomPaint(
                        size: Size.infinite,
                        painter: _ChartPainter(progress: t),
                      ),
                    ),
                  ),
                ],
              ),
            ).motion(
              reduce,
              (a) => a
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, delay: 150.ms),
            ),

            const SizedBox(height: 14),

            // Progression
            Row(
              children: [
                Text(
                  'Day 14 of 28',
                  style: CardKit.label(12.5, color: AppColors.grey700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: reduce ? 0.5 : 0, end: 0.5),
                    duration: reduce
                        ? Duration.zero
                        : const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 6,
                        backgroundColor: AppColors.primary100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Verdict IA Kora Émeraude
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary800,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary900.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: AppColors.primary300,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'AI verdict',
                              style: CardKit.label(
                                12,
                                color: AppColors.primary300,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Works for your skin',
                          style: CardKit.title(19, color: AppColors.grey50),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: reduce ? 0.92 : 0,
                            end: 0.92,
                          ),
                          duration: reduce
                              ? Duration.zero
                              : const Duration(milliseconds: 1600),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => CustomPaint(
                            size: const Size(58, 58),
                            painter: _RingPainter(
                              value: v,
                              color: AppColors.primary300,
                              trackColor: AppColors.primary700,
                            ),
                          ),
                        ),
                        CountUp(
                          end: 92,
                          suffix: '%',
                          style: CardKit.label(
                            14,
                            color: AppColors.grey50,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).motion(
              reduce,
              (a) => a
                  .fadeIn(delay: 500.ms, duration: 450.ms)
                  .slideY(
                    begin: 0.25,
                    end: 0,
                    delay: 500.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.progress});

  final double progress;

  // Valeurs normalisées : 0 = haut, 1 = bas (la courbe monte visuellement).
  static const _values = [0.82, 0.74, 0.78, 0.55, 0.48, 0.30, 0.22];

  @override
  void paint(Canvas canvas, Size size) {
    const primary = AppColors.primary600;

    // Lignes de repère
    final grid = Paint()
      ..color = AppColors.neutral600.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (i / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final pts = <Offset>[
      for (var i = 0; i < _values.length; i++)
        Offset(
          size.width * i / (_values.length - 1),
          size.height * _values[i] * 0.9 + size.height * 0.05,
        ),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final mx = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(
        mx,
        pts[i].dy,
        mx,
        pts[i + 1].dy,
        pts[i + 1].dx,
        pts[i + 1].dy,
      );
    }

    final metric = path.computeMetrics().first;
    final len = metric.length * progress;
    if (len <= 0) return;
    final drawn = metric.extractPath(0, len);
    final end = metric.getTangentForOffset(len)!.position;

    final fill = Path.from(drawn)
      ..lineTo(end.dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary.withValues(alpha: 0.25),
              primary.withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = primary,
      )
      ..drawCircle(end, 8, Paint()..color = primary.withValues(alpha: 0.2))
      ..drawCircle(end, 4.5, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.progress != progress;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final deflated = rect.deflate(3);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = trackColor;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas
      ..drawArc(deflated, 0, math.pi * 2, false, track)
      ..drawArc(deflated, -math.pi / 2, math.pi * 2 * value, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.trackColor != trackColor;
}
