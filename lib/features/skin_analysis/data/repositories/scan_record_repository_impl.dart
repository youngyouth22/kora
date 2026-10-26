// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/skin_analysis/domain/entities/scan_record.dart';
import 'package:kora/features/skin_analysis/domain/repositories/scan_record_repository.dart';

/// Offline-first implementation of [ScanRecordRepository].
class ScanRecordRepositoryImpl implements ScanRecordRepository {
  /// Creates a [ScanRecordRepositoryImpl].
  ScanRecordRepositoryImpl({
    required ScanDao scanDao,
    required SyncMutationDao mutationDao,
    required SyncEngine syncEngine,
  }) : _scanDao = scanDao,
       _mutationDao = mutationDao,
       _syncEngine = syncEngine;

  final ScanDao _scanDao;
  final SyncMutationDao _mutationDao;
  final SyncEngine _syncEngine;

  @override
  Future<Either<Failure, ScanRecord?>> getScan({required String id}) async {
    try {
      final entry = await _scanDao.getScan(id);
      if (entry == null) return const Right(null);

      final concernEntries = await _scanDao.getScanConcerns(id);
      return Right(_mapToEntity(entry, concernEntries));
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read scan from cache: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ScanRecord>>> getScansForUser({
    required String userId,
  }) async {
    try {
      final scanEntries = await _scanDao.getScansForUser(userId);
      final records = <ScanRecord>[];

      for (final scan in scanEntries) {
        final concerns = await _scanDao.getScanConcerns(scan.id);
        records.add(_mapToEntity(scan, concerns));
      }

      return Right(records);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read user scans: $e'));
    }
  }

  @override
  Stream<List<ScanRecord>> watchScansForUser({required String userId}) {
    return _scanDao.watchScansForUser(userId).asyncMap((scanEntries) async {
      final records = <ScanRecord>[];
      for (final scan in scanEntries) {
        final concerns = await _scanDao.getScanConcerns(scan.id);
        records.add(_mapToEntity(scan, concerns));
      }
      return records;
    });
  }

  @override
  Future<Either<Failure, void>> saveScan(ScanRecord scan) async {
    try {
      final now = DateTime.now();

      final scanCompanion = ScansCompanion(
        id: Value(scan.id),
        userId: Value(scan.userId),
        status: Value(scan.status),
        mode: Value(scan.mode),
        overallScore: Value(scan.overallScore),
        skinAge: Value(scan.skinAge),
        photoPath: Value(scan.photoPath),
        createdAt: Value(scan.createdAt),
        completedAt: Value(scan.completedAt ?? now),
      );

      final concernCompanions = scan.concerns.map((c) {
        return ScanConcernsCompanion(
          id: Value(c.id),
          scanId: Value(c.scanId),
          userId: Value(c.userId),
          concern: Value(c.concern),
          zone: Value(c.zone),
          rawScore: Value(c.rawScore),
          uiScore: Value(c.uiScore),
          maskPath: Value(c.maskPath),
        );
      }).toList();

      // 1. Write atomically to Drift SQLite
      await _scanDao.upsertScan(
        scan: scanCompanion,
        concerns: concernCompanions,
      );

      // 2. Queue scan mutation in outbox
      final scanPayload = <String, dynamic>{
        'id': scan.id,
        'user_id': scan.userId,
        'status': scan.status,
        'mode': scan.mode,
        'overall_score': scan.overallScore,
        'skin_age': scan.skinAge,
        'photo_path': scan.photoPath,
        'created_at': scan.createdAt.toIso8601String(),
        'completed_at': (scan.completedAt ?? now).toIso8601String(),
      };

      await _mutationDao.enqueue(
        id: 'mut_scan_${scan.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'scans',
        recordId: scan.id,
        action: 'upsert',
        payload: scanPayload,
      );

      // 3. Queue concerns mutations
      for (final c in scan.concerns) {
        final concernPayload = <String, dynamic>{
          'id': c.id,
          'scan_id': c.scanId,
          'user_id': c.userId,
          'concern': c.concern,
          'zone': c.zone,
          'raw_score': c.rawScore,
          'ui_score': c.uiScore,
          'mask_path': c.maskPath,
        };

        await _mutationDao.enqueue(
          id: 'mut_concern_${c.id}_${now.millisecondsSinceEpoch}',
          targetTable: 'scan_concerns',
          recordId: c.id,
          action: 'upsert',
          payload: concernPayload,
        );
      }

      // 4. Notify sync engine to flush
      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to persist scan locally: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncScans({required String userId}) async {
    try {
      await _syncEngine.sync(userId: userId);
      return const Right(null);
    } on Object catch (e) {
      return Left(NetworkFailure(message: 'Failed to sync scans: $e'));
    }
  }

  ScanRecord _mapToEntity(ScanEntry entry, List<ScanConcernEntry> concerns) {
    return ScanRecord(
      id: entry.id,
      userId: entry.userId,
      status: entry.status,
      mode: entry.mode,
      overallScore: entry.overallScore,
      skinAge: entry.skinAge,
      photoPath: entry.photoPath,
      createdAt: entry.createdAt,
      completedAt: entry.completedAt,
      concerns: concerns
          .map(
            (c) => ScanConcernRecord(
              id: c.id,
              scanId: c.scanId,
              userId: c.userId,
              concern: c.concern,
              zone: c.zone,
              rawScore: c.rawScore,
              uiScore: c.uiScore,
              maskPath: c.maskPath,
            ),
          )
          .toList(),
    );
  }
}
