import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/subscription_constants.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Screen hosting RevenueCat's remote-configured paywall published in the
/// RevenueCat dashboard.
class KoraPaywallPage extends StatefulWidget {
  /// Creates a [KoraPaywallPage].
  const KoraPaywallPage({
    this.offering,
    this.displayCloseButton = true,
    this.sessionState,
    this.onContinue,
    super.key,
  });

  /// Optional specific RevenueCat [Offering] to present.
  /// When null, displays the current active offering configured in RevenueCat.
  final Offering? offering;

  /// Whether to display a close button on the paywall.
  final bool displayCloseButton;

  /// Optional injected [AppSessionState] for post-paywall routing.
  final AppSessionState? sessionState;

  /// Optional callback invoked when the paywall completes or is dismissed.
  final ValueChanged<bool>? onContinue;

  @override
  State<KoraPaywallPage> createState() => _KoraPaywallPageState();
}

class _KoraPaywallPageState extends State<KoraPaywallPage> {
  bool _hasExited = false;

  AppSessionState? get _sessionState =>
      widget.sessionState ??
      (GetIt.instance.isRegistered<AppSessionState>()
          ? GetIt.instance<AppSessionState>()
          : null);

  bool get _isNativePaywallSupported {
    final isTest =
        const bool.fromEnvironment('flutter.test') ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  void _handleExit({required bool isSubscribed}) {
    if (_hasExited) return;
    _hasExited = true;

    final session = _sessionState;
    if (isSubscribed) {
      session?.setSubscriptionStatus(hasActiveSubscription: true);
    }

    if (!mounted) return;

    if (widget.onContinue != null) {
      widget.onContinue!(isSubscribed);
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop(isSubscribed);
      return;
    }

    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop(isSubscribed);
      return;
    }

    if (router != null) {
      final intended = session?.consumeIntendedDestination();
      if (intended != null &&
          intended != AppRoutes.splash &&
          intended != AppRoutes.paywall &&
          intended != AppRoutes.accountSecure &&
          !intended.startsWith('/onboarding')) {
        context.go(intended);
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  bool _hasActiveEntitlement(CustomerInfo customerInfo) {
    final proEntitlement =
        customerInfo.entitlements.all[SubscriptionConstants.entitlementKoraPro];
    if (proEntitlement != null && proEntitlement.isActive) {
      return true;
    }
    return customerInfo.entitlements.active.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isNativePaywallSupported)
              PaywallView(
                offering: widget.offering,
                displayCloseButton: widget.displayCloseButton,
                onPurchaseCompleted: (customerInfo, storeTransaction) {
                  context.read<SubscriptionBloc?>()?.add(
                    const CheckSubscriptionRequested(),
                  );
                  _handleExit(isSubscribed: true);
                },
                onRestoreCompleted: (customerInfo) {
                  context.read<SubscriptionBloc?>()?.add(
                    const CheckSubscriptionRequested(),
                  );
                  final isPro = _hasActiveEntitlement(customerInfo);
                  _handleExit(isSubscribed: isPro);
                },
                onDismiss: () {
                  _handleExit(isSubscribed: false);
                },
              )
            else
              _FallbackPaywallContent(
                onSubscribe: () {
                  context.read<SubscriptionBloc?>()?.add(
                    const CheckSubscriptionRequested(),
                  );
                  _handleExit(isSubscribed: true);
                },
                onRestore: () {
                  context.read<SubscriptionBloc?>()?.add(
                    const CheckSubscriptionRequested(),
                  );
                  _handleExit(isSubscribed: false);
                },
              ),
            if (widget.displayCloseButton)
              Positioned(
                top: 8,
                right: 12,
                child: Semantics(
                  button: true,
                  label: 'Close paywall',
                  child: IconButton(
                    onPressed: () => _handleExit(isSubscribed: false),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.grey100.withValues(
                        alpha: 0.85,
                      ),
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.grey900,
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FallbackPaywallContent extends StatelessWidget {
  const _FallbackPaywallContent({
    required this.onSubscribe,
    required this.onRestore,
  });

  final VoidCallback onSubscribe;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.primary700,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unlock Kora Pro',
            textAlign: TextAlign.center,
            style: AppTypography.h3Bold.copyWith(
              color: AppColors.grey1050,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Track your 16 skin biomarkers weekly, run product experiments, '
            'and get personalized AI Skin Coach insights.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMRegular.copyWith(
              color: AppColors.grey700,
              height: 1.4,
            ),
          ),
          const Spacer(),
          PrimaryButton(
            text: 'Continue with Kora Pro',
            onPressed: onSubscribe,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRestore,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              'Restore purchases',
              style: AppTypography.bodyMMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
