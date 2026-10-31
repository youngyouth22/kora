import 'package:equatable/equatable.dart';

/// Severity of an active ingredient layering alert.
enum CompatibilitySeverity {
  /// Advisory tip for optimal layering order or timing.
  advisory,

  /// Warning for ingredients that may cause irritation when layered together.
  caution,
}

/// Pure domain entity describing an active ingredient compatibility check
/// within a routine period (AM or PM).
class RoutineCompatibilityNotice extends Equatable {
  /// Creates a [RoutineCompatibilityNotice].
  const RoutineCompatibilityNotice({
    required this.title,
    required this.message,
    required this.involvedActives,
    this.severity = CompatibilitySeverity.advisory,
  });

  /// Short headline of the compatibility insight.
  final String title;

  /// Actionable recommendation on how to layer or alternate.
  final String message;

  /// List of active ingredients involved.
  final List<String> involvedActives;

  /// Severity level.
  final CompatibilitySeverity severity;

  @override
  List<Object?> get props => [title, message, involvedActives, severity];
}
