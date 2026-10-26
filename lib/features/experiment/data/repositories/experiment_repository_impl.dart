// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/experiment/domain/entities/skincare_experiment.dart';
import 'package:kora/features/experiment/domain/repositories/experiment_repository.dart';

/// Offline-first implementation of [ExperimentRepository].
class ExperimentRepositoryImpl implements ExperimentRepository {
  /// Creates an [ExperimentRepositoryImpl].
  ExperimentRepositoryImpl({
    required ExperimentDao experimentDao,
    required SyncMutationDao mutationDao,
    required SyncEngine syncEngine,
  }) : _experimentDao = experimentDao,
       _mutationDao = mutationDao,
       _syncEngine = syncEngine;

  final ExperimentDao _experimentDao;
  final SyncMutationDao _mutationDao;
  final SyncEngine _syncEngine;

  @override
  Future<Either<Failure, List<SkincareExperiment>>> getExperiments({
    required String userId,
  }) async {
    try {
      final entries = await _experimentDao.getExperimentsForUser(userId);
      final list = <SkincareExperiment>[];
      for (final entry in entries) {
        final scans = await _experimentDao.getScansForExperiment(entry.id);
        list.add(_mapToEntity(entry, scans));
      }
      return Right(list);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read experiments: $e'));
    }
  }

  @override
  Stream<List<SkincareExperiment>> watchExperiments({required String userId}) {
    return _experimentDao.watchExperimentsForUser(userId).asyncMap((
      entries,
    ) async {
      final list = <SkincareExperiment>[];
      for (final entry in entries) {
        final scans = await _experimentDao.getScansForExperiment(entry.id);
        list.add(_mapToEntity(entry, scans));
      }
      return list;
    });
  }

  @override
  Future<Either<Failure, SkincareExperiment?>> getExperiment({
    required String id,
  }) async {
    try {
      final entry = await _experimentDao.getExperiment(id);
      if (entry == null) return const Right(null);

      final scans = await _experimentDao.getScansForExperiment(id);
      return Right(_mapToEntity(entry, scans));
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read experiment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveExperiment(
    SkincareExperiment experiment,
  ) async {
    try {
      final now = DateTime.now();

      final companion = ExperimentsCompanion(
        id: Value(experiment.id),
        userId: Value(experiment.userId),
        itemId: Value(experiment.itemId),
        title: Value(experiment.title),
        targets: Value(experiment.targets),
        plannedDays: Value(experiment.plannedDays),
        startedAt: Value(experiment.startedAt),
        startedOn: Value(experiment.startedOn),
        endedAt: Value(experiment.endedAt),
        status: Value(experiment.status),
        verdict: Value(experiment.verdict),
        adherence: Value(experiment.adherence),
        createdAt: Value(experiment.createdAt),
        updatedAt: Value(now),
      );

      final scanLinks = <ExperimentScansCompanion>[];
      if (experiment.baselineScanId != null) {
        scanLinks.add(
          ExperimentScansCompanion(
            experimentId: Value(experiment.id),
            scanId: Value(experiment.baselineScanId!),
            role: const Value('baseline'),
          ),
        );
      }
      if (experiment.followupScanId != null) {
        scanLinks.add(
          ExperimentScansCompanion(
            experimentId: Value(experiment.id),
            scanId: Value(experiment.followupScanId!),
            role: const Value('followup'),
          ),
        );
      }

      // 1. Local Drift write
      await _experimentDao.upsertExperiment(
        experiment: companion,
        linkedScans: scanLinks,
      );

      // 2. Queue mutation in outbox
      final payload = <String, dynamic>{
        'id': experiment.id,
        'user_id': experiment.userId,
        'item_id': experiment.itemId,
        'title': experiment.title,
        'targets': experiment.targets,
        'planned_days': experiment.plannedDays,
        'started_at': experiment.startedAt.toIso8601String(),
        'started_on': experiment.startedOn,
        'ended_at': experiment.endedAt?.toIso8601String(),
        'status': experiment.status,
        'verdict': experiment.verdict,
        'adherence': experiment.adherence,
        'created_at': experiment.createdAt.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _mutationDao.enqueue(
        id: 'mut_exp_${experiment.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'experiments',
        recordId: experiment.id,
        action: 'upsert',
        payload: payload,
      );

      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save experiment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExperiment({
    required String id,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();

      await _experimentDao.deleteExperiment(id);

      await _mutationDao.enqueue(
        id: 'mut_del_exp_${id}_${now.millisecondsSinceEpoch}',
        targetTable: 'experiments',
        recordId: id,
        action: 'delete',
        payload: {'id': id, 'user_id': userId},
      );

      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to delete experiment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncExperiments({
    required String userId,
  }) async {
    try {
      await _syncEngine.sync(userId: userId);
      return const Right(null);
    } on Object catch (e) {
      return Left(NetworkFailure(message: 'Failed to sync experiments: $e'));
    }
  }

  SkincareExperiment _mapToEntity(
    ExperimentEntry entry,
    List<ExperimentScanEntry> scans,
  ) {
    String? baselineId;
    String? followupId;
    for (final s in scans) {
      if (s.role == 'baseline') baselineId = s.scanId;
      if (s.role == 'followup') followupId = s.scanId;
    }

    return SkincareExperiment(
      id: entry.id,
      userId: entry.userId,
      itemId: entry.itemId,
      title: entry.title,
      targets: entry.targets,
      plannedDays: entry.plannedDays,
      startedAt: entry.startedAt,
      startedOn: entry.startedOn,
      endedAt: entry.endedAt,
      status: entry.status,
      verdict: entry.verdict,
      adherence: entry.adherence,
      baselineScanId: baselineId,
      followupScanId: followupId,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}
