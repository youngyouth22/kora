import 'package:equatable/equatable.dart';

/// Base event for splash screen state management.
abstract class SplashEvent extends Equatable {
  /// Default const constructor.
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to trigger initial app bootstrapping.
class SplashStartedEvent extends SplashEvent {
  /// Default const constructor.
  const SplashStartedEvent();
}
