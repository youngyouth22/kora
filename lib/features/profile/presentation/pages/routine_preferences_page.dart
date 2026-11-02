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
import 'package:kora/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:kora/features/notifications/data/models/notification_preferences_model.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

/// Skincare routine preferences, guidance mode, and daily schedule screen.
class RoutinePreferencesPage extends StatefulWidget {
  /// Creates a [RoutinePreferencesPage].
  const RoutinePreferencesPage({super.key});

  @override
  State<RoutinePreferencesPage> createState() => _RoutinePreferencesPageState();
}

class _RoutinePreferencesPageState extends State<RoutinePreferencesPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  RoutineLevel _routineLevel = RoutineLevel.moderate;
  AssistancePreference _assistancePreference =
      AssistancePreference.tailoredBoosters;
  TestingProductStatus _testingProductStatus =
      TestingProductStatus.routineStability;

  // Reminders
  bool _morningReminder = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);

  bool _eveningReminder = true;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);

  int _scanWeekday = DateTime.sunday;
  TimeOfDay _scanTime = const TimeOfDay(hour: 18, minute: 0);

  static const List<
    ({
      RoutineLevel level,
      String title,
      String subtitle,
      Color badgeBg,
      Color badgeIcon,
      IconData icon,
    })
  >
  _routineLevelOptions = [
    (
      level: RoutineLevel.minimalist,
      title: 'Minimalist (1–2 products)',
      subtitle: 'Basic cleanser, moisturizer, or sunscreen',
      badgeBg: AppBadgeColors.savingsBg,
      badgeIcon: AppBadgeColors.savingsIcon,
      icon: Icons.clean_hands_outlined,
    ),
    (
      level: RoutineLevel.moderate,
      title: 'Moderate (3–4 products)',
      subtitle: 'Cleanser, toner, serum, and moisturizer',
      badgeBg: AppBadgeColors.valueBg,
      badgeIcon: AppBadgeColors.valueIcon,
      icon: Icons.spa_outlined,
    ),
    (
      level: RoutineLevel.advanced,
      title: 'Advanced (5+ products)',
      subtitle: 'Layered regimen with targeted actives and treatments',
      badgeBg: AppBadgeColors.innovativeBg,
      badgeIcon: AppBadgeColors.innovativeIcon,
      icon: Icons.layers_outlined,
    ),
    (
      level: RoutineLevel.irregular,
      title: 'Irregular or starting fresh',
      subtitle: 'Starting fresh with Kora to build consistency',
      badgeBg: AppBadgeColors.ultimateBg,
      badgeIcon: AppBadgeColors.ultimateIcon,
      icon: Icons.refresh_rounded,
    ),
  ];

  static const List<
    ({
      AssistancePreference preference,
      String title,
      String subtitle,
      Color badgeBg,
      Color badgeIcon,
      IconData icon,
    })
  >
  _assistanceOptions = [
    (
      preference: AssistancePreference.tailoredBoosters,
      title: 'Proactive tailored boosters',
      subtitle:
          'Receive formula & ingredient suggestions backed by your scan data',
      badgeBg: AppBadgeColors.valueBg,
      badgeIcon: AppBadgeColors.valueIcon,
      icon: Icons.auto_awesome_rounded,
    ),
    (
      preference: AssistancePreference.alertOnDecline,
      title: 'Alert only when metrics decline',
      subtitle:
          'Alert me only when irritation, redness, or barrier issues arise',
      badgeBg: AppBadgeColors.savingsBg,
      badgeIcon: AppBadgeColors.savingsIcon,
      icon: Icons.notifications_active_outlined,
    ),
    (
      preference: AssistancePreference.trackRoutineOnly,
      title: 'Track my current routine only',
      subtitle: 'Keep tracking focused strictly on existing products',
      badgeBg: AppBadgeColors.innovativeBg,
      badgeIcon: AppBadgeColors.innovativeIcon,
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  static const List<
    ({
      TestingProductStatus status,
      String title,
      String subtitle,
      Color badgeBg,
      Color badgeIcon,
      IconData icon,
    })
  >
  _testingStatusOptions = [
    (
      status: TestingProductStatus.startedRecently,
      title: 'Testing a new product',
      subtitle: 'Track its impact from baseline over 4 to 6 weeks',
      badgeBg: AppBadgeColors.valueBg,
      badgeIcon: AppBadgeColors.valueIcon,
      icon: Icons.science_outlined,
    ),
    (
      status: TestingProductStatus.planningSoon,
      title: 'Planning to introduce one soon',
      subtitle: 'Setup a baseline scan before adding a new active ingredient',
      badgeBg: AppBadgeColors.innovativeBg,
      badgeIcon: AppBadgeColors.innovativeIcon,
      icon: Icons.add_circle_outline_rounded,
    ),
    (
      status: TestingProductStatus.routineStability,
      title: 'Testing routine stability',
      subtitle: 'Confirm current routine keeps skin barrier healthy & stable',
      badgeBg: AppBadgeColors.savingsBg,
      badgeIcon: AppBadgeColors.savingsIcon,
      icon: Icons.balance_rounded,
    ),
  ];

  static const List<({int weekday, String name})> _weekdayOptions = [
    (weekday: DateTime.monday, name: 'Monday'),
    (weekday: DateTime.tuesday, name: 'Tuesday'),
    (weekday: DateTime.wednesday, name: 'Wednesday'),
    (weekday: DateTime.thursday, name: 'Thursday'),
    (weekday: DateTime.friday, name: 'Friday'),
    (weekday: DateTime.saturday, name: 'Saturday'),
    (weekday: DateTime.sunday, name: 'Sunday'),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_loadPreferences());
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sl = GetIt.instance;

      if (sl.isRegistered<ProfileDao>()) {
        final profile = await sl<ProfileDao>().getLatestProfile();
        if (profile != null) {
          _scanWeekday = profile.scanWeekday;
          final parts = profile.scanTime.split(':');
          if (parts.length >= 2) {
            final h = int.tryParse(parts[0]) ?? 18;
            final m = int.tryParse(parts[1]) ?? 0;
            _scanTime = TimeOfDay(hour: h, minute: m);
          }
        }
      }

      if (sl.isRegistered<OnboardingLocalDataSource>()) {
        final cached = await sl<OnboardingLocalDataSource>()
            .getLastSkinProfile();
        if (cached != null) {
          if (cached.routineLevel != null) {
            _routineLevel = cached.routineLevel!;
          }
          if (cached.assistancePreference != null) {
            _assistancePreference = cached.assistancePreference!;
          }
          if (cached.testingProductStatus != null) {
            _testingProductStatus = cached.testingProductStatus!;
          }
        }
      }

      if (sl.isRegistered<NotificationLocalDataSource>()) {
        final prefs = await sl<NotificationLocalDataSource>().getPreferences();
        _scanWeekday = prefs.preferredDayOfWeek;
        _scanTime = TimeOfDay(
          hour: prefs.preferredHour,
          minute: prefs.preferredMinute,
        );
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

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final sl = GetIt.instance;
      final userId = await ActiveUserResolver.resolveUserId();
      final now = DateTime.now();

      final hour = _scanTime.hour.toString().padLeft(2, '0');
      final minute = _scanTime.minute.toString().padLeft(2, '0');
      final scanTimeFormatted = '$hour:$minute';

      if (sl.isRegistered<ProfileDao>()) {
        final companion = ProfilesCompanion(
          id: drift.Value(userId),
          scanWeekday: drift.Value(_scanWeekday),
          scanTime: drift.Value(scanTimeFormatted),
          updatedAt: drift.Value(now),
        );
        await sl<ProfileDao>().upsertProfile(companion);
      }

      if (sl.isRegistered<OnboardingLocalDataSource>()) {
        final current = await sl<OnboardingLocalDataSource>()
            .getLastSkinProfile();
        final updated = (current ?? UserSkinProfileModel(userId: userId))
            .copyWith(
              routineLevel: _routineLevel,
              assistancePreference: _assistancePreference,
              testingProductStatus: _testingProductStatus,
              updatedAt: now,
            );
        await sl<OnboardingLocalDataSource>().cacheSkinProfile(
          UserSkinProfileModel.fromEntity(updated),
        );
      }

      if (sl.isRegistered<NotificationLocalDataSource>()) {
        final current = await sl<NotificationLocalDataSource>()
            .getPreferences();
        final updated = NotificationPreferencesModel(
          isEnabled: current.isEnabled,
          preferredDayOfWeek: _scanWeekday,
          preferredHour: _scanTime.hour,
          preferredMinute: _scanTime.minute,
          quietHoursStart: current.quietHoursStart,
          quietHoursEnd: current.quietHoursEnd,
          maxWeeklyNotifications: current.maxWeeklyNotifications,
          consecutiveIgnoredCount: current.consecutiveIgnoredCount,
          frequencyMultiplier: current.frequencyMultiplier,
          weeklyDeliveredCount: current.weeklyDeliveredCount,
          currentWeekNumber: current.currentWeekNumber,
          lastDeliveredAt: current.lastDeliveredAt,
          lastOpenedAt: current.lastOpenedAt,
        );
        await sl<NotificationLocalDataSource>().savePreferences(updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Routine preferences updated successfully',
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
              'Failed to save preferences: $e',
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

  Future<void> _selectTime({
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary700,
              onSurface: AppColors.grey1050,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Routine Preferences',
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
                        'Unable to load routine preferences',
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
                        onPressed: _loadPreferences,
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
                    // Routine Complexity
                    SettingSection(
                      title: 'Current Routine Complexity',
                      children: _routineLevelOptions.map((opt) {
                        final isSelected = _routineLevel == opt.level;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _routineLevel = opt.level;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: opt.badgeBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    opt.icon,
                                    size: 18,
                                    color: opt.badgeIcon,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.title,
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

                    // AI Guidance & Recommendation Style
                    SettingSection(
                      title: 'Guidance & Suggestions',
                      children: _assistanceOptions.map((opt) {
                        final isSelected =
                            _assistancePreference == opt.preference;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _assistancePreference = opt.preference;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: opt.badgeBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    opt.icon,
                                    size: 18,
                                    color: opt.badgeIcon,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.title,
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

                    // Experimentation Status
                    SettingSection(
                      title: 'Product Experimentation',
                      children: _testingStatusOptions.map((opt) {
                        final isSelected = _testingProductStatus == opt.status;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _testingProductStatus = opt.status;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: opt.badgeBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    opt.icon,
                                    size: 18,
                                    color: opt.badgeIcon,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.title,
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

                    // Daily Schedule & Reminders
                    SettingSection(
                      title: 'Daily Schedule & Reminders',
                      children: [
                        // Morning reminder
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Morning routine',
                                      style: AppTypography.bodyMSemiBold
                                          .copyWith(
                                            color: AppColors.grey1050,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Cleanse & protect routine reminder',
                                      style: AppTypography.bodyXsRegular
                                          .copyWith(
                                            color: AppColors.grey700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _morningReminder,
                                activeTrackColor: AppColors.primary700,
                                onChanged: (val) {
                                  setState(() {
                                    _morningReminder = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_morningReminder) ...[
                          const Divider(height: 1, color: AppColors.grey200),
                          InkWell(
                            onTap: () => _selectTime(
                              initialTime: _morningTime,
                              onSelected: (t) =>
                                  setState(() => _morningTime = t),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Morning reminder time',
                                    style: AppTypography.bodySRegular.copyWith(
                                      color: AppColors.grey800,
                                    ),
                                  ),
                                  Text(
                                    _morningTime.format(context),
                                    style: AppTypography.bodyMSemiBold.copyWith(
                                      color: AppColors.primary800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const Divider(height: 1, color: AppColors.grey200),

                        // Evening reminder
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Evening routine',
                                      style: AppTypography.bodyMSemiBold
                                          .copyWith(
                                            color: AppColors.grey1050,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Cleanse & night treatment reminder',
                                      style: AppTypography.bodyXsRegular
                                          .copyWith(
                                            color: AppColors.grey700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _eveningReminder,
                                activeTrackColor: AppColors.primary700,
                                onChanged: (val) {
                                  setState(() {
                                    _eveningReminder = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_eveningReminder) ...[
                          const Divider(height: 1, color: AppColors.grey200),
                          InkWell(
                            onTap: () => _selectTime(
                              initialTime: _eveningTime,
                              onSelected: (t) =>
                                  setState(() => _eveningTime = t),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Evening reminder time',
                                    style: AppTypography.bodySRegular.copyWith(
                                      color: AppColors.grey800,
                                    ),
                                  ),
                                  Text(
                                    _eveningTime.format(context),
                                    style: AppTypography.bodyMSemiBold.copyWith(
                                      color: AppColors.primary800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const Divider(height: 1, color: AppColors.grey200),

                        // Weekly scan day and time
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weekly scan day',
                                style: AppTypography.bodySRegular.copyWith(
                                  color: AppColors.grey800,
                                ),
                              ),
                              DropdownButton<int>(
                                value: _scanWeekday,
                                underline: const SizedBox.shrink(),
                                items: _weekdayOptions.map((w) {
                                  return DropdownMenuItem<int>(
                                    value: w.weekday,
                                    child: Text(
                                      w.name,
                                      style: AppTypography.bodySMedium.copyWith(
                                        color: AppColors.grey1050,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _scanWeekday = val;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.grey200),
                        InkWell(
                          onTap: () => _selectTime(
                            initialTime: _scanTime,
                            onSelected: (t) => setState(() => _scanTime = t),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Weekly scan time',
                                  style: AppTypography.bodySRegular.copyWith(
                                    color: AppColors.grey800,
                                  ),
                                ),
                                Text(
                                  _scanTime.format(context),
                                  style: AppTypography.bodyMSemiBold.copyWith(
                                    color: AppColors.primary800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Save CTA
                    PrimaryButton(
                      text: 'Save preferences',
                      isLoading: _isSaving,
                      onPressed: _savePreferences,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
