// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_card_kit.dart';

/// Trois scans (semaine 1, 3, 6) qui s'ouvrent en éventail. Le scan de la
/// semaine 6 est analysé en direct : ligne de scan mint, score qui monte, et deux
/// mesures flottantes.
class AnimatedScanStack extends StatelessWidget {
  /// Creates an [AnimatedScanStack].
  const AnimatedScanStack({super.key});

  static const _cardW = 210.0;
  static const _cardH = 290.0;

  @override
  Widget build(BuildContext context) {
    final reduce = CardKit.reduceMotion(context);

    return ScaledCard(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduce ? 1 : 0, end: 1),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 1300),
        builder: (context, t, _) {
          double s(double a, double b) =>
              Interval(a, b, curve: Curves.easeOutCubic).transform(t);

          final back = s(0, 0.7);
          final mid = s(0.1, 0.8);
          final front = s(0.2, 0.9);
          const left = (CardKit.designW - _cardW) / 2;
          const top = (CardKit.designH - _cardH) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: left,
                top: top,
                child: Transform.translate(
                  offset: Offset(-70 * back, 18 * back),
                  child: Transform.rotate(
                    angle: -0.16 * back,
                    child: const _ScanCard(
                      label: 'Week 1',
                      imagePath: ImageResources.onboardingScanWeek1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Transform.translate(
                  offset: Offset(66 * mid, 10 * mid),
                  child: Transform.rotate(
                    angle: 0.10 * mid,
                    child: const _ScanCard(
                      label: 'Week 3',
                      imagePath: ImageResources.onboardingScanWeek3,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: front,
                  child: Transform.translate(
                    offset: Offset(0, 40 * (1 - front)),
                    child: _ScanCard(
                      label: 'Week 6',
                      imagePath: ImageResources.onboardingScanWeek6,
                      isFront: true,
                      reduce: reduce,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 92,
                child:
                    const _FloatChip(
                      icon: Icons.water_drop_rounded,
                      label: 'Hydration',
                      value: '+32%',
                      iconColor: AppColors.primary700,
                    ).motion(
                      reduce,
                      (a) => a
                          .fadeIn(delay: 900.ms, duration: 400.ms)
                          .scale(
                            begin: const Offset(0.6, 0.6),
                            delay: 900.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
              ),
              Positioned(
                right: 0,
                bottom: 78,
                child:
                    const _FloatChip(
                      icon: Icons.blur_on_rounded,
                      label: 'Texture',
                      value: '-24%',
                      iconColor: AppColors.secondary500,
                    ).motion(
                      reduce,
                      (a) => a
                          .fadeIn(delay: 1100.ms, duration: 400.ms)
                          .scale(
                            begin: const Offset(0.6, 0.6),
                            delay: 1100.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.label,
    required this.imagePath,
    this.isFront = false,
    this.reduce = false,
  });

  final String label;
  final String imagePath;
  final bool isFront;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AnimatedScanStack._cardW,
      height: AnimatedScanStack._cardH,
      padding: const EdgeInsets.all(7),
      decoration: CardKit.decoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo de scan réelle
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
            // Dégradé d'ambiance et lisibilité
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.baseColor.withValues(alpha: 0.35),
                    AppColors.baseColor.withValues(alpha: 0),
                    AppColors.baseColor.withValues(
                      alpha: isFront ? 0.45 : 0.25,
                    ),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Points de repère du visage en mode analyse active
            if (isFront)
              const CustomPaint(
                painter: _LandmarksPainter(),
              ),
            // Pastille Semaine
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isFront
                        ? AppColors.primary400
                        : AppColors.neutral600.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  label,
                  style: CardKit.label(
                    11.5,
                    color: isFront ? AppColors.primary800 : AppColors.baseColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (isFront) ...[
              // Laser d'analyse vert menthe Kora
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child:
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0),
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ).motion(
                      reduce,
                      (a) => a.moveY(
                        begin: 30,
                        end: 190,
                        duration: 2200.ms,
                        curve: Curves.easeInOut,
                      ),
                      onPlay: (c) => c.repeat(reverse: true),
                    ),
              ),
              // Capsule de score en bas
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldColor.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.baseColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skin score',
                              style: CardKit.label(
                                10,
                                color: AppColors.grey700,
                              ),
                              maxLines: 1,
                            ),
                            CountUp(
                              end: 84,
                              style: CardKit.title(
                                22,
                                color: AppColors.primary800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 13,
                              color: AppColors.scaffoldColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '+18',
                              style: CardKit.label(
                                11.5,
                                color: AppColors.scaffoldColor,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final reduce = CardKit.reduceMotion(context);
    const primary = AppColors.primary700;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      decoration: CardKit.decoration(radius: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (iconColor ?? primary).withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 16, color: iconColor ?? primary),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: CardKit.label(10.5, color: AppColors.grey700)),
              Text(
                value,
                style: CardKit.title(15, color: AppColors.primary800),
              ),
            ],
          ),
        ],
      ),
    ).motion(
      reduce,
      (a) => a.moveY(
        begin: -3,
        end: 3,
        duration: 2600.ms,
        curve: Curves.easeInOut,
      ),
      onPlay: (c) => c.repeat(reverse: true),
    );
  }
}

class _LandmarksPainter extends CustomPainter {
  const _LandmarksPainter();

  @override
  void paint(Canvas canvas, Size s) {
    const points = [
      Offset(0.38, 0.35),
      Offset(0.62, 0.35),
      Offset(0.50, 0.47),
      Offset(0.50, 0.28),
      Offset(0.35, 0.50),
      Offset(0.65, 0.50),
    ];
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.primary300;
    final dot = Paint()..color = AppColors.primary50;
    for (final p in points) {
      final o = Offset(p.dx * s.width, p.dy * s.height);
      canvas
        ..drawCircle(o, 6, ring)
        ..drawCircle(o, 2.5, dot);
    }
  }

  @override
  bool shouldRepaint(_LandmarksPainter old) => false;
}
