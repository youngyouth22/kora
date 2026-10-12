import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure supports value equality and props', () {
      const failure1 = ServerFailure(
        message: 'Internal error',
        statusCode: 500,
        cause: 'crash',
      );
      const failure2 = ServerFailure(
        message: 'Internal error',
        statusCode: 500,
        cause: 'crash',
      );
      const failure3 = ServerFailure(
        message: 'Bad gateway',
        statusCode: 502,
      );

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
      expect(failure1.props, ['Internal error', 500, 'crash']);
      expect(
        failure1.toString(),
        contains('ServerFailure(message: Internal error, statusCode: 500)'),
      );
    });

    test('NetworkFailure supports value equality and props', () {
      const failure1 = NetworkFailure(
        message: 'No connection',
        statusCode: -1,
      );
      const failure2 = NetworkFailure(
        message: 'No connection',
        statusCode: -1,
      );

      expect(failure1, equals(failure2));
      expect(failure1.props, ['No connection', -1, null]);
    });

    test('CacheFailure supports value equality and props', () {
      const failure1 = CacheFailure(message: 'Cache miss');
      const failure2 = CacheFailure(message: 'Cache miss');

      expect(failure1, equals(failure2));
      expect(failure1.props, ['Cache miss', null, null]);
    });

    test('AuthFailure supports value equality and props', () {
      const failure1 = AuthFailure(message: 'Unauthorized', statusCode: 401);
      const failure2 = AuthFailure(message: 'Unauthorized', statusCode: 401);

      expect(failure1, equals(failure2));
      expect(failure1.props, ['Unauthorized', 401, null]);
    });

    test('ValidationFailure supports value equality and props', () {
      const failure1 = ValidationFailure(message: 'Invalid score range');
      const failure2 = ValidationFailure(message: 'Invalid score range');

      expect(failure1, equals(failure2));
      expect(failure1.props, ['Invalid score range', null, null]);
    });

    test('ScanFailure supports value equality and props', () {
      const failure1 = ScanFailure(
        message: 'Face not detected',
        statusCode: 422,
      );
      const failure2 = ScanFailure(
        message: 'Face not detected',
        statusCode: 422,
      );

      expect(failure1, equals(failure2));
      expect(failure1.props, ['Face not detected', 422, null]);
    });

    test('NotFoundFailure supports value equality and props', () {
      const failure1 = NotFoundFailure(
        message: 'Scan not found',
        statusCode: 404,
      );
      const failure2 = NotFoundFailure(
        message: 'Scan not found',
        statusCode: 404,
      );

      expect(failure1, equals(failure2));
      expect(failure1.props, ['Scan not found', 404, null]);
    });

    test('UnexpectedFailure supports value equality and props', () {
      const failure1 = UnexpectedFailure(message: 'Unknown error occurred');
      const failure2 = UnexpectedFailure(message: 'Unknown error occurred');

      expect(failure1, equals(failure2));
      expect(failure1.props, ['Unknown error occurred', null, null]);
    });
  });
}
