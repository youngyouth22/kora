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

/// Screen presenting the non-medical wellness advisory.
///
/// Complies strictly with Kora Rules Article 5:
/// - Explicitly clarifies cosmetic wellness scope.
/// - Avoids forbidden diagnostic and medical curative claims.
class DisclaimerScreen extends StatelessWidget {
  /// Creates a [DisclaimerScreen].
  const DisclaimerScreen({super.key});

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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          label: 'Kora mascot celebrating',
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
                                      pose: MascotPose.success,
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
                        const SizedBox(height: 12),
                        Text(
                              'Great Start, \n Skincare Lover!',
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
                        const SizedBox(height: 8),
                        Text(
                              "i'm not here to replace your dermatologist "
                              'but i can help you track your skincare journey '
                              'and reach your skin goals!',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMRegular.copyWith(
                                color: AppGreyColors.shade950,
                              ),
                            )
                            .animate(
                              delay: 200.ms,
                              target: disableAnimations ? 1 : null,
                            )
                            .fadeIn(
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 400.ms,
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
                  text: "Let's start!",
                  onPressed: () {
                    unawaited(context.push(AppRoutes.onboardingQuestions));
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
