// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/routine/data/datasources/routine_sql_seed_datasource.dart';
import 'package:kora/features/routine/domain/entities/catalog_product.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';

/// Offline-first implementation of [RoutineRepository].
///
/// Reads and writes locally via [RoutineDao] (Drift SQLite) and queues
/// outbox mutations via [SyncMutationDao] for background Supabase sync.
/// When `seedDemoIfEmpty` is enabled (used for the default demo user),
/// automatically populates the SQLite tables (or in-memory store when Drift
/// is not initialized in lightweight widget tests) with SQL-aligned seed data
/// on first access.
class RoutineRepositoryImpl implements RoutineRepository {
  /// Creates a [RoutineRepositoryImpl].
  RoutineRepositoryImpl({
    RoutineDao? routineDao,
    SyncMutationDao? mutationDao,
    SyncEngine? syncEngine,
    bool seedDemoIfEmpty = false,
  }) : _routineDao = routineDao,
       _mutationDao = mutationDao,
       _syncEngine = syncEngine,
       _seedDemoIfEmpty = seedDemoIfEmpty;

  final RoutineDao? _routineDao;
  final SyncMutationDao? _mutationDao;
  final SyncEngine? _syncEngine;
  final bool _seedDemoIfEmpty;

  final Set<String> _seededUserIds = <String>{};
  final Set<String> _seededLogKeys = <String>{};
  final Map<String, SkinCheckin> _checkinsCache = <String, SkinCheckin>{};
  final Map<String, List<RoutineProduct>> _memoryItems =
      <String, List<RoutineProduct>>{};
  final Map<String, List<RoutineLogRecord>> _memoryLogs =
      <String, List<RoutineLogRecord>>{};

  Future<void> _ensureDemoSeedForUser(String userId) async {
    if (!_seedDemoIfEmpty && userId != RoutineSqlSeedDataSource.defaultUserId) {
      return;
    }
    if (_seededUserIds.contains(userId)) return;
    _seededUserIds.add(userId);

    final dao = _routineDao;
    if (dao == null) {
      _memoryItems.putIfAbsent(
        userId,
        () => RoutineSqlSeedDataSource.buildSeedRoutineItems(userId: userId),
      );
      return;
    }

    final existing = await dao.getRoutineItems(userId);
    if (existing.isEmpty) {
      final seedItems = RoutineSqlSeedDataSource.buildSeedRoutineItems(
        userId: userId,
      );
      for (final item in seedItems) {
        await dao.upsertRoutineItem(_mapEntityToItemCompanion(item));
      }
    }
  }

  Future<void> _ensureDemoLogsForDate({
    required String userId,
    required String logDate,
  }) async {
    if (!_seedDemoIfEmpty && userId != RoutineSqlSeedDataSource.defaultUserId) {
      return;
    }
    final key = '$userId::$logDate';
    if (_seededLogKeys.contains(key)) return;
    _seededLogKeys.add(key);

    final dao = _routineDao;
    if (dao == null) {
      _memoryLogs.putIfAbsent(
        key,
        () => RoutineSqlSeedDataSource.buildSeedLogsForDate(
          userId: userId,
          logDate: logDate,
        ),
      );
      return;
    }

    final existingLogs = await dao.getRoutineLogsForDate(
      userId: userId,
      logDate: logDate,
    );
    if (existingLogs.isEmpty) {
      final seedLogs = RoutineSqlSeedDataSource.buildSeedLogsForDate(
        userId: userId,
        logDate: logDate,
      );
      for (final log in seedLogs) {
        await dao.upsertRoutineLog(_mapEntityToLogCompanion(log));
      }
    }
  }

  @override
  Future<Either<Failure, List<RoutineProduct>>> getRoutineProducts({
    required String userId,
  }) async {
    try {
      await _ensureDemoSeedForUser(userId);
      final dao = _routineDao;
      if (dao == null) {
        final list = List<RoutineProduct>.from(
          _memoryItems[userId] ?? const <RoutineProduct>[],
        )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return Right(list);
      }
      final entries = await dao.getRoutineItems(userId);
      return Right(entries.map(_mapItemToEntity).toList());
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read routine products: $e'));
    }
  }

