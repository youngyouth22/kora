import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/utils/active_user_resolver.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

/// User skin profile, Fitzpatrick phototype, and concerns management screen.
class SkinProfilePage extends StatefulWidget {
  /// Creates a [SkinProfilePage].
  const SkinProfilePage({super.key});

  @override
  State<SkinProfilePage> createState() => _SkinProfilePageState();
}

class _SkinProfilePageState extends State<SkinProfilePage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  SkinType _selectedSkinType = SkinType.combination;
  SkinTone _selectedSkinTone = SkinTone.typeIII;
  final Set<SkinGoal> _selectedGoals = {SkinGoal.acne, SkinGoal.pores};
  bool _hasSensitiveSkin = false;

  static const List<({SkinType type, String name, String subtitle})>
  _skinTypeOptions = [
    (
      type: SkinType.oily,
      name: 'Oily',
      subtitle: 'Excess shine throughout your face',
    ),
    (
      type: SkinType.dry,
      name: 'Dry',
      subtitle: 'Tight, flaky, or lacks natural moisture',
    ),
    (
      type: SkinType.combination,
      name: 'Combination',
      subtitle: 'Oily T-zone, normal or dry cheeks',
    ),
    (
      type: SkinType.normal,
      name: 'Normal',
      subtitle: 'Balanced moisture and sebum levels',
    ),
    (
      type: SkinType.unknown,
      name: 'Not sure',
      subtitle: 'Calibrated continuously from your scans',
    ),
  ];

  static const List<
    ({SkinTone tone, String name, String subtitle, Color color})
  >
  _skinToneOptions = [
    (
      tone: SkinTone.typeI,
      name: 'Type I · Very Fair',
      subtitle: 'Always burns easily, never tans',
      color: AppSkinToneColors.typeI,
    ),
    (
      tone: SkinTone.typeII,
      name: 'Type II · Fair',
      subtitle: 'Burns easily, tans minimally',
      color: AppSkinToneColors.typeII,
    ),
    (
      tone: SkinTone.typeIII,
      name: 'Type III · Medium',
      subtitle: 'Burns moderately, tans gradually',
      color: AppSkinToneColors.typeIII,
    ),
    (
      tone: SkinTone.typeIV,
      name: 'Type IV · Olive',
      subtitle: 'Burns minimally, tans easily',
      color: AppSkinToneColors.typeIV,
    ),
    (
      tone: SkinTone.typeV,
      name: 'Type V · Brown',
      subtitle: 'Rarely burns, tans profusely',
      color: AppSkinToneColors.typeV,
    ),
    (
      tone: SkinTone.typeVI,
      name: 'Type VI · Deeply Pigmented',
      subtitle: 'Almost never burns',
      color: AppSkinToneColors.typeVI,
    ),
  ];

  static const List<({SkinGoal goal, String name, IconData icon})>
  _skinGoalOptions = [
    (
      goal: SkinGoal.acne,
      name: 'Acne & blemishes',
      icon: Icons.flare_outlined,
    ),
    (
      goal: SkinGoal.darkSpots,
      name: 'Dark spots & pigmentation',
      icon: Icons.lens_blur_outlined,
    ),
    (
      goal: SkinGoal.redness,
      name: 'Redness & sensitivity',
      icon: Icons.spa_outlined,
    ),
    (
      goal: SkinGoal.pores,
      name: 'Pores & blackheads',
      icon: Icons.grain_rounded,
    ),
    (
      goal: SkinGoal.fineLines,
      name: 'Fine lines & wrinkles',
      icon: Icons.waves_rounded,
    ),
    (
      goal: SkinGoal.crowFeet,
      name: "Crow's feet & eye area",
      icon: Icons.remove_red_eye_outlined,
    ),
    (
      goal: SkinGoal.dehydration,
      name: 'Dehydration & dullness',
      icon: Icons.water_drop_outlined,
    ),
    (
      goal: SkinGoal.unevenTexture,
      name: 'Uneven skin texture',
      icon: Icons.hub_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_loadSkinProfile());
  }

  Future<void> _loadSkinProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sl = GetIt.instance;
      ProfileEntry? entry;

      if (sl.isRegistered<ProfileDao>()) {
        entry = await sl<ProfileDao>().getLatestProfile();
      }

      if (entry != null) {
        if (entry.skinType != null) {
          final resolvedType = SkinType.fromCode(entry.skinType);
          if (resolvedType != null) {
            _selectedSkinType = resolvedType;
          }
        }

        if (entry.skinToneSelf != null &&
            entry.skinToneSelf! >= 1 &&
            entry.skinToneSelf! <= 6) {
          _selectedSkinTone = SkinTone.values[entry.skinToneSelf! - 1];
        }

        if (entry.goals.isNotEmpty) {
          _selectedGoals.clear();
          for (final code in entry.goals) {
            final goal = SkinGoal.fromCode(code);
            if (goal != null) {
              _selectedGoals.add(goal);
            }
          }
        }

        _hasSensitiveSkin = entry.sensitivities.contains('sensitive');
      } else if (sl.isRegistered<OnboardingLocalDataSource>()) {
        final cached = await sl<OnboardingLocalDataSource>()
            .getLastSkinProfile();
        if (cached != null) {
          if (cached.skinType != null) {
            _selectedSkinType = cached.skinType!;
          }
          if (cached.skinTone != null) {
            _selectedSkinTone = cached.skinTone!;
          }
          if (cached.primaryGoals.isNotEmpty) {
            _selectedGoals
              ..clear()
              ..addAll(cached.primaryGoals);
          }
          _hasSensitiveSkin =
              cached.demographics?.hasSensitiveSkin ?? _hasSensitiveSkin;
        }
      }
    } on Object catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSkinProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final sl = GetIt.instance;
      final userId = await ActiveUserResolver.resolveUserId();
      final now = DateTime.now();

      final goalsList = _selectedGoals.map((g) => g.code).toList();
      final toneIndex = SkinTone.values.indexOf(_selectedSkinTone) + 1;
      final sensitivitiesList = _hasSensitiveSkin ? ['sensitive'] : <String>[];

      if (sl.isRegistered<ProfileDao>()) {
        final companion = ProfilesCompanion(
          id: drift.Value(userId),
          skinType: drift.Value(_selectedSkinType.code),
          skinToneSelf: drift.Value(toneIndex),
          goals: drift.Value(goalsList),
          sensitivities: drift.Value(sensitivitiesList),
          updatedAt: drift.Value(now),
        );
        await sl<ProfileDao>().upsertProfile(companion);
      }

      if (sl.isRegistered<OnboardingLocalDataSource>()) {
        final profileModel = UserSkinProfileModel(
          userId: userId,
          skinType: _selectedSkinType,
          skinTone: _selectedSkinTone,
          primaryGoals: _selectedGoals.toList(),
          demographics: UserDemographics(
            userId: userId,
            hasSensitiveSkin: _hasSensitiveSkin,
          ),
          updatedAt: now,
        );
        await sl<OnboardingLocalDataSource>().cacheSkinProfile(profileModel);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Skin profile updated successfully',
              style: AppTypography.bodySMedium.copyWith(
                color: AppColors.grey50,
              ),
            ),
            backgroundColor: AppColors.grey1000,
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: AppTypography.bodySMedium.copyWith(
                color: AppColors.grey50,
              ),
            ),
            backgroundColor: AppColors.error400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _toggleGoal(SkinGoal goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        if (_selectedGoals.length > 1) {
          _selectedGoals.remove(goal);
        }
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Skin Profile',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.grey1000,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary700,
                ),
              )
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unable to load skin profile',
                        style: AppTypography.h6Bold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySRegular.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Retry',
                        onPressed: _loadSkinProfile,
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Skin Type section
                    SettingSection(
                      title: 'Skin Type',
                      children: _skinTypeOptions.map((opt) {
                        final isSelected = _selectedSkinType == opt.type;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSkinType = opt.type;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.name,
                                        style: AppTypography.bodyMSemiBold
                                            .copyWith(
                                              color: AppColors.grey1050,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt.subtitle,
                                        style: AppTypography.bodyXsRegular
                                            .copyWith(
                                              color: AppColors.grey700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? AppColors.primary700
                                      : AppColors.grey400,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Skin Tone Phototype section
                    SettingSection(
                      title: 'Skin Tone (Fitzpatrick Phototype)',
                      children: _skinToneOptions.map((opt) {
                        final isSelected = _selectedSkinTone == opt.tone;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSkinTone = opt.tone;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: opt.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.name,
                                        style: AppTypography.bodyMSemiBold
                                            .copyWith(
                                              color: AppColors.grey1050,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt.subtitle,
                                        style: AppTypography.bodyXsRegular
                                            .copyWith(
                                              color: AppColors.grey700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? AppColors.primary700
                                      : AppColors.grey400,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Primary Goals & Concerns
                    SettingSection(
                      title: 'Primary Skin Goals & Concerns',
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _skinGoalOptions.map((opt) {
                              final isSelected = _selectedGoals.contains(
                                opt.goal,
                              );
                              return FilterChip(
                                selected: isSelected,
                                showCheckmark: false,
                                avatar: Icon(
                                  opt.icon,
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.primary800
                                      : AppColors.grey700,
                                ),
                                label: Text(
                                  opt.name,
                                  style: AppTypography.bodySMedium.copyWith(
                                    color: isSelected
                                        ? AppColors.primary900
                                        : AppColors.grey900,
                                  ),
                                ),
                                backgroundColor: AppColors.grey50,
                                selectedColor: AppColors.primary100,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary600
                                      : AppColors.grey300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (_) => _toggleGoal(opt.goal),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sensitivities
                    SettingSection(
                      title: 'Sensitivities',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sensitive skin barrier',
                                    style: AppTypography.bodyMSemiBold.copyWith(
                                      color: AppColors.grey1050,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Reacts easily to fragrances, acids, or '
                                    'harsh weather',
                                    style: AppTypography.bodyXsRegular.copyWith(
                                      color: AppColors.grey700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _hasSensitiveSkin,
                              activeTrackColor: AppColors.primary700,
                              onChanged: (val) {
                                setState(() {
                                  _hasSensitiveSkin = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save CTA
                    PrimaryButton(
                      text: 'Save skin profile',
                      isLoading: _isSaving,
                      onPressed: _saveSkinProfile,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
