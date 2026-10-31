// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen explaining Kora's scientific tracking principles and mechanism of action.
class OnboardingHowScreen extends StatelessWidget {
  /// Creates an [OnboardingHowScreen].
  const OnboardingHowScreen({
    this.targetDestination = AppRoutes.onboardingConsent,
    super.key,
  });

  /// Target route path to navigate to when user taps continue.
  final String targetDestination;

  static const List<({IconData icon, String title, String description})>
  _pillars = [
    (
      icon: Icons.wb_sunny_outlined,
      title: 'Lighting Normalization',
      description: 'Real-time positioning guidance checks ambient brightness and angle to ensure photos are clinically comparable.',
    ),
    (
      icon: Icons.biotech_rounded,
      title: '16 Deep Biomarkers',
      description: 'Computer vision extracts raw skin health indicators across redness, pores, and dark spots without vanity inflation.',
    ),
    (
      icon: Icons.trending_up_rounded,
      title: 'Weekly Delta vs Daily Noise',
      description: 'Daily fluctuations in water and stress mislead. Weekly comparisons filter noise to prove if your active routine works.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'How Kora Works',
          style: AppTypography.h6SemiBold.copyWith(
            color: AppColors.grey1050,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Science over guesswork',
                        style: AppTypography.h3Medium.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Designed to measure real biological changes in your skin barrier, not marketing illusions.',
                        style: AppTypography.bodyMRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._pillars.map(
                        (pillar) => _buildPillarCard(
                          icon: pillar.icon,
                          title: pillar.title,
                          description: pillar.description,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Semantics(
                  button: true,
                  label: 'Got it, let us continue',
                  child: PrimaryButton(
                    text: "Got it, let's continue",
                    onPressed: () {
                      unawaited(HapticFeedback.lightImpact());
                      if (context.mounted &&
                          GoRouter.maybeOf(context) != null) {
                        unawaited(context.push(targetDestination));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey200,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary200),
            ),
            child: Icon(
              icon,
              color: AppColors.primary700,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey700,
                    height: 1.4,
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
