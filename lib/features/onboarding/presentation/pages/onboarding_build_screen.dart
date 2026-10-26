// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen providing operational transparency and labor illusion (IKEA effect)
/// while synthesizing the user's questionnaire into their baseline plan.
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

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue() {
    unawaited(HapticFeedback.lightImpact());
    if (context.mounted && GoRouter.maybeOf(context) != null) {
      unawaited(context.push(widget.targetDestination));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              final progress = _progressAnimation.value;
              final percent = (progress * 100).round();
              final isComplete = progress >= 0.99;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Kora companion calculating your baseline',
                            child: const MascotIllustration(
                              pose: MascotPose.writing,
                              size: 130,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Building Your Skin Baseline',
                            textAlign: TextAlign.center,
                            style: AppTypography.h3Medium.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Calibrating algorithms to your Fitzpatrick profile, active ingredients, and skin goals.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMRegular.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Circular Progress with Percent
                          _buildCircularProgressIndicator(progress, percent),
                          const SizedBox(height: 32),
                          // Steps checklist
                          ...List.generate(_buildSteps.length, (index) {
                            final stepThreshold =
                                (index + 1) / _buildSteps.length;
                            final isStepDone = progress >= stepThreshold;
                            return _buildStepRow(
                              title: _buildSteps[index],
                              isDone: isStepDone,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: Semantics(
                      button: true,
                      label: 'Continue to Mechanism',
                      child: PrimaryButton(
                        text: isComplete
                            ? 'View How Kora Works'
                            : 'Calibrating...',
                        isLoading: !isComplete,
                        onPressed: isComplete ? _handleContinue : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgressIndicator(double progress, int percent) {
    return Semantics(
      label: 'Calibration progress',
      value: '$percent%',
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary700,
              ),
            ),
          ),
          Text(
            '$percent%',
            style: AppTypography.h4Bold.copyWith(
              color: AppColors.primary900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({required String title, required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary700 : AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_rounded : Icons.hourglass_empty_rounded,
              size: 16,
              color: isDone ? AppColors.neutral50 : AppColors.grey500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMSemiBold.copyWith(
                color: isDone ? AppColors.grey1050 : AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
