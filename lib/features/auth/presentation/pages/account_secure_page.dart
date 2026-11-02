import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/revenue_cat_service.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import 'package:kora/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/link_user_account_usecase.dart';

/// Screen allowing guest users to link their anonymous session to a permanent
/// Google account after completing the onboarding flow.
class AccountSecurePage extends StatelessWidget {
  /// Creates an [AccountSecurePage].
  const AccountSecurePage({
    this.sessionState,
    this.showPaywallAfterAuth = true,
    super.key,
  });

  /// Optional injected [AppSessionState].
  final AppSessionState? sessionState;

  /// Whether to present the RevenueCat paywall after authentication or skip
  /// if the user does not yet have an active subscription.
  final bool showPaywallAfterAuth;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated ||
            state.status == AuthStatus.skipped) {
          final session =
              sessionState ??
              (GetIt.instance.isRegistered<AppSessionState>()
                  ? GetIt.instance<AppSessionState>()
                  : null);

          if (GetIt.instance.isRegistered<CompleteOnboardingUseCase>()) {
            unawaited(
              GetIt.instance<CompleteOnboardingUseCase>()(const NoParams()),
            );
          }
          session
            ?..setAccountSecureRequired(required: false)
            ..setOnboardingCompleted(completed: true);

          if (state.status == AuthStatus.authenticated) {
            session?.setAuthenticated(authenticated: true);
            final userId = state.user?.id;
            if (userId != null) {
              if (GetIt.instance.isRegistered<LinkUserAccountUseCase>()) {
                unawaited(
                  GetIt.instance<LinkUserAccountUseCase>()(userId),
                );
              }
              unawaited(_syncRevenueCatIdentity(userId, session));
            }
          }

          if (GoRouter.maybeOf(context) == null) return;

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(state.status == AuthStatus.authenticated);
            return;
          }

          final hasSub = session?.hasActiveSubscription ?? false;
          if (showPaywallAfterAuth && !hasSub) {
            context.go(AppRoutes.paywall);
            return;
          }

          final intended = session?.consumeIntendedDestination();
          if (intended != null &&
              intended != AppRoutes.splash &&
              intended != AppRoutes.accountSecure &&
              !intended.startsWith('/onboarding')) {
            context.go(intended);
          } else {
            context.go(AppRoutes.home);
          }
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          final error = state.errorMessage!;
          final isGoogleConsoleError =
              error.contains('28444') ||
              error.contains('Developer console') ||
              error.contains('clientConfigurationError') ||
              error.contains('Google Sign-In') ||
              error.contains('GoogleSignInException');

          if (isGoogleConsoleError) {
            _showGoogleSignInUnavailableDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppErrorColors.shade500,
                content: Text(
                  error,
                  style: AppTypography.bodyMRegular.copyWith(
                    color: AppGreyColors.white,
                  ),
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
          appBar: Navigator.of(context).canPop()
              ? AppBar(
                  backgroundColor: AppColors.scaffoldColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppGreyColors.shade1050,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                )
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppPrimaryColors.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppPrimaryColors.shade700,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Protect your skin progress',
                    textAlign: TextAlign.center,
                    style: AppTypography.h3Bold.copyWith(
                      color: AppGreyColors.shade1050,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Link your session to keep your scan history, '
                    'custom routine, and progress safe.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLRegular.copyWith(
                      color: AppGreyColors.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildBenefitRow(
                    icon: Icons.check_circle_outline,
                    text: 'Instant sync across your devices',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    icon: Icons.check_circle_outline,
                    text: 'Never lose your scan scores and comparison photos',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    icon: Icons.check_circle_outline,
                    text: 'Keep your customized active skincare routine',
                  ),
                  const SizedBox(height: 36),
                  SocialAuthButton(
                    text: 'Continue with Google',
                    icon: Image.asset(
                      'assets/icons/google.png',
                      width: 22,
                      height: 22,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.g_mobiledata,
                        color: AppGreyColors.shade900,
                        size: 26,
                      ),
                    ),
                    isLoading: state.isLoading,
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLinkGoogleRequested(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const AuthSkipRequested(),
                          ),
                    child: Text(
                      'Maybe later',
                      style: AppTypography.bodyMRegular.copyWith(
                        color: AppGreyColors.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _syncRevenueCatIdentity(
    String userId,
    AppSessionState? session,
  ) async {
    try {
      await RevenueCatService.logIn(userId);
      final isPro = await RevenueCatService.isKoraProActive();
      if (isPro) {
        session?.setSubscriptionStatus(hasActiveSubscription: true);
      }
    } on Object catch (_) {}
  }

  Widget _buildBenefitRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: AppPrimaryColors.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMRegular.copyWith(
              color: AppGreyColors.shade900,
            ),
          ),
        ),
      ],
    );
  }

  void _showGoogleSignInUnavailableDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppGreyColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppGreyColors.shade300),
            ),
            icon: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppPrimaryColors.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppPrimaryColors.shade700,
                size: 28,
              ),
            ),
            title: Text(
              'Google Sign-In Unavailable',
              textAlign: TextAlign.center,
              style: AppTypography.h5Bold.copyWith(
                color: AppGreyColors.shade1050,
              ),
            ),
            content: Text(
              'Google Sign-In is not currently available in this '
              'test environment. You can continue using the full app in '
              'guest mode without any interruption.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMRegular.copyWith(
                color: AppGreyColors.shade700,
                height: 1.4,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    text: 'Continue as Guest',
                    height: 48,
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AuthBloc>().add(
                        const AuthSkipRequested(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTypography.bodyMRegular.copyWith(
                        color: AppGreyColors.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
