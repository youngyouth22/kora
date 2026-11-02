import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';

/// Contract for aggregating live home dashboard data.
abstract class HomeRepository {
  /// Fetches consolidated live home dashboard metrics and status.
  Future<Either<Failure, HomeDashboardData>> getDashboardData();

  /// Logs or updates the daily skin-feel check-in (1..3).
  Future<Either<Failure, void>> submitSkinCheckin({required int feel});

  /// Toggles today's skin tip read state.
  Future<Either<Failure, void>> toggleDailyTip({required bool read});

  /// Watches for scan updates in the local database.
  Stream<void> watchScans();
}
