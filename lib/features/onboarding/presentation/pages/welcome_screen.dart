import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kora/features/onboarding/presentation/widgets/animated_product_experiment_card.dart';
import 'package:kora/features/onboarding/presentation/widgets/animated_scan_stack.dart';
import 'package:kora/features/onboarding/presentation/widgets/animated_social_proof_card.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_card_kit.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';

/// Onboarding de bienvenue en 3 étapes.
///
/// Signature visuelle (le seul "moment fort", le reste reste sobre) :
/// un parallax à 3 couches. Le fond ambiant, l'illustration et le titre
/// bougent à des vitesses différentes pendant le swipe, ce qui donne de la
/// profondeur. Le titre se révèle ligne par ligne quand la page devient
/// active, et l'indicateur d'étape s'étire comme une pilule.
class WelcomeScreen extends StatefulWidget {
  /// Creates a [WelcomeScreen].
  const WelcomeScreen({
    this.source = 'app_store',
    this.sessionState,
    super.key,
  });

  /// Attribution source for the start event.
  final String source;

  /// Optional injected [AppSessionState] for routing and testing.
  final AppSessionState? sessionState;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _lastPage = 2;

  late final PageController _pageController;
  int _currentPage = 0;

  static const _slides = <_SlideData>[
    _SlideData(
      lines: ["Track your skin's evolution", 'without the guesswork'],
      subtitle: 'Scan once a week and see what really changes.',
      visual: AnimatedScanStack(),
    ),
    _SlideData(
      lines: ['Test skincare products', 'with real AI verdicts'],
      subtitle: 'Know in days if a product works for your skin.',
      visual: AnimatedProductExperimentCard(),
    ),
    _SlideData(
      lines: ['Achieve consistent results', 'backed by real science'],
      subtitle: 'Join people who stick to a routine that works.',
      visual: AnimatedSocialProofCard(),
    ),
  ];

