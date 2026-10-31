// ignore_for_file: document_ignores, prefer_initializing_formals, one_member_abstracts, lines_longer_than_80_chars

import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/splash/data/models/app_bootstrap_model.dart';

/// Contract for local bootstrap checks.
abstract class SplashLocalDataSource {
  /// Resolves the cached bootstrap configuration.
  Future<AppBootstrapModel> getBootstrapData();
}

/// Implementation of [SplashLocalDataSource] accessing local datasources and preferences.
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  /// Creates the datasource with injected [OnboardingLocalDataSource],
  /// optional [AppPreferencesService], and optional [AuthRemoteDataSource].
  SplashLocalDataSourceImpl({
    required OnboardingLocalDataSource onboardingLocalDataSource,
    AppPreferencesService? preferencesService,
    AuthRemoteDataSource? authRemoteDataSource,
  }) : _onboardingLocalDataSource = onboardingLocalDataSource,
       _preferencesService = preferencesService,
       _authRemoteDataSource = authRemoteDataSource;

  final OnboardingLocalDataSource _onboardingLocalDataSource;
  final AppPreferencesService? _preferencesService;
  final AuthRemoteDataSource? _authRemoteDataSource;

  @override
  Future<AppBootstrapModel> getBootstrapData() async {
    var isCompleted = _preferencesService?.isOnboardingCompleted ?? false;

    if (!isCompleted) {
      isCompleted = await _onboardingLocalDataSource.isOnboardingCompleted();
      if (isCompleted && _preferencesService != null) {
        await _preferencesService.setOnboardingCompleted(completed: true);
      }
    }

    var isAuthenticated = false;
    final auth = _authRemoteDataSource;
    if (auth != null) {
      try {
        final user = await auth.getCurrentUser();
        isAuthenticated = user != null;
      } on Object catch (_) {}
    }

    return AppBootstrapModel(
      isOnboardingCompleted: isCompleted,
      isAuthenticated: isAuthenticated,
    );
  }
}
