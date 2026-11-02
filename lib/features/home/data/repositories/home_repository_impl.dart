// Ignore preference initializing formals for dependency injection clarity.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/core/utils/active_user_resolver.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';
import 'package:kora/features/progress/domain/repositories/progress_repository.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';
import 'package:supabase/supabase.dart';

/// Concrete implementation of [HomeRepository] querying live SQLite DAOs
/// and repositories.
class HomeRepositoryImpl implements HomeRepository {
  /// Creates a [HomeRepositoryImpl].
  HomeRepositoryImpl({
    ProfileDao? profileDao,
    ScanDao? scanDao,
    RoutineDao? routineDao,
    ExperimentDao? experimentDao,
    ProgressRepository? progressRepository,
    RoutineRepository? routineRepository,
    SupabaseClient? supabaseClient,
    AppPreferencesService? preferencesService,
  }) : _profileDao = profileDao,
       _scanDao = scanDao,
       _routineDao = routineDao,
       _experimentDao = experimentDao,
       _progressRepository = progressRepository,
       _routineRepository = routineRepository,
       _supabaseClient = supabaseClient,
       _preferencesService = preferencesService;

  final ProfileDao? _profileDao;
  final ScanDao? _scanDao;
  final RoutineDao? _routineDao;
  final ExperimentDao? _experimentDao;
  final ProgressRepository? _progressRepository;
  final RoutineRepository? _routineRepository;
  final SupabaseClient? _supabaseClient;
  final AppPreferencesService? _preferencesService;

  bool _tipRead = false;

