// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_card_kit.dart';

/// Preuve sociale : note 4.9 étoiles dorées, avatars aux teintes de peau diverses,
/// témoignages qui défilent et grille de régularité vert émeraude Kora.
class AnimatedSocialProofCard extends StatefulWidget {
  /// Creates an [AnimatedSocialProofCard].
  const AnimatedSocialProofCard({super.key});

  @override
  State<AnimatedSocialProofCard> createState() =>
      _AnimatedSocialProofCardState();
}

class _AnimatedSocialProofCardState extends State<AnimatedSocialProofCard> {
  static const _quotes = <({String text, String name, String initial})>[
    (
      text:
          'My breakouts calmed down in three weeks. I finally know what works.',
      name: 'Amina, 28',
      initial: 'A',
    ),
    (
      text: "The AI verdict saved me from buying three products I didn't need.",
      name: 'Lucas, 31',
      initial: 'L',
    ),
    (
      text: 'Seeing my progress every week keeps me consistent.',
      name: 'Sofia, 25',
      initial: 'S',
    ),
  ];

  // 0 = vide, 1..3 = intensité de régularité (7 colonnes x 4 lignes).
  static const _grid = [
    1, 2, 3, 3, 2, 3, 3, //
    2, 3, 3, 3, 3, 2, 3,
    3, 3, 2, 3, 3, 3, 3,
    3, 3, 3, 1, 0, 0, 0,
  ];

  static const List<Color> _avatarColors = [
    AppSkinToneColors.typeI,
    AppSkinToneColors.typeIII,
    AppSkinToneColors.typeIV,
    AppPrimaryColors.shade200,
    AppSkinToneColors.typeV,
  ];

  Timer? _timer;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (!CardKit.reduceMotion(context)) {
      _timer = Timer.periodic(const Duration(milliseconds: 3600), (_) {
        if (mounted) setState(() => _index = (_index + 1) % _quotes.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = CardKit.reduceMotion(context);
    final quote = _quotes[_index];

    return ScaledCard(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: CardKit.decoration(radius: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Note + avatars
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CountUp(end: 4.9, decimals: 1, style: CardKit.title(46)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          const Icon(
                            Icons.star_rounded,
                            size: 19,
                            color: AppColors.secondary500,
                          ).motion(
                            reduce,
                            (a) => a
                                .fadeIn(delay: (300 + i * 90).ms)
                                .scale(
                                  begin: const Offset(0.3, 0.3),
                                  delay: (300 + i * 90).ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 34 + 4 * 24.0,
                        height: 38,
                        child: Stack(
                          children: [
                            for (var i = 0; i < 5; i++)
                              Positioned(
                                left: i * 24.0,
                                child:
                                    InitialAvatar(
                                      initial: 'AKLSM'[i],
                                      size: 38,
                                      backgroundColor: _avatarColors[i],
                                      textColor: AppColors.baseColor,
                                    ).motion(
                                      reduce,
                                      (a) => a
                                          .fadeIn(delay: (i * 80).ms)
                                          .slideX(
                                            begin: 0.6,
                                            end: 0,
                                            delay: (i * 80).ms,
                                            duration: 500.ms,
                                            curve: Curves.easeOutCubic,
                                          ),
                                    ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '12k+ routines tracked',
                        style: CardKit.label(12, color: AppColors.grey700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Témoignage
            Container(
              constraints: const BoxConstraints(minHeight: 96),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary50.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.primary100),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.18),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey(_index),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quote.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: CardKit.label(
                        14,
                        color: AppColors.baseColor,
                        weight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        InitialAvatar(
                          initial: quote.initial,
                          size: 24,
                          backgroundColor: AppColors.primary100,
                          textColor: AppColors.primary800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          quote.name,
                          style: CardKit.label(12, color: AppColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).motion(
              reduce,
              (a) => a.fadeIn(delay: 250.ms, duration: 450.ms),
            ),

            // Régularité vert émeraude Kora
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Routine consistency',
                      style: CardKit.label(12.5, color: AppColors.grey700),
                    ),
                    const Spacer(),
                    CountUp(
                      end: 86,
                      suffix: '%',
                      style: CardKit.title(17, color: AppColors.primary700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: reduce ? 1 : 0, end: 1),
                  duration: reduce
                      ? Duration.zero
                      : const Duration(milliseconds: 1500),
                  builder: (context, t, _) => Column(
                    children: [
                      for (var r = 0; r < 4; r++) ...[
                        if (r > 0) const SizedBox(height: 6),
                        Row(
                          children: [
                            for (var c = 0; c < 7; c++) ...[
                              if (c > 0) const SizedBox(width: 6),
                              Expanded(child: _cell(r * 7 + c, t)),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ).motion(
              reduce,
              (a) => a.fadeIn(delay: 450.ms, duration: 450.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(int i, double t) {
    final level = _grid[i];
    final start = (i / _grid.length) * 0.6;
    final v = Interval(
      start,
      start + 0.4,
      curve: Curves.easeOutBack,
    ).transform(t).clamp(0.0, 1.0);

    final colors = [
      AppColors.neutral600.withValues(alpha: 0.15),
      AppColors.primary100,
      AppColors.primary300,
      AppColors.primary600,
    ];

    return Transform.scale(
      scale: 0.5 + 0.5 * v,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: colors[level].withValues(
            alpha: level == 0 ? 0.3 * v : v,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
