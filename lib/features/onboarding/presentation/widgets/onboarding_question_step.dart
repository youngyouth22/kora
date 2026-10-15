import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';

/// Reusable layout for questionnaire and demographic onboarding steps.
///
/// Standardizes the header typography, subtitle styling, mascot display,
/// and options layout across onboarding screens (e.g. Demographics and Quiz).
class OnboardingQuestionStep extends StatelessWidget {
  /// Creates an [OnboardingQuestionStep].
  const OnboardingQuestionStep({
    required this.title,
    required this.child,
    this.subtitle,
    this.mascotPose,
    this.mascot,
    this.mascotHeroTag,
    this.mascotSize = 70,
    this.mascotAlignment = Alignment.center,
    this.isScrollable = true,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// The main question or step headline.
  final String title;

  /// Optional secondary explanation or context.
  final String? subtitle;

  /// Optional mascot pose variant to render via [MascotIllustration].
  final MascotPose? mascotPose;

  /// Optional custom mascot widget. If provided, takes precedence over
  /// [mascotPose].
  final Widget? mascot;

  /// Optional Hero tag for animating the mascot across screen transitions.
  final String? mascotHeroTag;

  /// Sizing for the mascot illustration. Defaults to 96.0.
  final double mascotSize;

  /// Alignment of the mascot illustration within its container. Defaults to
  /// [Alignment.center].
  final Alignment mascotAlignment;

  /// The widget containing the question options or interactive elements.
  final Widget child;

  /// Whether the question step content is scrollable. Defaults to true.
  final bool isScrollable;

  /// Padding around the content. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Widget? mascotWidget;
    if (mascot != null) {
      mascotWidget = mascot;
    } else if (mascotPose != null) {
      mascotWidget = MascotIllustration(
        pose: mascotPose!,
        size: mascotSize,
      );
    }

    if (mascotWidget != null && mascotHeroTag != null) {
      mascotWidget = Hero(
        tag: mascotHeroTag!,
        flightShuttleBuilder: mascotHeroFlightShuttleBuilder,
        child: mascotWidget,
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 12,
          children: [
            if (mascotWidget != null) ...[
              Align(
                alignment: mascotAlignment,
                child: Semantics(
                  label: 'Kora companion mascot',
                  child: mascotWidget,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    title,
                    style: AppTypography.h4Medium.copyWith(
                      color: AppGreyColors.shade1050,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMRegular.copyWith(
                        color: AppGreyColors.shade950,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        child,
      ],
    );

    if (isScrollable) {
      return SingleChildScrollView(
        padding: padding,
        child: content,
      );
    }

    return Padding(
      padding: padding,
      child: content,
    );
  }
}

/// Alias for [OnboardingQuestionStep] allowing flexible naming.
typedef OnboardingQuestionLayout = OnboardingQuestionStep;
