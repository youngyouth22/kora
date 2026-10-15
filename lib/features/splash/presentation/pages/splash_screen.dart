import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:kora/features/splash/presentation/bloc/splash_event.dart';
import 'package:kora/features/splash/presentation/bloc/splash_state.dart';

/// Bootstrapping splash screen for Kora.
///
/// Dispatches [SplashStartedEvent] to resolve session and onboarding status,
/// then notifies [AppSessionState] to trigger reactive GoRouter redirection.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({
    this.sessionState,
    this.bloc,
    super.key,
  });

  /// Injected session state to complete initialization.
  final AppSessionState? sessionState;

  /// Optional injected [SplashBloc] for testability.
  final SplashBloc? bloc;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? GetIt.instance<SplashBloc>();
    _bloc.add(const SplashStartedEvent());
  }

  @override
  void dispose() {
    if (widget.bloc == null) {
      unawaited(_bloc.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>.value(
      value: _bloc,
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.status == BaseStatus.success &&
              state.bootstrapData != null) {
            final data = state.bootstrapData!;
            widget.sessionState?.completeInitialization(
              isOnboardingCompleted: data.isOnboardingCompleted,
              isAuthenticated: data.isAuthenticated,
            );
          }
        },
        builder: (context, state) {
          Widget content;
          if (state.status == BaseStatus.failure) {
            content = _buildErrorView(context, state);
          } else if (state.status == BaseStatus.success) {
            content = const SizedBox.shrink();
          } else {
            content = _buildLoadingView(context);
          }

          return Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: content,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          label: 'Kora Logo',
          child: Text(
            'KORA',
            style: AppTypography.h1Bold.copyWith(
              color: AppPrimaryColors.shade800,
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Skin tracking & routine insights',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMRegular.copyWith(
            color: AppGreyColors.shade800,
          ),
        ),
        const SizedBox(height: 48),
        Semantics(
          label: 'Loading indicator',
          child: const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppPrimaryColors.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, SplashState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 56,
          color: AppErrorColors.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'Initialization Failed',
          textAlign: TextAlign.center,
          style: AppTypography.h4Bold.copyWith(
            color: AppColors.baseColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.errorMessage ??
              'Unable to load your application state. Please try again.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMRegular.copyWith(
            color: AppGreyColors.shade800,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPrimaryColors.shade600,
              foregroundColor: AppColors.scaffoldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _bloc.add(const SplashStartedEvent()),
            child: Text(
              'Retry',
              style: AppTypography.bodyLBold.copyWith(
                color: AppColors.scaffoldColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