  AppSessionState? get _sessionState =>
      widget.sessionState ??
      (GetIt.instance.isRegistered<AppSessionState>()
          ? GetIt.instance<AppSessionState>()
          : null);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OnboardingBloc>().add(
          OnboardingStartedEvent(source: widget.source),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _onNext() {
    if (_currentPage < _lastPage) {
      _goToPage(_currentPage + 1);
    } else {
      unawaited(context.push(AppRoutes.onboardingMascot));
    }
  }

  void _onSkip() {
    unawaited(context.push(AppRoutes.onboardingMascot));
  }

  void _onAlreadyHaveAccount() {
    _sessionState?.setIntendedDestination(AppRoutes.home);
    unawaited(context.push(AppRoutes.accountSecure));
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = CardKit.reduceMotion(context);
    final isLast = _currentPage == _lastPage;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: Stack(
        children: [
          // Couche 1 : fond ambiant (bouge le plus lentement).
          Positioned.fill(
            child: _AmbientBackground(controller: _pageController),
          ),

          SafeArea(
            child: Column(
              children: [
                // Barre du haut : "Skip" disparaît sur la dernière page.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isLast ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: isLast,
                          child: Semantics(
                            button: true,
                            label: 'Skip onboarding introduction',
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: TextButton(
                                onPressed: _onSkip,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Skip',
                                      style: AppTypography.bodyMSemiBold
                                          .copyWith(
                                            color: AppColors.grey700,
                                          ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.grey700,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _slides.length,
                    onPageChanged: (page) {
                      unawaited(HapticFeedback.selectionClick());
                      setState(() => _currentPage = page);
                    },
                    itemBuilder: (context, index) => _OnboardingSlide(
                      key: ValueKey('step_$index'),
                      index: index,
                      data: _slides[index],
                      controller: _pageController,
                      isActive: index == _currentPage,
                      reduceMotion: reduceMotion,
                    ),
                  ),
                ),

                // Indicateur + CTA
                Center(
                  child:
                      ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OnboardingStepIndicator(
                                    currentStep: _currentPage,
                                    totalSteps: _slides.length,
                                    onStepTapped: _goToPage,
                                  ),
                                  const SizedBox(height: 16),
                                  PrimaryButton(
                                    key: const ValueKey('onboarding_next_cta'),
                                    text: isLast ? 'Get started' : 'Continue',
                                    onPressed: _onNext,
                                  ),
                                  const SizedBox(height: 4),
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 48,
                                        minWidth: 48,
                                      ),
                                      child: TextButton(
                                        onPressed: _onAlreadyHaveAccount,
                                        child: Text(
                                          'I already have an account',
                                          style: AppTypography.bodyMSemiBold
                                              .copyWith(
                                                color: AppColors.grey800,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          )
                          .animate(target: reduceMotion ? 1 : null)
                          .fadeIn(duration: 500.ms, delay: 250.ms)
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            duration: 600.ms,
                            delay: 250.ms,
                            curve: Curves.easeOutCubic,
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.lines,
    required this.subtitle,
    required this.visual,
  });

  final List<String> lines;
  final String subtitle;
  final Widget visual;
}

/// Une page du carousel : illustration (parallax moyen) + texte (parallax
/// rapide). Le titre se révèle ligne par ligne quand la page est active.
class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.index,
    required this.data,
    required this.controller,
    required this.isActive,
    required this.reduceMotion,
    super.key,
  });

  final int index;
  final _SlideData data;
  final PageController controller;
  final bool isActive;
  final bool reduceMotion;

  /// Position relative de cette page : 0 = centrée, -1 = partie à gauche,
  /// 1 = arrive par la droite.
  double _delta(int fallbackPage) {
    if (controller.hasClients && controller.position.haveDimensions) {
      return index - (controller.page ?? fallbackPage.toDouble());
    }
    return index.toDouble() - fallbackPage;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final delta = _delta(0);
            final distance = delta.abs().clamp(0.0, 1.0);
            final fade = 1 - distance;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // Illustration : glisse à 35 % de la vitesse de la
                          // page, rétrécit légèrement et s'efface.
                          Center(
                            child: Opacity(
                              opacity: (0.25 + 0.75 * fade).clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(delta * 70, 0),
                                child: Transform.scale(
                                  scale: 1 - 0.08 * distance,
                                  child: _BreathingHalo(
                                    reduceMotion: reduceMotion,
                                    child: data.visual,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Texte : glisse plus vite que l'illustration.
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 16),
                            child: Opacity(
                              opacity: fade,
                              child: Transform.translate(
                                offset: Offset(delta * 140, 0),
                                child: _SlideText(
                                  data: data,
                                  isActive: isActive,
                                  reduceMotion: reduceMotion,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SlideText extends StatelessWidget {
  const _SlideText({
    required this.data,
    required this.isActive,
    required this.reduceMotion,
  });

  final _SlideData data;
  final bool isActive;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final lines = data.lines;
    // Chaque ligne démarre un peu après la précédente (effet cascade).
    final total = lines.length + 1; // +1 pour le sous-titre

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
      duration: reduceMotion
          ? Duration.zero
          : Duration(milliseconds: isActive ? 1000 : 250),
      builder: (context, t, _) {
        double stagger(int i) {
          final start = (i * 0.16).clamp(0.0, 0.8);
          final end = (start + 0.45).clamp(0.0, 1.0);
          return Interval(start, end, curve: Curves.easeOutCubic).transform(t);
        }

        Widget reveal(int i, Widget child) {
          final v = stagger(i);
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, (1 - v) * 18),
              child: child,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            reveal(
              0,
              Text(
                lines.join('\n'),
                style: AppTypography.h4Bold.copyWith(
                  color: AppColors.baseColor,
                  height: 1.2,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            reveal(
              total - 1,
              Text(
                data.subtitle,
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey700,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Halo doux qui "respire" derrière l'illustration.
class _BreathingHalo extends StatelessWidget {
  const _BreathingHalo({required this.child, required this.reduceMotion});

  final Widget child;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final halo = IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.primary.withValues(alpha: 0),
            ],
          ),
        ),
        child: const SizedBox(width: 340, height: 340),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (reduceMotion)
          halo
        else
          halo
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.12, 1.12),
                duration: 3200.ms,
                curve: Curves.easeInOut,
              ),
        child,
      ],
    );
  }
}

/// Fond ambiant : deux halos qui dérivent lentement avec le swipe.
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final page =
              controller.hasClients && controller.position.haveDimensions
              ? (controller.page ?? 0)
              : 0.0;

          Widget blob(Alignment alignment, double size, double alpha) {
            return Align(
              alignment: alignment,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: alpha),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: SizedBox(width: size, height: size),
              ),
            );
          }

          return Stack(
            children: [
              blob(Alignment(-1.2 + page * 0.5, -0.9 + page * 0.1), 420, 0.08),
              blob(Alignment(1.3 - page * 0.5, 0.6 - page * 0.15), 360, 0.06),
            ],
          );
        },
      ),
    );
  }
}
