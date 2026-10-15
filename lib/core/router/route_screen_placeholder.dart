// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Clean design-system compliant placeholder screen for Kora routes.
///
/// Used across feature route declarations until concrete feature screens
/// are plugged in. Adheres to [AppColors] and [AppTypography].
class RouteScreenPlaceholder extends StatelessWidget {
  /// Creates a [RouteScreenPlaceholder].
  const RouteScreenPlaceholder({
    required this.title,
    required this.routePath,
    this.parameters = const {},
    this.showBackButton = true,
    super.key,
  });

  /// Name of the screen or feature.
  final String title;

  /// Active route template path.
  final String routePath;

  /// Dynamic route path and query parameters.
  final Map<String, String> parameters;

  /// Whether to display a back button in the app bar.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop() && showBackButton;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        centerTitle: true,
        leading: canPop
            ? Semantics(
                button: true,
                label: 'Go back',
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.grey1000,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              )
            : null,
        title: Text(
          title,
          style: AppTypography.h6SemiBold.copyWith(
            color: AppColors.grey1000,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Path',
                      style: AppTypography.bodySSemiBold.copyWith(
                        color: AppColors.primary800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routePath,
                      style: AppTypography.bodyMMedium.copyWith(
                        color: AppColors.primary900,
                      ),
                    ),
                  ],
                ),
              ),
              if (parameters.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Path Parameters',
                        style: AppTypography.bodySSemiBold.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...parameters.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: AppTypography.bodySRegular.copyWith(
                                  color: AppColors.grey700,
                                ),
                              ),
                              Text(
                                entry.value,
                                style: AppTypography.bodySBold.copyWith(
                                  color: AppColors.grey1000,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Center(
                child: Text(
                  'Feature presentation screen ready for integration.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
