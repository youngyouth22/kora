import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import 'package:kora/features/auth/presentation/pages/email_entry_page.dart';
import 'package:kora/features/auth/presentation/widgets/social_auth_button.dart';

/// Screen allowing guest users to link their anonymous session to a permanent
/// account after experiencing the skin scan value and paywall.
class AccountSecurePage extends StatelessWidget {
  /// Creates an [AccountSecurePage].
  const AccountSecurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated ||
            state.status == AuthStatus.skipped) {
          // O19: Navigate to Home dashboard
          context.go(AppRoutes.home);
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppErrorColors.shade500,
              content: Text(
                state.errorMessage!,
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
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
                  if (isIos) ...[
                    SocialAuthButton(
                      text: 'Continue with Apple',
                      icon: const Icon(
                        Icons.apple,
                        color: AppGreyColors.white,
                        size: 24,
                      ),
                      backgroundColor: AppGreyColors.shade1050,
                      textColor: AppGreyColors.white,
                      borderColor: AppGreyColors.shade1050,
                      isLoading: state.isLoading,
                      onPressed: () => context.read<AuthBloc>().add(
                        const AuthLinkAppleRequested(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Continue with Email',
                    height: 52,
                    icon: const Icon(
                      Icons.mail_outline,
                      color: AppGreyColors.shade1050,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AuthBloc>(),
                            child: const EmailEntryPage(),
                          ),
                        ),
                      );
                    },
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
}
