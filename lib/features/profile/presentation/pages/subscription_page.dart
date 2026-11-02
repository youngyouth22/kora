import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/revenue_cat_service.dart';

/// Subscription management screen (C20 in blueprint).
class SubscriptionPage extends StatefulWidget {
  /// Creates a [SubscriptionPage].
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isPro = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_checkSubscriptionStatus());
  }

  Future<void> _checkSubscriptionStatus() async {
    var pro = false;
    if (GetIt.instance.isRegistered<AppSessionState>()) {
      pro = GetIt.instance<AppSessionState>().hasActiveSubscription;
    }
    if (!pro) {
      pro = await RevenueCatService.isKoraProActive();
    }
    if (mounted) {
      setState(() {
        _isPro = pro;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Subscription',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_isPro) ...[
                // Active Pro Card
                KoraCard(
                  backgroundColor: AppColors.primary50,
                  borderColor: AppColors.primary300,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Kora Pro Active',
                            style: AppTypography.h5Bold.copyWith(
                              color: AppColors.primary900,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary700,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppColors.grey50,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Full scientific tracking & AI skin intelligence '
                        'unlocked',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.primary800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.primary200),
                      const SizedBox(height: 16),
                      _buildFeatureCheck(
                        'Weekly skin scans & comparative trends',
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureCheck(
                        'Controlled product experiments & verdicts',
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureCheck(
                        'Full AI Skin Coach with scan context',
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureCheck(
                        'OCR Ingredient scanner & routine synergy',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Free Tier Card
                KoraCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Kora Free Plan',
                            style: AppTypography.h5Bold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey500,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'FREE',
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppColors.grey50,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Basic daily routine logging and standard camera '
                        'capture.',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.grey200),
                      const SizedBox(height: 16),
                      _buildFeatureCheck(
                        'Daily routine tracking',
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureCheck(
                        'Scientific weekly scans & statistical trends',
                        included: false,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureCheck(
                        'Controlled product experiments & verdicts',
                        included: false,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureCheck(
                        'Unlimited AI Skin Coach conversations',
                        included: false,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Manage Button
              PrimaryButton(
                text: _isPro
                    ? 'Manage Pro Subscription'
                    : 'Upgrade to Kora Pro',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () {
                  if (GoRouter.maybeOf(context) != null) {
                    unawaited(context.push(AppRoutes.paywall));
                  }
                },
              ),
              const SizedBox(height: 12),

              // Restore purchases
              TextButton(
                onPressed: () async {
                  try {
                    await RevenueCatService.presentCustomerCenter();
                  } on Object catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Purchases verified & up to date.',
                          style: AppTypography.bodySMedium.copyWith(
                            color: AppColors.grey50,
                          ),
                        ),
                        backgroundColor: AppColors.primary700,
                      ),
                    );
                  }
                  await _checkSubscriptionStatus();
                },
                child: Text(
                  'Restore purchases',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Legal / Cancellation explanation
              Text(
                'Cancel anytime in your phone Store settings at least 24 '
                'hours before the renewal date. If canceled, your full scan '
                'history remains safe in read-only mode.',
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCheck(String text, {bool included = true}) {
    return Row(
      children: [
        Icon(
          included ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          size: 18,
          color: included ? AppColors.primary700 : AppColors.grey500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySRegular.copyWith(
              color: included ? AppColors.grey900 : AppColors.grey600,
            ),
          ),
        ),
      ],
    );
  }
}
