import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/camera_permission_service.dart';

/// Screen displayed prior to live camera capture to explain the requirement
/// and request user authorization for front camera access.
class CameraPermissionScreen extends StatefulWidget {
  /// Creates a [CameraPermissionScreen].
  const CameraPermissionScreen({
    super.key,
    this.permissionService,
    this.sessionState,
    this.onPermissionGranted,
    this.onSkip,
  });

  /// Optional injected camera permission service.
  final CameraPermissionService? permissionService;

  /// Optional injected session state for navigation and onboarding guards.
  final AppSessionState? sessionState;

  /// Callback executed when camera permission is successfully granted.
  final VoidCallback? onPermissionGranted;

  /// Callback executed when the user chooses to skip or exit.
  final VoidCallback? onSkip;

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen>
    with WidgetsBindingObserver {
  var _isRequesting = false;
  var _isPermissionDenied = false;
  var _isPermanentlyDenied = false;

  CameraPermissionService get _permissionService =>
      widget.permissionService ??
      (GetIt.instance.isRegistered<CameraPermissionService>()
          ? GetIt.instance<CameraPermissionService>()
          : const DefaultCameraPermissionService());

  AppSessionState? get _sessionState =>
      widget.sessionState ??
      (GetIt.instance.isRegistered<AppSessionState>()
          ? GetIt.instance<AppSessionState>()
          : null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        _proceedToScan();
      }
    } on Object catch (_) {}
  }

  void _proceedToScan() {
    if (widget.onPermissionGranted != null) {
      _sessionState?.setOnboardingCompleted(completed: true);
      widget.onPermissionGranted!();
    } else if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.onboardingReminder);
    }
  }

  Future<void> _handleRequestPermission() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      final granted = await _permissionService.requestCameraPermission();
      if (!mounted) return;

      setState(() => _isRequesting = false);

      if (granted) {
        _proceedToScan();
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

  void _handleSkip() {
    if (widget.onSkip != null) {
      _sessionState?.setOnboardingCompleted(completed: true);
      widget.onSkip!();
    } else if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.onboardingReminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: _isPermissionDenied
          ? EmptyStateView(
              icon: Icons.no_photography_outlined,
              title: _isPermanentlyDenied
                  ? 'Camera Permission Required'
                  : 'Camera Access Denied',
              message: _isPermanentlyDenied
                  ? 'Camera access is disabled for Kora. Please enable it in '
                        'your device settings to scan your skin.'
                  : 'Kora needs camera access to perform your guided skin '
                        'scan. Please allow camera permissions to continue.',
              primaryActionLabel: _isPermanentlyDenied
                  ? 'Open Settings'
                  : 'Try Again',
              onPrimaryAction: _isPermanentlyDenied
                  ? _handleOpenSettings
                  : _handleRequestPermission,
              secondaryActionLabel: 'Continue to Home',
              onSecondaryAction: _handleSkip,
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Text(
                            'Allow Kora to use your camera '
                            ' to scan your skin.',

                            textAlign: TextAlign.center,
                            style: AppTypography.h3Medium.copyWith(
                              color: AppGreyColors.shade1050,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Semantics(
                        button: true,
                        label: 'Enable Camera',
                        child: PrimaryButton(
                          text: 'Enable Camera',
                          isLoading: _isRequesting,
                          onPressed: _handleRequestPermission,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _handleSkip,
                      child: Text(
                        'Maybe Later',
                        style: AppTypography.bodyMMedium.copyWith(
                          color: AppGreyColors.shade700,
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
