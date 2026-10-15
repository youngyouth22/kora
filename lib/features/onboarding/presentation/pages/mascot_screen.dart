// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/app_constants.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen introducing the Kora Mascot / companion to the user.
class MascotScreen extends StatelessWidget {
  /// Creates a [MascotScreen].
  const MascotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          label: 'Kora mascot waving hello',
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 240,
                                      sigmaY: 240,
                                      tileMode: TileMode.decal,
                                    ),
                                    child: Container(
                                      width: 126,
                                      height: 180,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary500,
                                        borderRadius: BorderRadius.all(
                                          Radius.elliptical(63, 90),
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate(
                                    target: disableAnimations ? 1 : null,
                                  )
                                  .fadeIn(
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .scale(
                                    begin: const Offset(0.7, 0.7),
                                    end: const Offset(1, 1),
                                    duration: 500.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                              const Hero(
                                    tag: AppConstants.mascotHeroTag,
                                    flightShuttleBuilder:
                                        mascotHeroFlightShuttleBuilder,
                                    child: MascotIllustration(
                                      pose: MascotPose.wave,
                                      size: 200,
                                    ),
                                  )
                                  .animate(
                                    target: disableAnimations ? 1 : null,
                                  )
                                  .fadeIn(
                                    duration: 350.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .scale(
                                    begin: const Offset(0.6, 0.6),
                                    end: const Offset(1, 1),
                                    duration: 450.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                              "Hi, I'm Kora!\nHere to help you boost your skincare results",
                              textAlign: TextAlign.center,
                              style: AppTypography.h3Medium.copyWith(
                                color: AppGreyColors.shade1050,
                              ),
                            )
                            .animate(
                              delay: 150.ms,
                              target: disableAnimations ? 1 : null,
                            )
                            .fadeIn(
                              duration: 350.ms,
                              curve: Curves.easeOut,
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 350.ms,
                              curve: Curves.easeOutQuad,
                            ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom CTA
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 16),
                child: PrimaryButton(
                  text: 'Next',
                  onPressed: () {
                    unawaited(context.push(AppRoutes.onboardingDemographics));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
