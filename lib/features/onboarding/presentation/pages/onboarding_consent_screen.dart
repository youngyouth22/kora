// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen collecting explicit informed consent for photo processing,
/// non-medical wellness advisory, and data retention (Article 5).
class OnboardingConsentScreen extends StatefulWidget {
  /// Creates an [OnboardingConsentScreen].
  const OnboardingConsentScreen({
    this.targetDestination = AppRoutes.onboardingCamera,
    super.key,
  });

  /// Target route path to navigate to upon agreement.
  final String targetDestination;

  @override
  State<OnboardingConsentScreen> createState() =>
      _OnboardingConsentScreenState();
}

class _OnboardingConsentScreenState extends State<OnboardingConsentScreen> {
  bool _isAgreed = true;

  static const List<({IconData icon, String title, String description})>
  _guarantees = [
    (
      icon: Icons.lock_outline_rounded,
      title: 'Private & Encrypted Storage',
      description: 'Your photos are stored in an encrypted private vault with temporary signed URLs. No public access.',
    ),
    (
      icon: Icons.shield_outlined,
      title: 'Zero Data Resale',
      description: 'Your facial biometric data is never sold, rented, or shared with third-party advertisers or cosmetic brands.',
    ),
    (
      icon: Icons.medical_services_outlined,
      title: 'Cosmetic Wellness Scope',
      description: 'Kora tracks cosmetic skin changes and product efficacy. It does not provide medical diagnoses or prescriptions.',
    ),
    (
      icon: Icons.delete_outline_rounded,
      title: 'Complete Deletion Rights',
      description: 'You can permanently delete all your photos and tracking history at any moment with a single tap.',
    ),
  ];

  void _handleContinue() {
    if (!_isAgreed) return;
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
        centerTitle: true,
        title: Text(
          'Consent & Privacy',
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
                        'Your trust comes first',
                        style: AppTypography.h3Medium.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Review our privacy commitments before we prepare your first baseline scan.',
                        style: AppTypography.bodyMRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._guarantees.map(
                        (g) => _buildGuaranteeCard(
                          icon: g.icon,
                          title: g.title,
                          description: g.description,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildConsentCheckbox(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Semantics(
                  button: true,
                  label: 'I Agree and Continue',
                  child: PrimaryButton(
                    text: 'I Agree & Continue',
                    isDisabled: !_isAgreed,
                    onPressed: _isAgreed ? _handleContinue : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuaranteeCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary200),
            ),
            child: Icon(
              icon,
              color: AppColors.primary700,
              size: 20,
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
                const SizedBox(height: 2),
                Text(
                  description,
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

  Widget _buildConsentCheckbox() {
    return Semantics(
      button: true,
      label: 'Acknowledge privacy policy and wellness terms',
      child: InkWell(
        onTap: () => setState(() => _isAgreed = !_isAgreed),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isAgreed ? AppColors.primary50 : AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isAgreed ? AppColors.primary300 : AppColors.grey300,
            ),
          ),
          child: Row(
            children: [
              Checkbox.adaptive(
                value: _isAgreed,
                activeColor: AppColors.primary700,
                onChanged: (val) {
                  setState(() => _isAgreed = val ?? false);
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'I acknowledge the wellness tracking scope and accept the terms of data privacy.',
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
