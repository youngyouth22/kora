// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/domain/repositories/progress_repository.dart';

/// Offline-first implementation of [ProgressRepository].
///
/// Reads from Drift SQLite ([ScanDao], [ExperimentDao], [RoutineDao]) when
/// available and falls back to seed data ([ProgressSqlSeedDataSource]) in
/// mock/test environments when the database is absent.
class ProgressRepositoryImpl implements ProgressRepository {
  /// Creates a [ProgressRepositoryImpl].
  ProgressRepositoryImpl({
    ScanDao? scanDao,
    ExperimentDao? experimentDao,
    RoutineDao? routineDao,
    bool seedDemoIfEmpty = true,
    DateTime? referenceDate,
  }) : _scanDao = scanDao,
       _experimentDao = experimentDao,
       _routineDao = routineDao,
       _seedDemoIfEmpty = seedDemoIfEmpty,
       _referenceDate = referenceDate;

  final ScanDao? _scanDao;
  final ExperimentDao? _experimentDao;
  final RoutineDao? _routineDao;
  final bool _seedDemoIfEmpty;
  final DateTime? _referenceDate;

  final Set<String> _seededUsers = <String>{};
  final Map<String, List<ProgressScan>> _memoryScans =
      <String, List<ProgressScan>>{};

  Future<void> _ensureSeedScans(String userId) async {
    if (!_seedDemoIfEmpty) return;
    // Only populate demo seed records for demo accounts or unauthenticated
    // fallback
    if (userId != ProgressSqlSeedDataSource.defaultUserId &&
        userId != '00000000-0000-0000-0000-000000000001') {
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

      final dao = _scanDao;
      if (dao == null) {
        final seeded =
            _memoryScans[userId] ??
            ProgressSqlSeedDataSource.buildSeedScans(
              userId: userId,
              referenceDate: _referenceDate,
            );
        return Right(seeded);
      }

      final entries = await dao.getScansForUser(userId);
      if (entries.isEmpty) {
        if (_seedDemoIfEmpty &&
            (userId == ProgressSqlSeedDataSource.defaultUserId ||
                userId == '00000000-0000-0000-0000-000000000001')) {
          final seeded = ProgressSqlSeedDataSource.buildSeedScans(
            userId: userId,
            referenceDate: _referenceDate,
          );
          return Right(seeded);
        }
        return const Right([]);
      }

      final scans = <ProgressScan>[];
      for (final entry in entries) {
        final concernEntries = await dao.getScanConcerns(entry.id);
        scans.add(
          ProgressScan(
            id: entry.id,
            userId: entry.userId,
            status: entry.status,
            mode: entry.mode,
            overallScore: entry.overallScore ?? 70.0,
            skinAge: entry.skinAge ?? 30,
            qualityOk: entry.qualityOk,
            photoPath: entry.photoPath,
            isDemo: entry.isDemo,
            createdAt: entry.createdAt,
            completedAt: entry.completedAt ?? entry.createdAt,
            note: 'Weekly calibrated skin scan',
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
                : const [],
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
      if (_scanDao == null && _routineDao == null && _seedDemoIfEmpty) {
        return Right(
          ProgressSqlSeedDataSource.buildCalendarMonth(
            month: month,
            userId: userId,
            referenceDate: _referenceDate,
          ),
        );
      }

      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

      final scans = _scanDao != null
          ? await _scanDao.getScansForUser(userId)
          : const <ScanEntry>[];
      final rawRoutineLogs = _routineDao != null
          ? await _routineDao.getAllRoutineLogs(userId)
          : const <RoutineLogEntry>[];
      final routineLogs = rawRoutineLogs
          .where((l) => !_isDemoSeedLog(l.id))
          .toList();

      final activityDays = <ProgressActivityDay>[];
      for (var day = 1; day <= daysInMonth; day++) {
        final currentDate = DateTime(month.year, month.month, day);
        final dateIso =
            '${currentDate.year.toString().padLeft(4, '0')}-'
            '${currentDate.month.toString().padLeft(2, '0')}-'
            '${currentDate.day.toString().padLeft(2, '0')}';

        final scansOnDate = scans.where((s) {
          final d = s.createdAt.toLocal();
          return d.year == currentDate.year &&
              d.month == currentDate.month &&
              d.day == currentDate.day;
        }).toList();

        final logsOnDate = routineLogs.where((l) => l.logDate == dateIso);
        final hadRoutine = logsOnDate.any((l) => l.done);
        final hadScan = scansOnDate.isNotEmpty;

        var actions = 0;
        if (hadScan) actions += 1;
        if (hadRoutine) actions += 1;

        activityDays.add(
          ProgressActivityDay(
            userId: userId,
            day: currentDate,
            actions: actions,
            hadScan: hadScan,
            hadRoutine: hadRoutine,
            hadTask: hadRoutine,
            scanId: hadScan ? scansOnDate.first.id : null,
            scanScore: hadScan ? scansOnDate.first.overallScore : null,
            summaryNote: hadScan
                ? 'Weekly calibrated scan completed'
                : (hadRoutine ? 'Routine completed' : null),
          ),
        );
      }

      return Right(activityDays);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load calendar month: $e'));
    }
  }

  @override
  Future<Either<Failure, ProgressStreakState>> getStreakState({
    required String userId,
  }) async {
    try {
      if (_scanDao == null && _routineDao == null && _seedDemoIfEmpty) {
        return Right(
          ProgressSqlSeedDataSource.buildSeedStreakState(
            userId: userId,
            referenceDate: _referenceDate,
          ),
        );
      }

      final rawRoutineLogs = _routineDao != null
          ? await _routineDao.getAllRoutineLogs(userId)
          : const <RoutineLogEntry>[];
      final routineLogs = rawRoutineLogs
          .where((l) => !_isDemoSeedLog(l.id))
          .toList();
      final scans = _scanDao != null
          ? await _scanDao.getScansForUser(userId)
          : const <ScanEntry>[];

      // Extract unique active dates
      final activeDateStrings = <String>{};
      for (final l in routineLogs) {
        if (l.done) {
          activeDateStrings.add(l.logDate);
        }
      }
      for (final s in scans) {
        final d = s.createdAt.toLocal();
        final iso =
            '${d.year.toString().padLeft(4, '0')}-'
            '${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}';
        activeDateStrings.add(iso);
      }

      final activeDates =
          activeDateStrings
              .map(DateTime.tryParse)
              .whereType<DateTime>()
              .map((dt) => DateTime(dt.year, dt.month, dt.day))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

      final now = _referenceDate ?? DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      var currentStreak = 0;
      var checkDate = activeDates.contains(today) ? today : yesterday;

      while (activeDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Calculate longest streak
      var longestStreak = 0;
      var streakCount = 0;
      DateTime? prevDate;
      final sortedAsc = List<DateTime>.from(activeDates)
        ..sort((a, b) => a.compareTo(b));
      for (final d in sortedAsc) {
        if (prevDate == null) {
          streakCount = 1;
        } else if (d.difference(prevDate).inDays == 1) {
          streakCount++;
        } else {
          streakCount = 1;
        }
        if (streakCount > longestStreak) {
          longestStreak = streakCount;
        }
        prevDate = d;
      }
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      // Calculate weekly scan streak
      final scanWeeks = <int>{};
      for (final s in scans) {
        final weekNumber = s.createdAt.difference(DateTime(2024)).inDays ~/ 7;
        scanWeeks.add(weekNumber);
      }
      final currentWeek = today.difference(DateTime(2024)).inDays ~/ 7;
      var weeklyScanStreak = 0;
      var checkWeek = scanWeeks.contains(currentWeek)
          ? currentWeek
          : currentWeek - 1;
      while (scanWeeks.contains(checkWeek)) {
        weeklyScanStreak++;
        checkWeek--;
      }

      return Right(
        ProgressStreakState(
          userId: userId,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastActiveDate: activeDates.isNotEmpty ? activeDates.first : null,
          freezesAvailable: 1,
          freezesUsedTotal: 0,
          weeklyScanStreak: weeklyScanStreak,
          longestWeeklyScanStreak: weeklyScanStreak,
          weeklyJokerAvailable: true,
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
      if (_scanDao == null && _seedDemoIfEmpty) {
        return Right(
          ProgressSqlSeedDataSource.buildSeedMilestones(
            userId: userId,
            referenceDate: _referenceDate,
          ),
        );
      }

      final scans = _scanDao != null
          ? await _scanDao.getScansForUser(userId)
          : const <ScanEntry>[];

      final milestones = <ProgressMilestone>[];
      if (scans.isNotEmpty) {
        final firstScan = scans.last;
        milestones.add(
          ProgressMilestone(
            userId: userId,
            type: 'first_scan',
            title: 'First Baseline Scan',
            subtitle: 'Completed your calibrated starting point',
            reachedAt: firstScan.createdAt,
            seenAt: firstScan.createdAt,
          ),
        );
      }

      return Right(milestones);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load milestones: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProgressExperiment>>> getExperiments({
    required String userId,
  }) async {
    try {
      final dao = _experimentDao;
      if (dao == null) {
        if (_seedDemoIfEmpty) {
          return Right(
            ProgressSqlSeedDataSource.buildSeedExperiments(
              userId: userId,
              referenceDate: _referenceDate,
            ),
          );
        }
        return const Right([]);
      }

      final entries = await dao.getExperimentsForUser(userId);
      if (entries.isEmpty) {
        if (_seedDemoIfEmpty) {
          return Right(
            ProgressSqlSeedDataSource.buildSeedExperiments(
              userId: userId,
              referenceDate: _referenceDate,
            ),
          );
        }
        return const Right([]);
      }

      final list = entries.map((e) {
        return ProgressExperiment(
          id: e.id,
          userId: e.userId,
          title: e.title,
          targets: e.targets,
          plannedDays: e.plannedDays,
          startedAt: e.startedAt,
          startedOn: DateTime.tryParse(e.startedOn) ?? e.startedAt,
          status: e.status,
          adherence: e.adherence ?? 0.8,
          itemId: e.itemId,
          endedAt: e.endedAt,
        );
      }).toList();

      return Right(list);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load experiments: $e'));
    }
  }

  static bool _isDemoSeedLog(String id) {
    return id.endsWith('-am-cleanser') ||
        id.endsWith('-am-toner') ||
        id.endsWith('-am-vitc') ||
        id.endsWith('-pm-cleanser');
  }
}
