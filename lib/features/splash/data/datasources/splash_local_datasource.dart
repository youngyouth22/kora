// ignore_for_file: document_ignores
// ignore_for_file: one_member_abstracts
// ignore_for_file: prefer_initializing_formals

import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/splash/data/models/app_bootstrap_model.dart';

/// Contract for local bootstrap checks.
abstract class SplashLocalDataSource {
  /// Resolves the cached bootstrap configuration.
  Future<AppBootstrapModel> getBootstrapData();
}

/// Implementation of [SplashLocalDataSource] accessing local datasources.
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  /// Creates the datasource with injected [OnboardingLocalDataSource].
  SplashLocalDataSourceImpl({
    required OnboardingLocalDataSource onboardingLocalDataSource,
  }) : _onboardingLocalDataSource = onboardingLocalDataSource;

  final OnboardingLocalDataSource _onboardingLocalDataSource;

  @override
  Future<AppBootstrapModel> getBootstrapData() async {
    final isCompleted = await _onboardingLocalDataSource
        .isOnboardingCompleted();

    return AppBootstrapModel(
      isOnboardingCompleted: isCompleted,
    );
  }
}
