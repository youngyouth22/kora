// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_state.dart';
import 'package:kora/features/notifications/presentation/widgets/day_of_week_selector.dart';
import 'package:kora/features/notifications/presentation/widgets/notification_preview_card.dart';
import 'package:kora/features/notifications/presentation/widgets/notification_rule_info_row.dart';
import 'package:kora/features/notifications/presentation/widgets/time_slot_selector.dart';

/// Onboarding screen prompting the user to authorize notifications
/// and configure their weekly skin scan day and time schedule (N1).
class NotificationReminderScreen extends StatefulWidget {
  /// Creates a [NotificationReminderScreen].
  const NotificationReminderScreen({
    super.key,
    this.permissionService,
    this.sessionState,
    this.onPermissionGranted,
    this.onSkip,
  });

  /// Injected permission handler service.
  final NotificationPermissionService? permissionService;

  /// Injected app session state.
  final AppSessionState? sessionState;

  /// Optional custom callback invoked when permission is authorized.
  final VoidCallback? onPermissionGranted;

  /// Optional custom callback invoked when the user skips reminder setup.
  final VoidCallback? onSkip;

  @override
  State<NotificationReminderScreen> createState() =>
      _NotificationReminderScreenState();
}

class _NotificationReminderScreenState extends State<NotificationReminderScreen>
    with WidgetsBindingObserver {
  var _isRequesting = false;
  var _isPermissionDenied = false;
  var _isPermanentlyDenied = false;

  int _selectedDay = DateTime.sunday;
  int _selectedHour = 20;
  int _selectedMinute = 0;

  NotificationPermissionService get _permissionService =>
      widget.permissionService ??
      (GetIt.instance.isRegistered<NotificationPermissionService>()
          ? GetIt.instance<NotificationPermissionService>()
          : const DefaultNotificationPermissionService());

  AppSessionState? get _sessionState =>
      widget.sessionState ??
      (GetIt.instance.isRegistered<AppSessionState>()
          ? GetIt.instance<AppSessionState>()
          : null);

  static const Map<int, String> _dayNames = {
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize day/time from active bloc state if available
    final bloc = context.read<NotificationBloc?>();
    if (bloc != null) {
      final prefs = bloc.state.preferences;
      _selectedDay = prefs.preferredDayOfWeek;
      _selectedHour = prefs.preferredHour;
      _selectedMinute = prefs.preferredMinute;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPermissionDenied) {
      unawaited(_checkPermissionOnResume());
    }
  }

  Future<void> _checkPermissionOnResume() async {
    try {
      final isGranted = await _permissionService.isPermissionGranted();
      if (!mounted) return;
      if (isGranted) {
        _handleProceed();
      }
    } on Object catch (_) {}
  }

  void _handleProceed() {
    _sessionState?.setOnboardingCompleted(completed: true);
    if (widget.onPermissionGranted != null) {
      widget.onPermissionGranted!();
    } else if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.scanCapture);
    }
  }

  void _handleSkip() {
    _sessionState?.setOnboardingCompleted(completed: true);
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.scanCapture);
    }
  }

  Future<void> _handleRequestPermission() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      // First, dispatch configured reminder schedule to NotificationBloc
      try {
        context.read<NotificationBloc>().add(
          NotificationWeeklyReminderConfigured(
            dayOfWeek: _selectedDay,
            hour: _selectedHour,
            minute: _selectedMinute,
          ),
        );
      } on Object catch (_) {}

      final granted = await _permissionService.requestNotificationPermission();
      if (!mounted) return;

      setState(() => _isRequesting = false);

      if (granted) {
        try {
          context.read<NotificationBloc>().add(
            const NotificationPermissionRequested(),
          );
        } on Object catch (_) {}

        _handleProceed();
      } else {
        final permanentlyDenied = await _permissionService
            .isPermanentlyDenied();
        if (!mounted) return;
        setState(() {
          _isPermissionDenied = true;
          _isPermanentlyDenied = permanentlyDenied;
        });
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _isPermissionDenied = true;
          _isRequesting = false;
        });
      }
    }
  }

  Future<void> _handleOpenSettings() async {
    await _permissionService.openSettings();
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = _dayNames[_selectedDay] ?? 'Sunday';
    final timeLabel = _formatTime(_selectedHour, _selectedMinute);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: _isPermissionDenied
          ? EmptyStateView(
              icon: Icons.notifications_off_outlined,
              title: _isPermanentlyDenied
                  ? 'Notifications Disabled'
                  : 'Reminders Denied',
              message: _isPermanentlyDenied
                  ? 'Notifications are disabled for Kora. To receive your weekly scan reminders, please enable them in your device settings.'
                  : 'Kora uses weekly notifications to help you track your skin progress over time. You can turn them on anytime.',
              primaryActionLabel: _isPermanentlyDenied
                  ? 'Open Settings'
                  : 'Try Again',
              onPrimaryAction: _isPermanentlyDenied
                  ? _handleOpenSettings
                  : _handleRequestPermission,
              secondaryActionLabel: 'Continue to Scan',
              onSecondaryAction: _handleSkip,
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Stay consistent with weekly scan reminders',
                              style: AppTypography.h3Medium.copyWith(
                                color: AppColors.grey1050,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Skin barrier renewal follows a 28-day cycle. A quick 30-second scan once a week tracks what truly works.',
                              style: AppTypography.bodyMRegular.copyWith(
                                color: AppColors.grey700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            NotificationPreviewCard(
                              title: 'Weekly scan reminder',
                              body:
                                  'Time for your 30s scan • $dayLabel at $timeLabel',
                            ),
                            const SizedBox(height: 24),
                            DayOfWeekSelector(
                              selectedDay: _selectedDay,
                              onDaySelected: (day) {
                                setState(() => _selectedDay = day);
                              },
                            ),
                            const SizedBox(height: 20),
                            TimeSlotSelector(
                              selectedHour: _selectedHour,
                              selectedMinute: _selectedMinute,
                              onTimeSelected: (hour, minute) {
                                setState(() {
                                  _selectedHour = hour;
                                  _selectedMinute = minute;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            const NotificationRuleInfoRow(
                              icon: Icons.schedule_rounded,
                              title: 'Max 3 notifications per week',
                              subtitle:
                                  'Essential routine and scan reminders only.',
                            ),
                            const NotificationRuleInfoRow(
                              icon: Icons.bedtime_outlined,
                              title: 'Quiet hours respected',
                              subtitle: 'Zero disturbances between 9:00 PM and 8:00 AM.',
                            ),
                            const NotificationRuleInfoRow(
                              icon: Icons.favorite_border_rounded,
                              title: 'Zero guilt-tripping',
                              subtitle: 'Missed a scan? Pick up anytime without shame.',
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Semantics(
                        button: true,
                        label: 'Confirm and Enable Reminders',
                        child: BlocBuilder<NotificationBloc, NotificationState>(
                          builder: (context, state) {
                            return PrimaryButton(
                              text: 'Confirm & Enable Reminders',
                              isLoading: _isRequesting || state.isLoading,
                              onPressed: _handleRequestPermission,
                            );
                          },
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Maybe Later',
                      child: TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          'Maybe Later',
                          style: AppTypography.bodyMMedium.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