  @override
  Stream<List<RoutineProduct>> watchRoutineProducts({required String userId}) {
    final dao = _routineDao;
    if (dao == null) {
      return Stream.value(_memoryItems[userId] ?? const <RoutineProduct>[]);
    }
    return dao
        .watchRoutineItems(userId)
        .map((entries) => entries.map(_mapItemToEntity).toList());
  }

  @override
  Future<Either<Failure, RoutineProduct?>> getRoutineProductById({
    required String id,
    required String userId,
  }) async {
    try {
      await _ensureDemoSeedForUser(userId);
      final dao = _routineDao;
      if (dao == null) {
        final items = _memoryItems[userId] ?? const <RoutineProduct>[];
        for (final item in items) {
          if (item.id == id) return Right(item);
        }
        return const Right(null);
      }
      final entries = await dao.getRoutineItems(userId);
      for (final entry in entries) {
        if (entry.id == id) {
          return Right(_mapItemToEntity(entry));
        }
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read routine product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRoutineProduct(
    RoutineProduct product,
  ) async {
    try {
      final now = DateTime.now();
      final updated = product.copyWith(updatedAt: now);

      final dao = _routineDao;
      if (dao == null) {
        final list =
            List<RoutineProduct>.from(
                _memoryItems[updated.userId] ?? const <RoutineProduct>[],
              )
              ..removeWhere((item) => item.id == updated.id)
              ..add(updated);
        _memoryItems[updated.userId] = list;
        return const Right(null);
      }

      // 1. Local Drift SQLite write
      await dao.upsertRoutineItem(_mapEntityToItemCompanion(updated));

      // 2. Queue mutation in outbox
      final payload = <String, dynamic>{
        'id': updated.id,
        'user_id': updated.userId,
        'name': updated.name,
        'brand': updated.brand,
        'step_type': updated.stepType,
        'actives': updated.actives,
        'period': updated.period,
        'days': updated.days,
        'started_on': updated.startedOn?.toIso8601String(),
        'active': updated.active,
        'sort_order': updated.sortOrder,
        'catalog_product_id': updated.catalogProductId,
        'ingredients_raw': updated.ingredientsRaw,
        'created_at': updated.createdAt.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _mutationDao?.enqueue(
        id: 'mut_item_${updated.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'routine_items',
        recordId: updated.id,
        action: 'upsert',
        payload: payload,
      );

      // 3. Notify sync engine
      _syncEngine?.notifyMutationEnqueued();

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

      final dao = _routineDao;
      if (dao == null) {
        final list = List<RoutineProduct>.from(
          _memoryItems[userId] ?? const <RoutineProduct>[],
        )..removeWhere((item) => item.id == id);
        _memoryItems[userId] = list;
        return const Right(null);
      }

      // 1. Local delete
      await dao.deleteRoutineItem(id);

      // 2. Queue remote deletion
      await _mutationDao?.enqueue(
        id: 'mut_del_item_${id}_${now.millisecondsSinceEpoch}',
        targetTable: 'routine_items',
        recordId: id,
        action: 'delete',
        payload: {'id': id, 'user_id': userId},
      );

      _syncEngine?.notifyMutationEnqueued();

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
      await _ensureDemoLogsForDate(userId: userId, logDate: logDate);
      final dao = _routineDao;
      if (dao == null) {
        final key = '$userId::$logDate';
        return Right(
          List<RoutineLogRecord>.from(
            _memoryLogs[key] ?? const <RoutineLogRecord>[],
          ),
        );
      }
      final entries = await dao.getRoutineLogsForDate(
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
    final dao = _routineDao;
    if (dao == null) {
      final key = '$userId::$logDate';
      return Stream.value(_memoryLogs[key] ?? const <RoutineLogRecord>[]);
    }
    return dao
        .watchRoutineLogsForDate(userId: userId, logDate: logDate)
        .map((entries) => entries.map(_mapLogToEntity).toList());
  }

  @override
  Future<Either<Failure, void>> logRoutineStep(RoutineLogRecord log) async {
    try {
      final now = DateTime.now();

      final dao = _routineDao;
      if (dao == null) {
        final key = '${log.userId}::${log.logDate}';
        final list =
            List<RoutineLogRecord>.from(
                _memoryLogs[key] ?? const <RoutineLogRecord>[],
              )
              ..removeWhere(
                (item) =>
                    item.itemId == log.itemId && item.period == log.period,
              )
              ..add(log);
        _memoryLogs[key] = list;
        return const Right(null);
      }

      // 1. Local Drift write
      await dao.upsertRoutineLog(_mapEntityToLogCompanion(log));

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

      await _mutationDao?.enqueue(
        id: 'mut_log_${log.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'routine_logs',
        recordId: log.id,
        action: 'upsert',
        payload: payload,
      );

      _syncEngine?.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save routine log: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CatalogProduct>>> getCatalogProducts({
    String? category,
    String? query,
  }) async {
    try {
      var products = RoutineSqlSeedDataSource.buildCatalogProducts();
      if (category != null && category.isNotEmpty && category != 'all') {
        products = products
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        products = products.where((p) {
          final inName = p.name.toLowerCase().contains(q);
          final inBrand = (p.brand ?? '').toLowerCase().contains(q);
          final inActives = p.actives.any((a) => a.toLowerCase().contains(q));
          final inConcerns = p.concerns.any((c) => c.toLowerCase().contains(q));
          return inName || inBrand || inActives || inConcerns;
        }).toList();
      }
      return Right(products);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read catalog products: $e'));
    }
  }

  @override
  Future<Either<Failure, SkinCheckin?>> getCheckinForDate({
    required String userId,
    required String date,
  }) async {
    try {
      final key = '$userId::$date';
      if (_checkinsCache.containsKey(key)) {
        return Right(_checkinsCache[key]);
      }
      if (_seedDemoIfEmpty ||
          userId == RoutineSqlSeedDataSource.defaultUserId) {
        final seeded = RoutineSqlSeedDataSource.buildDefaultCheckin(
          userId: userId,
          date: date,
        );
        _checkinsCache[key] = seeded;
        return Right(seeded);
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read daily check-in: $e'));
    }
  }

  @override
  Future<Either<Failure, SkinCheckin>> saveCheckin(SkinCheckin checkin) async {
    try {
      final key = '${checkin.userId}::${checkin.checkinDate}';
      _checkinsCache[key] = checkin;

      final now = DateTime.now();
      await _mutationDao?.enqueue(
        id: 'mut_checkin_${checkin.id}_${now.millisecondsSinceEpoch}',
        targetTable: 'checkins',
        recordId: checkin.id,
        action: 'upsert',
        payload: <String, dynamic>{
          'id': checkin.id,
          'user_id': checkin.userId,
          'scan_id': checkin.scanId,
          'checkin_date': checkin.checkinDate,
          'skin_feel': checkin.skinFeel,
          'new_products': checkin.newProducts,
          'note': checkin.note,
          'created_at': checkin.createdAt.toIso8601String(),
        },
      );
      _syncEngine?.notifyMutationEnqueued();

      return Right(checkin);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save daily check-in: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncRoutine({required String userId}) async {
    try {
      await _syncEngine?.sync(userId: userId);
      return const Right(null);
    } on Object catch (e) {
      return Left(NetworkFailure(message: 'Failed to sync routine: $e'));
    }
  }

  RoutineItemsCompanion _mapEntityToItemCompanion(RoutineProduct product) {
    return RoutineItemsCompanion(
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
      updatedAt: Value(product.updatedAt),
    );
  }

  RoutineLogsCompanion _mapEntityToLogCompanion(RoutineLogRecord log) {
    return RoutineLogsCompanion(
      id: Value(log.id),
      userId: Value(log.userId),
      itemId: Value(log.itemId),
      logDate: Value(log.logDate),
      period: Value(log.period),
      done: Value(log.done),
      createdAt: Value(log.createdAt),
    );
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
