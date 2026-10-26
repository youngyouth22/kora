// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';

/// Offline-first implementation of [RoutineRepository].
class RoutineRepositoryImpl implements RoutineRepository {
  /// Creates a [RoutineRepositoryImpl].
  RoutineRepositoryImpl({
    required RoutineDao routineDao,
    required SyncMutationDao mutationDao,
    required SyncEngine syncEngine,
  }) : _routineDao = routineDao,
       _mutationDao = mutationDao,
       _syncEngine = syncEngine;

  final RoutineDao _routineDao;
  final SyncMutationDao _mutationDao;
  final SyncEngine _syncEngine;

  @override
  Future<Either<Failure, List<RoutineProduct>>> getRoutineProducts({
    required String userId,
  }) async {
    try {
      final entries = await _routineDao.getRoutineItems(userId);
      return Right(entries.map(_mapItemToEntity).toList());
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read routine products: $e'));
    }
  }

  @override
  Stream<List<RoutineProduct>> watchRoutineProducts({required String userId}) {
    return _routineDao
        .watchRoutineItems(userId)
        .map((entries) => entries.map(_mapItemToEntity).toList());
  }

  @override
  Future<Either<Failure, void>> saveRoutineProduct(
    RoutineProduct product,
  ) async {
    try {
      final now = DateTime.now();

      final companion = RoutineItemsCompanion(
        id: Value(product.id),
        userId: Value(product.userId),
        name: Value(product.name),
        brand: Value(product.brand),
        stepType: Value(product.stepType),
        actives: Value(product.actives),
        period: Value(product.period),
        days: Value(product.days),
        startedOn: Value(product.startedOn),
        active: Value(product.active),
        sortOrder: Value(product.sortOrder),
        catalogProductId: Value(product.catalogProductId),
        ingredientsRaw: Value(product.ingredientsRaw),
        createdAt: Value(product.createdAt),
        updatedAt: Value(now),
      );

      // 1. Local Drift SQLite write
      await _routineDao.upsertRoutineItem(companion);

      // 2. Queue mutation in outbox
      final payload = <String, dynamic>{
        'id': product.id,
        'user_id': product.userId,
        'name': product.name,
        'brand': product.brand,
        'step_type': product.stepType,
        'actives': product.actives,
        'period': product.period,
        'days': product.days,
        'started_on': product.startedOn?.toIso8601String(),
        'active': product.active,
        'sort_order': product.sortOrder,
        'catalog_product_id': product.catalogProductId,
        'ingredients_raw': product.ingredientsRaw,
        'created_at': product.createdAt.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _mutationDao.enqueue(
        id: 'mut_item_${product.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'routine_items',
        recordId: product.id,
        action: 'upsert',
        payload: payload,
      );

      // 3. Notify sync engine
      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save routine product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoutineProduct({
    required String id,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();

      // 1. Local delete
      await _routineDao.deleteRoutineItem(id);

      // 2. Queue remote deletion
      await _mutationDao.enqueue(
        id: 'mut_del_item_${id}_${now.millisecondsSinceEpoch}',
        targetTable: 'routine_items',
        recordId: id,
        action: 'delete',
        payload: {'id': id, 'user_id': userId},
      );

      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(
        CacheFailure(message: 'Failed to delete routine product: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<RoutineLogRecord>>> getLogsForDate({
    required String userId,
    required String logDate,
  }) async {
    try {
      final entries = await _routineDao.getRoutineLogsForDate(
        userId: userId,
        logDate: logDate,
      );
      return Right(entries.map(_mapLogToEntity).toList());
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read routine logs: $e'));
    }
  }

  @override
  Stream<List<RoutineLogRecord>> watchLogsForDate({
    required String userId,
    required String logDate,
  }) {
    return _routineDao
        .watchRoutineLogsForDate(userId: userId, logDate: logDate)
        .map((entries) => entries.map(_mapLogToEntity).toList());
  }

  @override
  Future<Either<Failure, void>> logRoutineStep(RoutineLogRecord log) async {
    try {
      final now = DateTime.now();

      final companion = RoutineLogsCompanion(
        id: Value(log.id),
        userId: Value(log.userId),
        itemId: Value(log.itemId),
        logDate: Value(log.logDate),
        period: Value(log.period),
        done: Value(log.done),
        createdAt: Value(log.createdAt),
      );

      // 1. Local Drift write
      await _routineDao.upsertRoutineLog(companion);

      // 2. Queue mutation
      final payload = <String, dynamic>{
        'id': log.id,
        'user_id': log.userId,
        'item_id': log.itemId,
        'log_date': log.logDate,
        'period': log.period,
        'done': log.done,
        'created_at': log.createdAt.toIso8601String(),
      };

      await _mutationDao.enqueue(
        id: 'mut_log_${log.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'routine_logs',
        recordId: log.id,
        action: 'upsert',
        payload: payload,
      );

      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save routine log: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncRoutine({required String userId}) async {
    try {
      await _syncEngine.sync(userId: userId);
      return const Right(null);
    } on Object catch (e) {
      return Left(NetworkFailure(message: 'Failed to sync routine: $e'));
    }
  }

  RoutineProduct _mapItemToEntity(RoutineItemEntry entry) {
    return RoutineProduct(
      id: entry.id,
      userId: entry.userId,
      name: entry.name,
      brand: entry.brand,
      stepType: entry.stepType,
      actives: entry.actives,
      period: entry.period,
      days: entry.days,
      startedOn: entry.startedOn,
      active: entry.active,
      sortOrder: entry.sortOrder,
      catalogProductId: entry.catalogProductId,
      ingredientsRaw: entry.ingredientsRaw,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  RoutineLogRecord _mapLogToEntity(RoutineLogEntry entry) {
    return RoutineLogRecord(
      id: entry.id,
      userId: entry.userId,
      itemId: entry.itemId,
      logDate: entry.logDate,
      period: entry.period,
      done: entry.done,
      createdAt: entry.createdAt,
    );
  }
}
