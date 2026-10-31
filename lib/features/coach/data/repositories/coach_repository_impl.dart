// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/coach/data/datasources/coach_local_datasource.dart';
import 'package:kora/features/coach/data/datasources/coach_remote_datasource.dart';
import 'package:kora/features/coach/data/models/coach_chat_models.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/repositories/coach_repository.dart';

/// Implementation of [CoachRepository].
class CoachRepositoryImpl implements CoachRepository {
  /// Creates a [CoachRepositoryImpl].
  const CoachRepositoryImpl({
    required CoachRemoteDataSource remoteDataSource,
    CoachLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final CoachRemoteDataSource _remoteDataSource;
  final CoachLocalDataSource? _localDataSource;

  @override
  Future<Either<Failure, CoachReply>> sendMessage({
    required String message,
    required String threadId,
    CoachContext? coachContext,
    List<CoachChatMessage>? history,
  }) async {
    try {
      final model = await _remoteDataSource.sendMessage(
        message: message,
        threadId: threadId,
        coachContext: coachContext,
        history: history,
      );
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Object catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Unable to reach Kora Coach right now: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<CoachThread>>> getThreads() async {
    try {
      final local = _localDataSource;
      if (local == null) return const Right([]);
      final models = await local.getThreads();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read coach threads: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveThread(CoachThread thread) async {
    try {
      final local = _localDataSource;
      if (local != null) {
        await local.saveThread(CoachThreadModel.fromEntity(thread));
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save coach thread: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteThread(String threadId) async {
    try {
      final local = _localDataSource;
      if (local != null) {
        await local.deleteThread(threadId);
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to delete coach thread: $e'));
    }
  }
}
