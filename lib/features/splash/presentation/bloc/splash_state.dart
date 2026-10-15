import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';

/// State representation for splash screen bootstrapping.
class SplashState extends Equatable {
  /// Creates a [SplashState].
  const SplashState({
    this.status = BaseStatus.initial,
    this.bootstrapData,
    this.errorMessage,
  });

  /// Status of the bootstrap operation.
  final BaseStatus status;

  /// Loaded bootstrap data upon success.
  final AppBootstrapData? bootstrapData;

  /// Error message when status is [BaseStatus.failure].
  final String? errorMessage;

  /// Copy with helper for state mutation.
  SplashState copyWith({
    BaseStatus? status,
    AppBootstrapData? bootstrapData,
    String? errorMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      bootstrapData: bootstrapData ?? this.bootstrapData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bootstrapData, errorMessage];
}
