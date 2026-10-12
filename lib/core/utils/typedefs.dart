import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';

/// Type definition for asynchronous Clean Architecture results returning
/// either a [Failure] or a value of type [T].
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Type definition for reactive Clean Architecture streams yielding
/// either a [Failure] or a value of type [T].
typedef ResultStream<T> = Stream<Either<Failure, T>>;

/// Type definition for synchronous results.
typedef Result<T> = Either<Failure, T>;

/// Type definition for JSON maps.
typedef JsonMap = Map<String, dynamic>;
