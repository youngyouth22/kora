import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/services/revenue_cat_service.dart';

/// Settings tile that triggers RevenueCat's Customer Center modal.
class SubscriptionCustomerCenterTile extends StatelessWidget {
  /// Creates a [SubscriptionCustomerCenterTile].
  const SubscriptionCustomerCenterTile({super.key});

  Future<void> _handleTap(BuildContext context) async {
    try {
      await RevenueCatService.presentCustomerCenter();
    } on Object catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open subscription management.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Manage Kora Pro Subscription',
      child: ListTile(
        leading: const Icon(
          Icons.workspace_premium_outlined,
          color: AppColors.primary,
        ),
        title: Text(
          'Manage Subscription',
          style: AppTypography.bodyLSemiBold.copyWith(
            color: AppColors.grey900,
          ),
        ),
        subtitle: Text(
          'View plan, billing, restore, or cancel',
          style: AppTypography.bodySRegular.copyWith(
            color: AppColors.grey600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.grey400,
        ),
        onTap: () => _handleTap(context),
      ),
    );
  }
}
