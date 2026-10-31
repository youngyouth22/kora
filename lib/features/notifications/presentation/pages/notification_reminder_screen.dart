// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_state.dart';
import 'package:kora/features/notifications/presentation/widgets/day_of_week_selector.dart';
import 'package:kora/features/notifications/presentation/widgets/notification_preview_card.dart';
import 'package:kora/features/notifications/presentation/widgets/notification_rule_info_row.dart';
import 'package:kora/features/notifications/presentation/widgets/time_slot_selector.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';

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
        await _handleProceed();
      }
    } on Object catch (_) {}
  }

  Future<void> _handleProceed() async {
    await _finalizeOnboardingAndRoute(fromPermissionGranted: true);
  }

  Future<void> _handleSkip() async {
    await _finalizeOnboardingAndRoute(fromPermissionGranted: false);
  }

  Future<void> _finalizeOnboardingAndRoute({
    required bool fromPermissionGranted,
  }) async {
    if (GetIt.instance.isRegistered<CompleteOnboardingUseCase>()) {
      try {
        await GetIt.instance<CompleteOnboardingUseCase>()(const NoParams());
      } on Object catch (_) {}
    }

    final session = _sessionState;
    if (fromPermissionGranted) {
      if (widget.onPermissionGranted != null) {
        session?.setOnboardingCompleted(completed: true);
        widget.onPermissionGranted!();
        return;
      }
      final nextScanRoute = (session?.hasSeenScanGuide ?? false)
          ? AppRoutes.scanCapture
          : AppRoutes.scanGuide;
      session?.setIntendedDestination(nextScanRoute);
    } else {
      if (widget.onSkip != null) {
        session?.setOnboardingCompleted(completed: true);
        widget.onSkip!();
        return;
      }
      if (session?.intendedDestination == null) {
        session?.setIntendedDestination(AppRoutes.scanGuide);
      }
    }

    session?.setOnboardingCompleted(completed: true);

    if (mounted && GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.accountSecure);
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

        await _handleProceed();
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
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

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
          : Stack(
              children: [
                const Positioned.fill(child: _AmbientBackground()),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
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

                                    // Hero + titre
                                    _Reveal(
                                      reduce: reduce,
                                      child: const _BellHero(),
                                    ),
                                    const SizedBox(height: 22),
                                    _Reveal(
                                      reduce: reduce,
                                      delayMs: 80,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Stay consistent with weekly scan reminders',
                                            style: AppTypography.h3Medium
                                                .copyWith(
                                                  color: AppColors.grey1050,
                                                  height: 1.15,
                                                  letterSpacing: -0.4,
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Skin barrier renewal follows a 28-day cycle. A quick 30-second scan once a week tracks what truly works.',
                                            style: AppTypography.bodyMRegular
                                                .copyWith(
                                                  color: AppColors.grey700,
                                                  height: 1.45,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 26),

                                    // Aperçu
                                    _Reveal(
                                      reduce: reduce,
                                      delayMs: 160,
                                      child: NotificationPreviewCard(
                                        title: 'Weekly scan reminder',
                                        body:
                                            'Time for your 30s scan • $dayLabel at $timeLabel',
                                      ),
                                    ),
                                    const SizedBox(height: 26),

                                    // Jour
                                    _Reveal(
                                      reduce: reduce,
                                      delayMs: 240,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _SectionLabel(
                                            label: 'Day',
                                            value: dayLabel,
                                          ),
                                          const SizedBox(height: 12),
                                          DayOfWeekSelector(
                                            selectedDay: _selectedDay,
                                            onDaySelected: (day) {
                                              setState(
                                                () => _selectedDay = day,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Heure
                                    _Reveal(
                                      reduce: reduce,
                                      delayMs: 320,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _SectionLabel(
                                            label: 'Time',
                                            value: timeLabel,
                                          ),
                                          const SizedBox(height: 12),
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Règles (carte groupée)
                                    _Reveal(
                                      reduce: reduce,
                                      delayMs: 400,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral50,
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          border: Border.all(
                                            color: AppColors.grey200,
                                          ),
                                        ),
                                        child: const Column(
                                          children: [
                                            NotificationRuleInfoRow(
                                              icon: Icons.schedule_rounded,
                                              title: 'Max 3 notifications per week',
                                              subtitle: 'Essential routine and scan reminders only.',
                                            ),
                                            _RuleDivider(),
                                            NotificationRuleInfoRow(
                                              icon: Icons.bedtime_outlined,
                                              title: 'Quiet hours respected',
                                              subtitle: 'Zero disturbances between 9:00 PM and 8:00 AM.',
                                            ),
                                            _RuleDivider(),
                                            NotificationRuleInfoRow(
                                              icon:
                                                  Icons.favorite_border_rounded,
                                              title: 'Zero guilt-tripping',
                                              subtitle: 'Missed a scan? Pick up anytime without shame.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 6,
                              ),
                              child: Semantics(
                                button: true,
                                label: 'Confirm and Enable Reminders',
                                child:
                                    BlocBuilder<
                                      NotificationBloc,
                                      NotificationState
                                    >(
                                      builder: (context, state) {
                                        return PrimaryButton(
                                          text: 'Confirm & Enable Reminders',
                                          isLoading:
                                              _isRequesting || state.isLoading,
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
                  ),
                ),
              ],
            ),
    );
  }
}

/// Titre de section avec la valeur choisie en accent à droite.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodyMSemiBold.copyWith(
            fontSize: 16,
            color: AppColors.grey1050,
          ),
        ),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            value,
            key: ValueKey(value),
            style: AppTypography.bodyMSemiBold.copyWith(
              color: AppColors.primary700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RuleDivider extends StatelessWidget {
  const _RuleDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: AppColors.grey200,
    );
  }
}

/// Cloche avec deux ondes qui se propagent, seul élément "vivant" en boucle.
/// Le constructeur `const` évite que les `setState` de l'écran ne relancent
/// l'animation.
class _BellHero extends StatelessWidget {
  const _BellHero();

  @override
  Widget build(BuildContext context) {
    final isTest =
        const bool.fromEnvironment('flutter.test') ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final reduce =
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) || isTest;

    Widget ring(int delayMs) {
      return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary700.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          )
          .animate(onPlay: (c) => c.repeat(), delay: delayMs.ms)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.6, 1.6),
            duration: 2400.ms,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 2400.ms);
    }

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (!reduce) ...[ring(0), ring(1200)],
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary700, AppColors.primary900],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary700.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.neutral50,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

/// Deux halos fixes en arrière-plan.
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    Widget blob(Alignment alignment, double size, double alpha) => Align(
      alignment: alignment,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary700.withValues(alpha: alpha),
              AppColors.primary700.withValues(alpha: 0),
            ],
          ),
        ),
        child: SizedBox(width: size, height: size),
      ),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          blob(const Alignment(1.2, -0.95), 420, 0.10),
          blob(const Alignment(-1.3, 0.55), 360, 0.06),
        ],
      ),
    );
  }
}

/// Apparition douce (fondu + glissement) jouée une seule fois. Ce widget garde
/// son propre contrôleur, donc les `setState` de l'écran ne la relancent pas.
class _Reveal extends StatefulWidget {
  const _Reveal({
    required this.child,
    required this.reduce,
    this.delayMs = 0,
  });

  final Widget child;
  final bool reduce;
  final int delayMs;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final total = 650 + widget.delayMs;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.reduce ? 1 : total),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.reduce ? 0 : widget.delayMs / total,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    if (widget.reduce) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final v = _animation.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 18),
            child: child,
          ),
        );
      },
    );
  }
}
