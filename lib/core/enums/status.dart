/// Standard status enum for BLoC states across Kora.
///
/// Mandated by Kora Rules Article 2: states use a status enum
/// rather than a tangle of nullable booleans.
enum BaseStatus {
  /// Initial state before any action is triggered.
  initial,

  /// Asynchronous operation in progress (loading indicator).
  loading,

  /// Operation finished successfully.
  success,

  /// Operation failed with an error.
  failure;

  /// Whether the current state is initial.
  bool get isInitial => this == BaseStatus.initial;

  /// Whether the current state is loading.
  bool get isLoading => this == BaseStatus.loading;

  /// Whether the current state is success.
  bool get isSuccess => this == BaseStatus.success;

  /// Whether the current state is failure.
  bool get isFailure => this == BaseStatus.failure;
}
