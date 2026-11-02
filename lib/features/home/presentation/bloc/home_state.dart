import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';

/// State of the main home dashboard screen.
class HomeState extends Equatable {
  /// Creates a [HomeState].
  const HomeState({
    this.status = BaseStatus.initial,
    this.data,
    this.errorMessage,
  });

  /// Status of the dashboard loading flow.
  final BaseStatus status;

  /// Live dashboard metrics and user data.
  final HomeDashboardData? data;

  /// Error message if the operation failed.
  final String? errorMessage;

  /// Creates a copy of [HomeState] with optionally replaced fields.
  HomeState copyWith({
    BaseStatus? status,
    HomeDashboardData? data,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
