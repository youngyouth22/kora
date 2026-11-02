import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';
import 'package:kora/features/profile/presentation/widgets/setting_tile.dart';
import 'package:kora/features/profile/presentation/widgets/social_share_section.dart';
import 'package:supabase/supabase.dart';

/// User profile and main settings dashboard (C19 in blueprint).
class ProfilePage extends StatefulWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _displayName = 'Me';
  String? _userEmail;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUserProfile());
  }

  Future<void> _loadUserProfile() async {
    final sl = GetIt.instance;
    var name = 'Me';
    String? email;
    var authenticated = false;

    if (sl.isRegistered<AppSessionState>()) {
      authenticated = sl<AppSessionState>().isAuthenticated;
    }

    if (sl.isRegistered<ProfileDao>()) {
      try {
        final profile = await sl<ProfileDao>().getLatestProfile();
        if (profile?.displayName != null && profile!.displayName!.isNotEmpty) {
          name = profile.displayName!;
        }
      } on Object catch (_) {}
    }

    if (sl.isRegistered<SupabaseClient>()) {
      try {
        final authUser = sl<SupabaseClient>().auth.currentUser;
        if (authUser != null &&
            !authUser.isAnonymous &&
            authUser.email != null) {
          email = authUser.email;
          authenticated = true;
          if (name == 'Me') {
            final metaName = authUser.userMetadata?['display_name'] as String?;
            if (metaName != null && metaName.isNotEmpty) {
              name = metaName;
            } else {
              name = email!.split('@').first;
            }
          }
        }
      } on Object catch (_) {}
    }

    if (mounted) {
      setState(() {
        _displayName = name;
        _userEmail = email;
        _isAuthenticated = authenticated && email != null;
      });
    }
  }

  Future<void> _openAccountSecure() async {
    final result = await context.push<bool?>(AppRoutes.accountSecure);
    if ((result ?? false) || mounted) {
      await _loadUserProfile();
    }
  }

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
              if (!_isAuthenticated) ...[
                const SizedBox(height: 20),
                _buildGuestBanner(),
              ],
              const SizedBox(height: 32),

              // Skin Profile Summary
              SettingSection(
                title: 'Personalization',
                children: [
                  SettingTile(
                    icon: Icons.track_changes_rounded,
                    title: 'Routine Preferences',
                    onTap: () =>
                        context.push(AppRoutes.profileRoutinePreferences),
                  ),
                  SettingTile(
                    icon: Icons.face_retouching_natural_rounded,
                    title: 'Skin profile & quiz',
                    onTap: () => context.push(AppRoutes.profileSkinProfile),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Account & Preferences
              SettingSection(
                title: 'Account & Settings',
                children: [
                  if (!_isAuthenticated)
                    SettingTile(
                      icon: Icons.sync_rounded,
                      iconColor: AppColors.primary700,
                      title: 'Link account & sync',
                      subtitle: 'Save guest data to cloud',
                      onTap: _openAccountSecure,
                    ),
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
                          'Your offline scans and routine logs will be safely '
                          'synced to your account.',
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
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              final sl = GetIt.instance;

                              if (sl.isRegistered<SupabaseClient>()) {
                                try {
                                  await sl<SupabaseClient>().auth.signOut();
                                } on Object catch (_) {}
                              }

                              if (sl.isRegistered<AppPreferencesService>()) {
                                await sl<AppPreferencesService>().clear();
                              }

                              if (sl.isRegistered<AppSessionState>()) {
                                sl<AppSessionState>()
                                  ..reset()
                                  ..completeInitialization(
                                    isOnboardingCompleted: false,
                                  );
                              }

                              if (context.mounted) {
                                context.go(AppRoutes.onboardingWelcome);
                              }
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
              style: AppTypography.h3Bold.copyWith(
                color: AppColors.grey1050,
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
                text:
                    'Version 1.0.0 (2026)\n'
                    ' © 2026 Kora Inc. All Rights Reserved',
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
              backgroundColor: AppColors.primary50,
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: AppColors.primary700,
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton.filled(
                onPressed: () {
                  unawaited(context.push(AppRoutes.onboardingQuestions));
                },
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
                _displayName,
                textAlign: TextAlign.center,
                style: AppTypography.h3Medium.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
              if (!_isAuthenticated)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.secondary700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Guest mode',
                        style: AppTypography.bodyXsMedium.copyWith(
                          color: AppColors.secondary800,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                _userEmail ?? 'Track your progress and \nbecome your best skin',
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

  Widget _buildGuestBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
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
                      'Save your skin progress',
                      style: AppTypography.h6Bold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to sync your scans, custom routine, '
                      'and progress safely to your account.',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Sign in & save data',
            backgroundColor: AppColors.primary700,
            icon: const Icon(
              Icons.login_rounded,
              color: AppColors.neutral50,
              size: 20,
            ),
            onPressed: _openAccountSecure,
          ),
        ],
      ),
    );
  }
}
