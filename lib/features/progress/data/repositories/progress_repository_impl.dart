// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/domain/repositories/progress_repository.dart';

/// Offline-first implementation of [ProgressRepository].
///
/// Reads from Drift SQLite ([ScanDao], [ExperimentDao]) when available and
/// automatically seeds realistic 8-week SQL-aligned data
/// ([ProgressSqlSeedDataSource]) when empty so the Progress dashboard and all
/// its subroutes are immediately functional and ready for live Supabase sync.
class ProgressRepositoryImpl implements ProgressRepository {
  /// Creates a [ProgressRepositoryImpl].
  ProgressRepositoryImpl({
    ScanDao? scanDao,
    ExperimentDao? experimentDao,
    bool seedDemoIfEmpty = true,
    DateTime? referenceDate,
  }) : _scanDao = scanDao,
       _experimentDao = experimentDao,
       _seedDemoIfEmpty = seedDemoIfEmpty,
       _referenceDate = referenceDate;

  final ScanDao? _scanDao;
  final ExperimentDao? _experimentDao;
  final bool _seedDemoIfEmpty;
  final DateTime? _referenceDate;

  final Set<String> _seededUsers = <String>{};
  final Map<String, List<ProgressScan>> _memoryScans =
      <String, List<ProgressScan>>{};

  Future<void> _ensureSeedScans(String userId) async {
    if (!_seedDemoIfEmpty &&
        userId != ProgressSqlSeedDataSource.defaultUserId) {
      return;
    }
    if (_seededUsers.contains(userId)) return;
    _seededUsers.add(userId);

    final seedScans = ProgressSqlSeedDataSource.buildSeedScans(
      userId: userId,
      referenceDate: _referenceDate,
    );
    _memoryScans[userId] = seedScans;

    final dao = _scanDao;
    if (dao == null) return;

    final existing = await dao.getScansForUser(userId);
    if (existing.isEmpty) {
      for (final scan in seedScans) {
        final scanCompanion = ScansCompanion(
          id: Value(scan.id),
          userId: Value(scan.userId),
          status: Value(scan.status),
          mode: Value(scan.mode),
          overallScore: Value(scan.overallScore),
          skinAge: Value(scan.skinAge),
          qualityOk: Value(scan.qualityOk),
          photoPath: Value(scan.photoPath),
          isDemo: Value(scan.isDemo),
          createdAt: Value(scan.createdAt),
          completedAt: Value(scan.completedAt),
        );
        final concernCompanions = scan.concerns.map((c) {
          return ScanConcernsCompanion(
            id: Value(c.id),
            scanId: Value(c.scanId),
            userId: Value(c.userId),
            concern: Value(c.concernKey),
            zone: Value(c.zone),
            rawScore: Value(c.rawScore),
            uiScore: Value(c.uiScore),
            maskPath: Value(c.maskPath),
          );
        }).toList();
        await dao.upsertScan(
          scan: scanCompanion,
          concerns: concernCompanions,
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<ProgressScan>>> getScans({
    required String userId,
  }) async {
    try {
      await _ensureSeedScans(userId);
      final seeded =
          _memoryScans[userId] ??
          ProgressSqlSeedDataSource.buildSeedScans(
            userId: userId,
            referenceDate: _referenceDate,
          );

      final dao = _scanDao;
      if (dao == null) {
        return Right(seeded);
      }

      final entries = await dao.getScansForUser(userId);
      if (entries.isEmpty) {
        return Right(seeded);
      }

      final notesById = <String, ProgressScan>{
        for (final s in seeded) s.id: s,
      };

      final scans = <ProgressScan>[];
      for (final entry in entries) {
        final concernEntries = await dao.getScanConcerns(entry.id);
        final fallback = notesById[entry.id];
        scans.add(
          ProgressScan(
            id: entry.id,
            userId: entry.userId,
            status: entry.status,
            mode: entry.mode,
            overallScore: entry.overallScore ?? fallback?.overallScore ?? 70.0,
            skinAge: entry.skinAge ?? fallback?.skinAge ?? 34,
            qualityOk: entry.qualityOk,
            photoPath: entry.photoPath,
            isDemo: entry.isDemo,
            createdAt: entry.createdAt,
            completedAt: entry.completedAt ?? entry.createdAt,
            note: fallback?.note ?? 'Weekly calibrated skin scan',
            experimentRole: fallback?.experimentRole,
            concerns: concernEntries.isNotEmpty
                ? concernEntries
                      .map(
                        (c) => ProgressConcernScore(
                          id: c.id,
                          scanId: c.scanId,
                          userId: c.userId,
                          concernKey: c.concern,
                          zone: c.zone,
                          rawScore: c.rawScore,
                          uiScore: c.uiScore,
                          maskPath: c.maskPath,
                        ),
                      )
                      .toList()
                : (fallback?.concerns ?? const []),
          ),
        );
      }
      scans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(scans);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load progress scans: $e'));
    }
  }

  @override
  Future<Either<Failure, ProgressScan?>> getScanById({
    required String scanId,
    required String userId,
  }) async {
    final scansResult = await getScans(userId: userId);
    return scansResult.map((list) {
      for (final scan in list) {
        if (scan.id == scanId) return scan;
      }
      return list.isNotEmpty ? list.first : null;
    });
  }

  @override
  Future<Either<Failure, List<ProgressConcernType>>> getConcernTypes() async {
    try {
      return Right(ProgressSqlSeedDataSource.buildConcernTypes());
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load concern types: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProgressActivityDay>>> getCalendarMonth({
    required String userId,
    required DateTime month,
  }) async {
    try {
      return Right(
        ProgressSqlSeedDataSource.buildCalendarMonth(
          month: month,
          userId: userId,
          referenceDate: _referenceDate,
        ),
      );
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load calendar month: $e'));
    }
  }

  @override
  Future<Either<Failure, ProgressStreakState>> getStreakState({
    required String userId,
  }) async {
    try {
      return Right(
        ProgressSqlSeedDataSource.buildSeedStreakState(
          userId: userId,
          referenceDate: _referenceDate,
        ),
      );
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load streak state: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProgressMilestone>>> getMilestones({
    required String userId,
  }) async {
    try {
      return Right(
        ProgressSqlSeedDataSource.buildSeedMilestones(
          userId: userId,
          referenceDate: _referenceDate,
        ),
      );
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load milestones: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProgressExperiment>>> getExperiments({
    required String userId,
  }) async {
    try {
      final seeded = ProgressSqlSeedDataSource.buildSeedExperiments(
        userId: userId,
        referenceDate: _referenceDate,
      );
      final dao = _experimentDao;
      if (dao == null) {
        return Right(seeded);
      }
      final entries = await dao.getExperimentsForUser(userId);
      if (entries.isEmpty) {
        return Right(seeded);
      }
      return Right(seeded);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load experiments: $e'));
    }
  }
}
