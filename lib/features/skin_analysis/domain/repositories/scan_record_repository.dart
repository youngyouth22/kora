import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/domain/entities/scan_record.dart';

/// Contract for persistent skin scan records with offline-first guarantees.
abstract class ScanRecordRepository {
  /// Retrieves a scan by [id] from local Drift cache.
  Future<Either<Failure, ScanRecord?>> getScan({required String id});

  /// Retrieves all historical scans for [userId] from local Drift cache.
  Future<Either<Failure, List<ScanRecord>>> getScansForUser({
    required String userId,
  });

  /// Watches all historical scans for [userId] reactively.
  Stream<List<ScanRecord>> watchScansForUser({required String userId});

  /// Saves a scan locally in Drift and enqueues it for background remote
  /// synchronization.
  Future<Either<Failure, void>> saveScan(ScanRecord scan);

  /// Synchronizes scans with remote Supabase storage.
  Future<Either<Failure, void>> syncScans({required String userId});
}
