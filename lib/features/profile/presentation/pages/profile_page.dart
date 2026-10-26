// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';
import 'package:kora/features/profile/presentation/widgets/setting_tile.dart';
import 'package:kora/features/profile/presentation/widgets/social_share_section.dart';

/// User profile and main settings dashboard (C19 in blueprint).
class ProfilePage extends StatelessWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User header card
              _buildProfilePreview(),
              const SizedBox(height: 32),

              // Skin Profile Summary
              SettingSection(
                title: 'Personalization',
                children: [
                  SettingTile(
                    icon: Icons.track_changes_rounded,
                    title: 'Routine Preferences',
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Icons.face_retouching_natural_rounded,
                    title: 'Skin profile',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Account & Preferences
              SettingSection(
                title: 'Account & Settings',
                children: [
                  SettingTile(
                    icon: Icons.card_membership_rounded,
                    title: 'Subscription',
                    onTap: () => context.push(AppRoutes.profileSubscription),
                  ),
                  SettingTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & data',
                    onTap: () => context.push(AppRoutes.profilePrivacy),
                  ),
                  SettingTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => context.push(AppRoutes.profileNotifications),
                  ),
                  SettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & legal',
                    onTap: () => context.push(AppRoutes.profileHelp),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Social channels and share section
              const SocialShareSection(
                title: 'Get involved',
              ),

              const SizedBox(height: 32),

              // Sign out button
              SecondaryButton(
                text: 'Sign out',
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.grey50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.grey300),
                        ),
                        title: Text(
                          'Sign out?',
                          style: AppTypography.h6Bold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        content: Text(
                          'Your offline scans and routine logs will be safely synced to your account.',
                          style: AppTypography.bodySRegular.copyWith(
                            color: AppColors.grey800,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Cancel',
                              style: AppTypography.bodySMedium.copyWith(
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.go(AppRoutes.onboardingWelcome);
                            },
                            child: Text(
                              'Sign out',
                              style: AppTypography.bodySMedium.copyWith(
                                color: AppColors.error400,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 48),
              _buildSettingFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingFooter() {
    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageResources.koraLogo,
              width: 36,
              fit: BoxFit.cover,
            ),
            Text(
              'Kora',
              style: AppTypography.h3Medium.copyWith(
                fontSize: 28,
                color: const Color(0XFF090A0B),
              ),
            ),
          ],
        ),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Powered by Youcam API \n',
            style: AppTypography.bodyMRegular.copyWith(
              color: AppGreyColors.shade1050,
            ),
            children: [
              TextSpan(
                text: 'Version 1.0.0 (2026)\n © 2026 Kora Inc. All Rights Reserved',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePreview() {
    return Column(
      spacing: 16,
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFF2EEE3),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton.filled(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: AppGreyColors.white,
                  padding: EdgeInsets.zero,
                  side: const BorderSide(
                    width: 2,
                    color: AppColors.scaffoldColor,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: SvgPicture.asset(
                  ImageResources.addIcon,
                  colorFilter: const ColorFilter.mode(
                    AppGreyColors.shade1000,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          width: double.infinity,
          child: Column(
            spacing: 8,
            children: [
              Text(
                'Me',
                textAlign: TextAlign.center,
                style: AppTypography.h3Medium.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
              Text(
                'Track your progress and \n'
                'become your best skin',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
