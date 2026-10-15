import 'package:equatable/equatable.dart';

/// Pure domain entity holding initial application bootstrap state.
class AppBootstrapData extends Equatable {
  /// Creates an [AppBootstrapData] entity.
  const AppBootstrapData({
    required this.isOnboardingCompleted,
    this.isAuthenticated = false,
  });

  /// Whether the user has completed the onboarding flow.
  final bool isOnboardingCompleted;

  /// Whether the user has an active authenticated session.
  final bool isAuthenticated;

  @override
  List<Object?> get props => [isOnboardingCompleted, isAuthenticated];
}
