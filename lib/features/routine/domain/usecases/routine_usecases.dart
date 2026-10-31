import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/routine/domain/entities/catalog_product.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';

/// Usecase to fetch all routine products for a user.
class GetRoutineProductsUseCase {
  /// Creates a [GetRoutineProductsUseCase].
  const GetRoutineProductsUseCase(this._repository);

  final RoutineRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, List<RoutineProduct>>> call({required String userId}) {
    return _repository.getRoutineProducts(userId: userId);
  }
}

/// Usecase to save or update a [RoutineProduct].
class SaveRoutineProductUseCase {
  /// Creates a [SaveRoutineProductUseCase].
  const SaveRoutineProductUseCase(this._repository);

  final RoutineRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, void>> call(RoutineProduct product) {
    return _repository.saveRoutineProduct(product);
  }
}

/// Usecase to delete a routine product by [id].
class DeleteRoutineProductUseCase {
  /// Creates a [DeleteRoutineProductUseCase].
  const DeleteRoutineProductUseCase(this._repository);

  final RoutineRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, void>> call({
    required String id,
    required String userId,
  }) {
    return _repository.deleteRoutineProduct(id: id, userId: userId);
  }
}

/// Usecase to toggle or record a daily routine step completion log.
class ToggleRoutineStepUseCase {
  /// Creates a [ToggleRoutineStepUseCase].
  const ToggleRoutineStepUseCase(this._repository);

  final RoutineRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, void>> call(RoutineLogRecord log) {
    return _repository.logRoutineStep(log);
  }
}

/// Usecase to retrieve daily routine logs for a specific date (`YYYY-MM-DD`).
class GetRoutineLogsForDateUseCase {
  /// Creates a [GetRoutineLogsForDateUseCase].
  const GetRoutineLogsForDateUseCase(this._repository);

  final RoutineRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, List<RoutineLogRecord>>> call({
    required String userId,
    required String logDate,
  }) {
    return _repository.getLogsForDate(userId: userId, logDate: logDate);
  }
}

/// Usecase to search and filter curated catalog products.
class GetCatalogProductsUseCase {
  /// Creates a [GetCatalogProductsUseCase].
  const GetCatalogProductsUseCase(this._repository);

  final RoutineRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, List<CatalogProduct>>> call({
    String? category,
    String? query,
  }) {
    return _repository.getCatalogProducts(category: category, query: query);
  }
}

/// Usecase to read and save the user's daily skin check-in (`public.checkins`).
class ManageSkinCheckinUseCase {
  /// Creates a [ManageSkinCheckinUseCase].
  const ManageSkinCheckinUseCase(this._repository);

  final RoutineRepository _repository;

  /// Retrieves today's check-in if logged.
  Future<Either<Failure, SkinCheckin?>> getForDate({
    required String userId,
    required String date,
  }) {
    return _repository.getCheckinForDate(userId: userId, date: date);
  }

  /// Saves or updates today's check-in.
  Future<Either<Failure, SkinCheckin>> save(SkinCheckin checkin) {
    return _repository.saveCheckin(checkin);
  }
}
