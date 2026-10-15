// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/router/app_routes.dart';

/// Resilient error page rendered when a route fails to resolve.
///
/// Adheres to Kora Rules Article 6:
/// - Explicitly states WHAT HAPPENED + WHAT TO DO.
/// - 52dp height primary CTA.
/// - Uses [AppColors] and [AppTypography] tokens exclusively.
class RouteErrorScreen extends StatelessWidget {
  /// Creates a [RouteErrorScreen] with an optional error description.
  const RouteErrorScreen({
    this.errorMessage,
    super.key,
  });

  /// Optional error message or exception details.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Icon(
                  Icons.explore_off_rounded,
                  size: 64,
                  color: AppColors.secondary600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                textAlign: TextAlign.center,
                style: AppTypography.h4Bold.copyWith(
                  color: AppColors.grey1000,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The screen you are looking for does not exist or has moved. '
                'Return to the dashboard to continue your routine.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey800,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Semantics(
                button: true,
                label: 'Return to home dashboard',
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: AppColors.grey50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(
                      'Back to Home',
                      style: AppTypography.bodyLSemiBold.copyWith(
                        color: AppColors.grey50,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
