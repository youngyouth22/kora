import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';

class _FakeAsyncUseCase implements UseCase<String, String> {
  @override
  Future<Either<Failure, String>> call(String params) async {
    if (params.isEmpty) {
      return const Left(ValidationFailure(message: 'Params cannot be empty'));
    }
    return Right('Result: $params');
  }
}

class _FakeStreamUseCase implements StreamUseCase<int, int> {
  @override
  Stream<Either<Failure, int>> call(int params) async* {
    if (params < 0) {
      yield const Left(ValidationFailure(message: 'Params must be positive'));
      return;
    }
    yield Right(params);
    yield Right(params * 2);
  }
}

class _FakeSyncUseCase implements SynchronousUseCase<int, int> {
  @override
  Either<Failure, int> call(int params) {
    if (params < 0) {
      return const Left(ValidationFailure(message: 'Cannot be negative'));
    }
    return Right(params + 10);
  }
}

void main() {
  group('UseCase contracts', () {
    test('UseCase returns Right on successful execution', () async {
      final useCase = _FakeAsyncUseCase();
      final result = await useCase('kora');

      expect(result, const Right<Failure, String>('Result: kora'));
    });

    test('UseCase returns Left on failure', () async {
      final useCase = _FakeAsyncUseCase();
      final result = await useCase('');

      expect(
        result,
        const Left<Failure, String>(
          ValidationFailure(message: 'Params cannot be empty'),
        ),
      );
    });

    test(
      'StreamUseCase emits values and failures as reactive streams',
      () async {
        final streamUseCase = _FakeStreamUseCase();

        final successStream = streamUseCase(5);
        await expectLater(
          successStream,
          emitsInOrder([
            const Right<Failure, int>(5),
            const Right<Failure, int>(10),
          ]),
        );

        final errorStream = streamUseCase(-1);
        await expectLater(
          errorStream,
          emitsInOrder([
            const Left<Failure, int>(
              ValidationFailure(message: 'Params must be positive'),
            ),
          ]),
        );
      },
    );

    test('SynchronousUseCase evaluates deterministically', () {
      final syncUseCase = _FakeSyncUseCase();

      expect(syncUseCase(5), const Right<Failure, int>(15));
      expect(
        syncUseCase(-5),
        const Left<Failure, int>(
          ValidationFailure(message: 'Cannot be negative'),
        ),
      );
    });

    test('NoParams supports equality and empty props', () {
      const params1 = NoParams();
      const params2 = NoParams();

      expect(params1, equals(params2));
      expect(params1.props, isEmpty);
    });
  });
}
