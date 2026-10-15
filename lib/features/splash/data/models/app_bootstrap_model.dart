import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';

/// Data model representing bootstrap status with JSON/mapping support.
class AppBootstrapModel extends AppBootstrapData {
  /// Creates an [AppBootstrapModel].
  const AppBootstrapModel({
    required super.isOnboardingCompleted,
    super.isAuthenticated = false,
  });

  /// Factory creating [AppBootstrapModel] from JSON map.
  factory AppBootstrapModel.fromJson(Map<String, dynamic> json) {
    return AppBootstrapModel(
      isOnboardingCompleted: json['is_onboarding_completed'] as bool? ?? false,
      isAuthenticated: json['is_authenticated'] as bool? ?? false,
    );
  }

  /// Converts this model to a serializable JSON map.
  Map<String, dynamic> toJson() {
    return {
      'is_onboarding_completed': isOnboardingCompleted,
      'is_authenticated': isAuthenticated,
    };
  }

  /// Converts this model to pure domain entity.
  AppBootstrapData toEntity() => AppBootstrapData(
    isOnboardingCompleted: isOnboardingCompleted,
    isAuthenticated: isAuthenticated,
  );
}
