// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Full-screen scan preparation guide helping users prepare lighting and framing
/// before initializing the live front-camera guided capture.
class ScanGuideScreen extends StatelessWidget {
  /// Creates a [ScanGuideScreen].
  const ScanGuideScreen({
    this.targetDestination = AppRoutes.scanCapture,
    super.key,
  });

  /// Target capture destination.
  final String targetDestination;

  static const List<({int step, String title, String subtitle, IconData icon})>
  _tips = [
    (
      step: 1,
      title: 'Find diffuse, even lighting',
      subtitle: 'Face a window or soft light source. Avoid direct overhead glare or strong shadows.',
      icon: Icons.light_mode_outlined,
    ),
    (
      step: 2,
      title: 'Clean, bare skin',
      subtitle: 'For accurate biomarker scoring, remove makeup, heavy creams, or glistening oils.',
      icon: Icons.face_retouching_natural_outlined,
    ),
    (
      step: 3,
      title: 'Hair back & remove glasses',
      subtitle: 'Tie hair behind ears and take off glasses so your forehead and cheeks are clear.',
      icon: Icons.visibility_outlined,
    ),
    (
      step: 4,
      title: 'Neutral facial expression',
      subtitle: 'Keep your mouth closed and expression relaxed. Look straight ahead into the frame.',
      icon: Icons.sentiment_satisfied_outlined,
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
          'Scan Guide',
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
                        'Set up for your baseline',
                        style: AppTypography.h3Medium.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accurate tracking starts with consistent conditions. Follow these 4 quick tips.',
                        style: AppTypography.bodyMRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._tips.map(_buildTipTile),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Semantics(
                  button: true,
                  label: 'Start Guided Scan',
                  child: PrimaryButton(
                    text: 'Start Guided Scan',
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

  Widget _buildTipTile(
    ({int step, String title, String subtitle, IconData icon}) tip,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey200,
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary200),
            ),
            child: Text(
              '${tip.step}',
              style: AppTypography.bodySBold.copyWith(
                color: AppColors.primary800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tip.title,
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                    ),
                    Icon(
                      tip.icon,
                      size: 20,
                      color: AppColors.primary700,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tip.subtitle,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey700,
                    height: 1.35,
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
