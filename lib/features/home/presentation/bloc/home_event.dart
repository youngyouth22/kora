import 'package:equatable/equatable.dart';

/// Base class for all home bloc events.
abstract class HomeEvent extends Equatable {
  /// Creates a [HomeEvent].
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to initialize and fetch live home dashboard metrics.
class HomeStarted extends HomeEvent {
  /// Creates a [HomeStarted] event.
  const HomeStarted();
}

/// Dispatched to refresh live home dashboard metrics.
class HomeRefreshed extends HomeEvent {
  /// Creates a [HomeRefreshed] event.
  const HomeRefreshed();
}

/// Dispatched to record daily skin feel check-in.
class HomeSkinCheckinSubmitted extends HomeEvent {
  /// Creates a [HomeSkinCheckinSubmitted] event with selected [feel] (1..3).
  const HomeSkinCheckinSubmitted(this.feel);

  /// Skin feel rating integer (1 = worse, 2 = same, 3 = better).
  final int feel;

  @override
  List<Object?> get props => [feel];
}

/// Dispatched to mark daily tip read/unread.
class HomeDailyTipToggled extends HomeEvent {
  /// Creates a [HomeDailyTipToggled] event with [read] state.
  const HomeDailyTipToggled({required this.read});

  /// Whether the tip is marked as read.
  final bool read;

  @override
  List<Object?> get props => [read];
}
