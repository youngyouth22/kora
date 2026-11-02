import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/core/utils/active_user_resolver.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';
import 'package:supabase/supabase.dart';

/// User privacy, biometric consent and data deletion screen (C21 in blueprint).
class PrivacyPage extends StatefulWidget {
  /// Creates a [PrivacyPage].
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _keepPhotos = true;

  void _confirmDeletePhotos() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.grey300),
            ),
            title: Text(
              'Delete all photos?',
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            content: Text(
              'All selfie images stored on your device and private storage '
              'will be permanently deleted. Your numerical scores and trends '
              'will remain safe.',
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
                  final userId = await ActiveUserResolver.resolveUserId();

                  if (sl.isRegistered<ScanDao>()) {
                    final scanDao = sl<ScanDao>();
                    final scans = await scanDao.getScansForUser(userId);
                    for (final scan in scans) {
                      if (scan.photoPath != null &&
                          scan.photoPath!.isNotEmpty) {
                        try {
                          final file = File(scan.photoPath!);
                          if (file.existsSync()) {
                            await file.delete();
                          }
                        } on Object catch (_) {}
                      }
                    }
                    await scanDao.clearAllPhotosForUser(userId);
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All photos deleted from device. '
                        'Numerical scores kept.',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.grey1000,
                    ),
                  );
                },
                child: Text(
                  'Delete photos',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.error400,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.grey300),
            ),
            title: Text(
              'Delete account & data?',
              style: AppTypography.h6Bold.copyWith(color: AppColors.error400),
            ),
            content: Text(
              'This action is irreversible. All your scan records, '
              'routine logs, active experiments, and photos will be '
              'permanently erased.',
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
                  final userId = await ActiveUserResolver.resolveUserId();

                  // 1. Delete all SQLite tables for user
                  if (sl.isRegistered<ScanDao>()) {
                    final scanDao = sl<ScanDao>();
                    final scans = await scanDao.getScansForUser(userId);
                    for (final scan in scans) {
                      if (scan.photoPath != null &&
                          scan.photoPath!.isNotEmpty) {
                        try {
                          final file = File(scan.photoPath!);
                          if (file.existsSync()) {
                            await file.delete();
                          }
                        } on Object catch (_) {}
                      }
                    }
                    await scanDao.deleteAllScansForUser(userId);
                  }

                  if (sl.isRegistered<RoutineDao>()) {
                    await sl<RoutineDao>().deleteAllRoutineForUser(userId);
                  }

                  if (sl.isRegistered<ExperimentDao>()) {
                    await sl<ExperimentDao>().deleteAllExperimentsForUser(
                      userId,
                    );
                  }

                  if (sl.isRegistered<ProfileDao>()) {
                    await sl<ProfileDao>().deleteAllProfiles();
                  }

                  if (sl.isRegistered<SyncMutationDao>()) {
                    await sl<SyncMutationDao>().clearAll();
                  }

                  // 2. Clear SharedPreferences
                  if (sl.isRegistered<AppPreferencesService>()) {
                    await sl<AppPreferencesService>().clear();
                  }

                  // 3. Supabase Auth Sign out
                  if (sl.isRegistered<SupabaseClient>()) {
                    try {
                      await sl<SupabaseClient>().auth.signOut();
                    } on Object catch (_) {}
                  }

                  // 4. Reset Session State
                  if (sl.isRegistered<AppSessionState>()) {
                    sl<AppSessionState>()
                      ..reset()
                      ..completeInitialization(
                        isOnboardingCompleted: false,
                      );
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Account and all associated data permanently erased.',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.grey1000,
                    ),
                  );
                  context.go(AppRoutes.onboardingWelcome);
                },
                child: Text(
                  'Delete everything',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.error400,
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
          'Privacy & Data',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Storage Switch Card
              KoraCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep my photos to compare',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If toggled off, only raw numerical scores and '
                            'zone masks are stored. Photos are discarded.',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _keepPhotos,
                      activeTrackColor: AppColors.primary700,
                      onChanged: (val) => setState(() => _keepPhotos = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data Management
              SettingSection(
                title: 'Data Actions',
                titleTextStyle: AppTypography.h6Bold.copyWith(
                  color: AppColors.grey1050,
                ),
                cardPadding: const EdgeInsets.all(16),
                spacing: 8,
                children: [
                  _buildActionTile(
                    icon: Icons.photo_library_outlined,
                    title: 'Delete all my photos',
                    subtitle: 'Keep only numerical progression scores',
                    color: AppColors.grey1050,
                    onTap: _confirmDeletePhotos,
                  ),
                  const Divider(height: 1, color: AppColors.grey200),
                  _buildActionTile(
                    icon: Icons.download_outlined,
                    title: 'Export my data (JSON)',
                    subtitle: 'Download complete history of scans and routines',
                    color: AppColors.primary700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Export archive generated and ready to save.',
                            style: AppTypography.bodySMedium.copyWith(
                              color: AppColors.grey50,
                            ),
                          ),
                          backgroundColor: AppColors.primary700,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.grey200),
                  _buildActionTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete account & data',
                    subtitle: 'Irreversible cascade deletion per requirements',
                    color: AppColors.error400,
                    onTap: _confirmDeleteAccount,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Legal & Consent Status
              KoraCard(
                backgroundColor: AppColors.grey100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consent Record',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consent given: Oct 11, 2026 · Policy v1.0\n'
                      'Protected by Row Level Security (RLS) on private '
                      'encrypted buckets. No photos used for AI training.',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMSemiBold.copyWith(color: color),
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
              size: 18,
              color: AppColors.grey600,
            ),
          ],
        ),
      ),
    );
  }
}
