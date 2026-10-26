import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

/// Support, FAQ, and legal disclaimers screen (C23 in blueprint).
class HelpPage extends StatelessWidget {
  /// Creates a [HelpPage].
  const HelpPage({super.key});

  void _showHelpDialog(BuildContext context, String title, String content) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.grey300),
            ),
            title: Text(
              title,
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            content: Text(
              content,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey900,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.primary700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Help & Legal',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FAQ
              SettingSection(
                title: 'Knowledge Base & FAQ',
                titleTextStyle: AppTypography.h6Bold.copyWith(
                  color: AppColors.grey1050,
                ),
                cardPadding: const EdgeInsets.all(16),
                spacing: 8,
                children: [
                  _buildHelpTile(
                    icon: Icons.analytics_outlined,
                    title: 'How to read my scores',
                    subtitle:
                        'Why raw score matters more than inflated ratings',
                    onTap: () => _showHelpDialog(
                      context,
                      'Understanding Raw Scores',
                      'Kora deliberately displays your raw scientific '
                          'score from the YouCam AI analysis instead of '
                          'flattered UI ratings. Variations under ±3 '
                          'points are considered normal noise (stable). '
                          'True improvement or decline is measured across '
                          'a rolling 3-week average.',
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.grey200),
                  _buildHelpTile(
                    icon: Icons.camera_alt_outlined,
                    title: 'Scan tips for reliable results',
                    subtitle: 'Lighting, distance, and facial angle guidance',
                    onTap: () => _showHelpDialog(
                      context,
                      'Capture Guidelines',
                      '1. Face a natural window with soft daylight.\n'
                          '2. Keep face between 60% and 80% of the frame.\n'
                          '3. Keep neutral expression, eyes open.\n'
                          '4. Clean, unmade skin before tracking.',
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.grey200),
                  _buildHelpTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact support',
                    subtitle: 'Response within 24 hours from our team',
                    onTap: () => _showHelpDialog(
                      context,
                      'Customer Care',
                      'Need assistance? Reach our dedicated support '
                          'team at support@kora.skin. We are happy to help '
                          'with account, subscription, or scan questions.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Legal
              SettingSection(
                title: 'Legal & Compliance',
                titleTextStyle: AppTypography.h6Bold.copyWith(
                  color: AppColors.grey1050,
                ),
                cardPadding: const EdgeInsets.all(16),
                spacing: 8,
                children: [
                  _buildHelpTile(
                    icon: Icons.medical_services_outlined,
                    title: 'Medical disclaimer',
                    subtitle: 'Cosmetic wellness & tracking, not diagnosis',
                    onTap: () => _showHelpDialog(
                      context,
                      'Medical Disclaimer',
                      'Kora is an educational self-tracking tool. '
                          'It does not provide medical diagnosis, '
                          'treatment, cure, or clinical advice. If you '
                          'notice changing moles or persistent irritation, '
                          'consult a licensed dermatologist.',
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.grey200),
                  _buildHelpTile(
                    icon: Icons.code_rounded,
                    title: 'Credits & licenses',
                    subtitle: 'YouCam API, Flutter open-source libraries',
                    onTap: () => _showHelpDialog(
                      context,
                      'Credits & Attribution',
                      '• YouCam Skin AI API (Perfect Corp)\n'
                          '• Flutter framework & Dart runtime\n'
                          '• Drift offline-first database\n'
                          '• Supabase open-source backend\n'
                          '• RevenueCat subscription billing',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Version info
              Center(
                child: Text(
                  'Powered by YouCam Skin AI\nKora v1.0.0 (Release Build)',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary700),
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
                  Text(
                    subtitle,
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.grey600,
            ),
          ],
        ),
      ),
    );
  }
}
