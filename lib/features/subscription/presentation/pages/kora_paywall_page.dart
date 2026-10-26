import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Screen hosting RevenueCat's remote-configured paywall.
class KoraPaywallPage extends StatelessWidget {
  /// Creates a [KoraPaywallPage].
  const KoraPaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: SafeArea(
        child: PaywallView(
          onPurchaseCompleted: (customerInfo, storeTransaction) {
            context.read<SubscriptionBloc>().add(
              const CheckSubscriptionRequested(),
            );
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          },
          onRestoreCompleted: (customerInfo) {
            context.read<SubscriptionBloc>().add(
              const CheckSubscriptionRequested(),
            );
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          },
          onDismiss: () {
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(false);
            }
          },
        ),
      ),
    );
  }
}
