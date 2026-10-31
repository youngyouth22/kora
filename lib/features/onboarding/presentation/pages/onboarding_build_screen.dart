// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen providing operational transparency and labor illusion (IKEA effect)
/// while synthesizing the user's questionnaire into their baseline plan.
///
/// Composition :
/// - un cadran (ticks + arc lumineux) autour de la mascotte,
/// - une pastille de pourcentage qui chevauche le cadran,
/// - une carte de checklist où l'étape en cours est mise en avant,
/// - un retour haptique à chaque étape terminée.
class OnboardingBuildScreen extends StatefulWidget {
  /// Creates an [OnboardingBuildScreen].
  const OnboardingBuildScreen({
    this.targetDestination = AppRoutes.onboardingHow,
    this.autoAdvanceDuration = const Duration(milliseconds: 3600),
    super.key,
  });

  /// Target route path to navigate to when build calculation completes.
  final String targetDestination;

  /// Duration before auto-advancing if not manually tapped.
  final Duration autoAdvanceDuration;

  @override
  State<OnboardingBuildScreen> createState() => _OnboardingBuildScreenState();
}

class _OnboardingBuildScreenState extends State<OnboardingBuildScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;
  Timer? _autoAdvanceTimer;
  int _lastDoneCount = 0;
  bool _hasNavigated = false;

  static const List<String> _buildSteps = [
    'Fitzpatrick skin tone calibration',
    '16 dermatological baseline markers',
    'Active ingredients tolerance protocol',
    'Weekly delta noise-reduction filter',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.autoAdvanceDuration,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // Un léger "tick" haptique à chaque étape terminée.
    _controller.addListener(_onTick);
    _controller.forward();

    _autoAdvanceTimer = Timer(
      widget.autoAdvanceDuration + const Duration(milliseconds: 400),
      () {
        if (mounted) {
          _handleContinue();
        }
      },
    );
  }

  void _onTick() {
    final done = (_progressAnimation.value * _buildSteps.length + 0.001)
        .floor()
        .clamp(0, _buildSteps.length);
    if (done > _lastDoneCount) {
      _lastDoneCount = done;
      unawaited(HapticFeedback.selectionClick());
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _autoAdvanceTimer?.cancel();
    unawaited(HapticFeedback.lightImpact());
    if (context.mounted && GoRouter.maybeOf(context) != null) {
      unawaited(context.push(widget.targetDestination));
    }
  }

  Widget _live(Widget Function(double progress) builder) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) => builder(_progressAnimation.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTest =
        const bool.fromEnvironment('flutter.test') ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final reduce =
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) || isTest;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(child: _live(_buildAmbient)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final ring = math
                                .min(
                                  math.min(constraints.maxWidth, 240),
                                  constraints.maxHeight * 0.38,
                                )
                                .clamp(150.0, 240.0);

                            return SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 16),
                                    _live(
                                      (p) => _buildRing(
                                        ring.toDouble(),
                                        p,
                                        reduce,
                                      ),
                                    ).reveal(reduce: reduce, scale: true),
                                    const SizedBox(height: 28),
                                    _live(_buildHeadline).reveal(
                                      reduce: reduce,
                                      delayMs: 150,
                                    ),
                                    const SizedBox(height: 24),
                                    _live(_buildStepsCard).reveal(
                                      reduce: reduce,
                                      delayMs: 300,
                                      dy: 0.08,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: _live(_buildCta)
                            .reveal(reduce: reduce, delayMs: 450),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fond ambiant : deux halos qui dérivent avec la progression.
  // ---------------------------------------------------------------------------
  Widget _buildAmbient(double progress) {
    Widget blob(Alignment alignment, double size, double alpha) => Align(
      alignment: alignment,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary700.withValues(alpha: alpha),
              AppColors.primary700.withValues(alpha: 0),
            ],
          ),
        ),
        child: SizedBox(width: size, height: size),
      ),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          blob(Alignment(-1.2 + progress * 0.6, -0.95), 440, 0.10),
          blob(
            Alignment(1.3 - progress * 0.5, 0.75 - progress * 0.2),
            380,
            0.07,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cadran + mascotte + pastille de pourcentage.
  // ---------------------------------------------------------------------------
  Widget _buildRing(double size, double progress, bool reduce) {
    final percent = (progress * 100).round();
    final disc = size * 0.56;

    Widget mascot = MascotIllustration(
      pose: MascotPose.writing,
      size: disc * 0.78,
    );
    if (!reduce) {
      mascot = mascot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: -3,
            end: 3,
            duration: 2400.ms,
            curve: Curves.easeInOut,
          );
    }

    return Semantics(
      label: 'Calibration progress',
      value: '$percent%',
      child: SizedBox(
        width: size,
        height: size + 20,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: _DialPainter(progress: progress),
                  ),
                  Container(
                    width: disc,
                    height: disc,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neutral50,
                      border: Border.all(color: AppColors.grey200),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary700.withValues(alpha: 0.18),
                          blurRadius: 36,
                          spreadRadius: -6,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Semantics(
                      label: 'Kora companion calculating your baseline',
                      child: mascot,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.grey200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary900.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    '$percent%',
                    style: AppTypography.h4Bold.copyWith(
                      fontSize: 20,
                      height: 1.1,
                      color: AppColors.primary900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Titre + sous-titre (changent quand le calcul est terminé).
  // ---------------------------------------------------------------------------
  Widget _buildHeadline(double progress) {
    final isComplete = progress >= 0.99;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(isComplete),
        children: [
          Text(
            isComplete
                ? 'Your Baseline Is Ready'
                : 'Building Your Skin Baseline',
            textAlign: TextAlign.center,
            style: AppTypography.h3Medium.copyWith(
              color: AppColors.grey1050,
              height: 1.15,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isComplete
                ? 'Your personalised plan is set. See how Kora tracks your progress.'
                : 'Calibrating algorithms to your Fitzpatrick profile, active ingredients, and skin goals.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMRegular.copyWith(
              color: AppColors.grey700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Carte de checklist.
  // ---------------------------------------------------------------------------
  Widget _buildStepsCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withValues(alpha: 0.07),
            blurRadius: 36,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < _buildSteps.length; i++)
            _buildStepRow(index: i, progress: progress),
        ],
      ),
    );
  }

  Widget _buildStepRow({required int index, required double progress}) {
    final n = _buildSteps.length;
    final local = ((progress * n) - index).clamp(0.0, 1.0);
    final isDone = local >= 0.999;
    final isActive = !isDone && progress * n >= index;

    final statusText = isDone
        ? 'Done'
        : isActive
        ? '${(local * 100).round()}%'
        : 'Queued';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary700.withValues(alpha: 0.07)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildLeading(
            index: index,
            isDone: isDone,
            isActive: isActive,
            local: local,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppTypography.bodyMSemiBold.copyWith(
                color: isDone || isActive
                    ? AppColors.grey1050
                    : AppColors.grey600,
              ),
              child: Text(_buildSteps[index]),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: AppTypography.bodyMSemiBold.copyWith(
              fontSize: 12,
              color: isDone
                  ? AppColors.primary700
                  : isActive
                  ? AppColors.primary900
                  : AppColors.grey500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            child: Text(statusText),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading({
    required int index,
    required bool isDone,
    required bool isActive,
    required double local,
  }) {
    const size = 30.0;

    final Widget child;
    if (isDone) {
      child = Container(
        key: ValueKey('done_$index'),
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primary700,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 18,
          color: AppColors.neutral50,
        ),
      );
    } else if (isActive) {
      child = SizedBox(
        key: ValueKey('active_$index'),
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: math.max(local, 0.06),
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary700,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary700,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    } else {
      child = Container(
        key: ValueKey('pending_$index'),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.grey200, width: 2),
        ),
        child: Text(
          '${index + 1}',
          style: AppTypography.bodyMSemiBold.copyWith(
            fontSize: 12,
            color: AppColors.grey500,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // CTA
  // ---------------------------------------------------------------------------
  Widget _buildCta(double progress) {
    final isComplete = progress >= 0.99;

    return Semantics(
      button: true,
      label: 'Continue to Mechanism',
      child: PrimaryButton(
        text: isComplete ? 'View How Kora Works' : 'Calibrating...',
        isLoading: !isComplete,
        onPressed: isComplete ? _handleContinue : null,
      ),
    );
  }
}

/// Apparition douce (fondu + glissement) des blocs de l'écran. Ignorée si
/// l'utilisateur a désactivé les animations.
extension _Reveal on Widget {
  Widget reveal({
    required bool reduce,
    int delayMs = 0,
    double dy = 0.12,
    bool scale = false,
  }) {
    if (reduce) return this;
    var a = animate()
        .fadeIn(duration: 450.ms, delay: delayMs.ms)
        .slideY(
          begin: dy,
          end: 0,
          duration: 550.ms,
          delay: delayMs.ms,
          curve: Curves.easeOutCubic,
        );
    if (scale) {
      a = a.scale(
        begin: const Offset(0.88, 0.88),
        end: const Offset(1, 1),
        duration: 650.ms,
        delay: delayMs.ms,
        curve: Curves.easeOutBack,
      );
    }
    return a;
  }
}

/// Cadran : ticks qui s'allument + arc dégradé avec halo et pointe.
class _DialPainter extends CustomPainter {
  const _DialPainter({required this.progress});

  final double progress;

  static const _tickCount = 72;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Ticks
    final tick = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _tickCount; i++) {
      final fraction = i / _tickCount;
      final angle = -math.pi / 2 + 2 * math.pi * fraction;
      final length = i % 6 == 0 ? 11.0 : 6.0;
      final dir = Offset(math.cos(angle), math.sin(angle));
      tick.color = fraction < progress
          ? AppColors.primary700
          : AppColors.grey200;
      canvas.drawLine(
        center + dir * (radius - 2),
        center + dir * (radius - 2 - length),
        tick,
      );
    }

    // Arc
    final arcRect = Rect.fromCircle(center: center, radius: radius - 24);
    const stroke = 8.0;

    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.grey200.withValues(alpha: 0.6),
    );

    if (progress <= 0.005) return;
    final sweep = 2 * math.pi * progress;

    // Halo
    canvas
      ..drawArc(
        arcRect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primary700.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      )
      // Arc dégradé (queue transparente -> tête pleine)
      ..drawArc(
        arcRect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            endAngle: math.max(sweep, 0.01),
            transform: const GradientRotation(-math.pi / 2),
            colors: [
              AppColors.primary700.withValues(alpha: 0.45),
              AppColors.primary700,
            ],
          ).createShader(arcRect),
      );

    // Pointe
    final tipAngle = -math.pi / 2 + sweep;
    final tip =
        center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * (radius - 24);
    canvas
      ..drawCircle(tip, 8, Paint()..color = AppColors.neutral50)
      ..drawCircle(
        tip,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = AppColors.primary700,
      );
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.progress != progress;
}
