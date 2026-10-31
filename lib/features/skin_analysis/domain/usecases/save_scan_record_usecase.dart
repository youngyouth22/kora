import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/domain/entities/scan_record.dart';
import 'package:kora/features/skin_analysis/domain/repositories/scan_record_repository.dart';

/// Usecase to persist a completed skin scan and its concern breakdowns
/// into the local Drift SQLite database and queue Supabase synchronization.
class SaveScanRecordUseCase {
  /// Creates a [SaveScanRecordUseCase].
  const SaveScanRecordUseCase(this._repository);

  final ScanRecordRepository _repository;

  /// Executes saving the [ScanRecord].
  Future<Either<Failure, void>> call(ScanRecord scan) {
    return _repository.saveScan(scan);
  }
}
