// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_curve_visual.dart';
import 'package:kora/features/onboarding/presentation/widgets/reassurance_badge.dart';

/// Welcome screen introducing Kora to new users.
///
/// Adheres strictly to the specification:
/// - Title <= 8 words: "Find out if your routine really works"
/// - Stylized curve and diverse skin tone visual
/// - 3 reassurance bullets: Private · Science-based · No jargon
/// - Single primary CTA "Get started" + secondary "I already have an account"
/// - Visible without scrolling on 5.4" displays
/// - Supports 200% font accessibility scaling
/// - Zero prohibited medical diagnostic claims
/// - Emits `onboarding_started` event on initialization
class WelcomeScreen extends StatefulWidget {
  /// Creates a [WelcomeScreen].
  const WelcomeScreen({
    this.source = 'app_store',
    super.key,
  });

  /// Attribution source for the start event.
  final String source;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch analytics tracking event on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OnboardingBloc>().add(
          OnboardingStartedEvent(source: widget.source),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top header & branding
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'KORA',
                            style: AppTypography.h6Bold.copyWith(
                              color: AppColors.primary800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title <= 8 words
                          Text(
                            'Find out if your routine really works',
                            style: AppTypography.h3Bold.copyWith(
                              color: AppColors.baseColor,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Visual: Stylized curve + diverse skin tones
                          const OnboardingCurveVisual(),
                          const SizedBox(height: 16),
                          // 3 Reassurance Bullets
                          const Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ReassuranceBadge(
                                label: 'Private',
                                icon: Icons.lock_outline_rounded,
                              ),
                              ReassuranceBadge(
                                label: 'Science-based',
                                icon: Icons.biotech_rounded,
                              ),
                              ReassuranceBadge(
                                label: 'No jargon',
                                icon: Icons.chat_bubble_outline_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bottom CTAs: 52dp height, full-width, single primary CTA
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: 'Get started',
                            onPressed: () {
                              unawaited(
                                context.push(AppRoutes.onboardingMascot),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Secondary link
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 48,
                                minWidth: 48,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  unawaited(
                                    context.push(AppRoutes.accountSecure),
                                  );
                                },
                                child: Text(
                                  'I already have an account',
                                  style: AppTypography.bodyMSemiBold.copyWith(
                                    color: AppColors.grey800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