  @override
  Future<Either<Failure, HomeDashboardData>> getDashboardData() async {
    try {
      final userId = await ActiveUserResolver.resolveUserId();
      final now = DateTime.now();
      final todayIso = _formatDate(now);

      // 1. Resolve user display name
      var userName = 'there';
      if (_profileDao != null) {
        final profile = await _profileDao.getLatestProfile();
        if (profile?.displayName != null && profile!.displayName!.isNotEmpty) {
          userName = profile.displayName!;
        }
      }
      if (userName == 'there' && _supabaseClient != null) {
        final authUser = _supabaseClient.auth.currentUser;
        final metaName = authUser?.userMetadata?['display_name'] as String?;
        if (metaName != null && metaName.isNotEmpty) {
          userName = metaName;
        } else if (authUser?.email != null) {
          userName = authUser!.email!.split('@').first;
        }
      }

      // 2. Resolve streaks and current week daily completion
      var currentStreak = 0;
      var longestStreak = 0;
      var weeklyScanStreak = 0;
      if (_progressRepository != null) {
        final streakRes = await _progressRepository.getStreakState(
          userId: userId,
        );
        streakRes.fold(
          (_) {},
          (s) {
            currentStreak = s.currentStreak;
            longestStreak = s.longestStreak;
            weeklyScanStreak = s.weeklyScanStreak;
          },
        );
      }

      // Compute Monday..Sunday completion for the current week
      final weekday = now.weekday; // 1 = Monday, 7 = Sunday
      final today = DateTime(now.year, now.month, now.day);
      final monday = today.subtract(Duration(days: weekday - 1));
      final streakDaysCompleted = <bool>[];

      final rawRoutineLogs = _routineDao != null
          ? await _routineDao.getAllRoutineLogs(userId)
          : const <RoutineLogEntry>[];
      final routineLogs = rawRoutineLogs
          .where((l) => !_isDemoSeedLog(l.id))
          .toList();
      final scans = _scanDao != null
          ? await _scanDao.getScansForUser(userId)
          : const <ScanEntry>[];

      for (var i = 0; i < 7; i++) {
        final dayDate = DateTime(monday.year, monday.month, monday.day + i);
        // Future days cannot be completed
        if (dayDate.isAfter(today)) {
          streakDaysCompleted.add(false);
          continue;
        }

        final dayIso = _formatDate(dayDate);
        final hasRoutine = routineLogs.any(
          (l) => l.logDate == dayIso && l.done,
        );
        final hasScan = scans.any((s) {
          final d = s.createdAt.toLocal();
          return d.year == dayDate.year &&
              d.month == dayDate.month &&
              d.day == dayDate.day;
        });
        streakDaysCompleted.add(hasRoutine || hasScan);
      }

      // 3. Resolve scan timing
      final hasBaselineScan = scans.isNotEmpty;
      var daysUntilNextScan = 0;
      var isScanDueToday = false;
      var nextScanDateLabel = 'Ready for first scan';

      if (hasBaselineScan) {
        final latestScan = scans.first;
        final daysSinceLastScan = now.difference(latestScan.createdAt).inDays;
        daysUntilNextScan = (7 - daysSinceLastScan).clamp(0, 7);
        isScanDueToday = daysUntilNextScan == 0;
        final targetDate = latestScan.createdAt.add(const Duration(days: 7));
        final weekdayName = _weekdayName(targetDate.weekday);
        nextScanDateLabel = '$weekdayName at 6 PM';
      }

      // 4. Resolve daily plan tasks
      final todayLogs = routineLogs
          .where((l) => l.logDate == todayIso)
          .toList();
      final morningDone = todayLogs.any(
        (l) => l.period.toLowerCase() == 'am' && l.done,
      );
      final eveningDone = todayLogs.any(
        (l) => l.period.toLowerCase() == 'pm' && l.done,
      );

      var checkinDone = false;
      if (_routineRepository != null) {
        final checkinRes = await _routineRepository.getCheckinForDate(
          userId: userId,
          date: todayIso,
        );
        checkinRes.fold(
          (_) {},
          (c) => checkinDone = c != null,
        );
      }

      // Check preferences service for daily tip if present
      if (_preferencesService != null) {
        _tipRead = _tipRead || (_preferencesService.hasSeenCaptureTips);
      }

      // 5. Resolve active experiment
      String? expTitle;
      String? expId;
      int? expDay;
      int? expTotalDays;
      String? expTargets;
      double? expAdherence;

      if (_experimentDao != null) {
        final experiments = await _experimentDao.getExperimentsForUser(userId);
        final activeList = experiments.where((e) => e.status == 'active');
        if (activeList.isNotEmpty) {
          final exp = activeList.first;
          expTitle = exp.title;
          expId = exp.id;
          expTotalDays = exp.plannedDays;
          expDay = now
              .difference(exp.startedAt)
              .inDays
              .clamp(1, exp.plannedDays);
          expTargets = exp.targets.join(' & ');
          expAdherence = exp.adherence ?? 0.82;
        }
      }

      // 6. Resolve trajectory score
      int? overallScore;
      int? scoreDelta;
      String? scoreSubtitle;

      if (scans.isNotEmpty) {
        overallScore = scans.first.overallScore?.round() ?? 75;
        if (scans.length >= 2 && scans[1].overallScore != null) {
          scoreDelta = (scans[0].overallScore! - scans[1].overallScore!)
              .round();
        } else {
          scoreDelta = 0;
        }
        scoreSubtitle = 'Calibrated skin health tracking';
      }

      return Right(
        HomeDashboardData(
          userName: userName,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          weeklyScanStreak: weeklyScanStreak,
          streakDaysCompleted: streakDaysCompleted,
          daysUntilNextScan: daysUntilNextScan,
          isScanDueToday: isScanDueToday,
          hasBaselineScan: hasBaselineScan,
          nextScanDateLabel: nextScanDateLabel,
          morningRoutineDone: morningDone,
          eveningRoutineDone: eveningDone,
          skinCheckinDone: checkinDone,
          dailyTipRead: _tipRead,
          activeExperimentTitle: expTitle,
          activeExperimentId: expId,
          activeExperimentDay: expDay,
          activeExperimentTotalDays: expTotalDays,
          activeExperimentTargets: expTargets,
          activeExperimentAdherence: expAdherence,
          overallScore: overallScore,
          scoreDelta: scoreDelta,
          scoreSubtitle: scoreSubtitle,
        ),
      );
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to load home dashboard: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitSkinCheckin({
    required int feel,
  }) async {
    try {
      final userId = await ActiveUserResolver.resolveUserId();
      final now = DateTime.now();
      final dateIso = _formatDate(now);

      if (_routineRepository != null) {
        final checkin = SkinCheckin(
          id: 'chk_${now.millisecondsSinceEpoch}',
          userId: userId,
          checkinDate: dateIso,
          skinFeel: feel,
          createdAt: now,
        );
        await _routineRepository.saveCheckin(checkin);
      }

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to submit check-in: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleDailyTip({required bool read}) async {
    _tipRead = read;
    return const Right(null);
  }

  @override
  Stream<void> watchScans() async* {
    if (_scanDao == null) return;
    final userId = await ActiveUserResolver.resolveUserId();
    yield* _scanDao.watchScansForUser(userId).map((_) {});
  }

  static bool _isDemoSeedLog(String id) {
    return id.endsWith('-am-cleanser') ||
        id.endsWith('-am-toner') ||
        id.endsWith('-am-vitc') ||
        id.endsWith('-pm-cleanser');
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
      default:
        return 'Sunday';
    }
  }
}
