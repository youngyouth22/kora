import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:kora/features/notifications/data/models/notification_preferences_model.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

/// Notification preferences and scan reminder scheduler screen
/// (C22 in blueprint).
class NotificationsPage extends StatefulWidget {
  /// Creates a [NotificationsPage].
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _weeklyScan = true;
  bool _morningRoutine = true;
  bool _eveningRoutine = true;
  bool _milestones = true;
  bool _streakReminders = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPreferences());
  }

  Future<void> _loadPreferences() async {
    final sl = GetIt.instance;
    if (sl.isRegistered<NotificationLocalDataSource>()) {
      try {
        final prefs = await sl<NotificationLocalDataSource>().getPreferences();
        if (mounted) {
          setState(() {
            _weeklyScan = prefs.isEnabled;
          });
        }
      } on Object catch (_) {}
    }
  }

  Future<void> _updateWeeklyScan(bool value) async {
    setState(() => _weeklyScan = value);
    final sl = GetIt.instance;
    if (sl.isRegistered<NotificationLocalDataSource>()) {
      try {
        final current = await sl<NotificationLocalDataSource>()
            .getPreferences();
        final updated = NotificationPreferencesModel(
          isEnabled: value,
          preferredDayOfWeek: current.preferredDayOfWeek,
          preferredHour: current.preferredHour,
          preferredMinute: current.preferredMinute,
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
        if (!value) {
          await sl<NotificationLocalDataSource>().cancelAll();
        }
      } on Object catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weekly Scan Reminder
              SettingSection(
                title: 'Weekly Scan Schedule',
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly scan reminder',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sunday at 6:00 PM (Local time)',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.primary800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _weeklyScan,
                      activeTrackColor: AppColors.primary700,
                      onChanged: _updateWeeklyScan,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Daily Reminders
              SettingSection(
                title: 'Daily Care & Progress',
                children: [
                  _buildSwitchRow(
                    title: 'Morning routine reminder',
                    subtitle: '8:00 AM · Cleanse & sunscreen reminder',
                    value: _morningRoutine,
                    onChanged: (val) => setState(() => _morningRoutine = val),
                  ),
                  const Divider(height: 16, color: AppColors.grey200),
                  _buildSwitchRow(
                    title: 'Evening routine reminder',
                    subtitle: '9:00 PM · Cleanse & treatment reminder',
                    value: _eveningRoutine,
                    onChanged: (val) => setState(() => _eveningRoutine = val),
                  ),
                  const Divider(height: 16, color: AppColors.grey200),
                  _buildSwitchRow(
                    title: 'Streak at risk warning',
                    subtitle: '7:30 PM nudge only if no check-in logged',
                    value: _streakReminders,
                    onChanged: (val) => setState(() => _streakReminders = val),
                  ),
                  const Divider(height: 16, color: AppColors.grey200),
                  _buildSwitchRow(
                    title: 'Results & experiment milestones',
                    subtitle: 'Alert when a 6-week product verdict is ready',
                    value: _milestones,
                    onChanged: (val) => setState(() => _milestones = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Frequency guarantee
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Kora respects your attention: maximum 2 notifications per '
                  'week. No spam, no marketing alerts.',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
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
                subtitle,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primary700,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
