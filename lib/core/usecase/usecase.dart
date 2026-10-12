// Clean Architecture use case contracts define a single callable action.
// ignore_for_file: one_member_abstracts

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';

/// Base contract for asynchronous use cases in Clean Architecture.
///
/// Encapsulates a single business action executed by BLoC or services.
/// Returns a [Future] containing an [Either] of [Failure] (Left)
/// or [Output] (Right).
abstract class UseCase<Output, Params> {
  /// Executes the use case with given [params].
  Future<Either<Failure, Output>> call(Params params);
}

/// Base contract for reactive stream-based use cases.
///
/// Useful for continuous subscriptions (Drift database queries,
/// real-time sync).
abstract class StreamUseCase<Output, Params> {
  /// Executes the stream use case with given [params].
  Stream<Either<Failure, Output>> call(Params params);
}

/// Base contract for pure synchronous business logic use cases.
///
/// Used for deterministic calculations (verdict computation,
/// streak recalculation, noise threshold evaluation) without
/// asynchronous overhead.
abstract class SynchronousUseCase<Output, Params> {
  /// Executes the synchronous use case with given [params].
  Either<Failure, Output> call(Params params);
}

/// Representation of empty parameters for use cases that require no input.
class NoParams extends Equatable {
  /// Creates a [NoParams] instance.
  const NoParams();

  @override
  List<Object?> get props => [];
}
