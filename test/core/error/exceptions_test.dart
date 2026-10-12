import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/exceptions.dart';

void main() {
  group('Exceptions', () {
    test('ServerException supports value equality and props', () {
      const exception1 = ServerException(
        message: 'Server unreachable',
        statusCode: 503,
      );
      const exception2 = ServerException(
        message: 'Server unreachable',
        statusCode: 503,
      );

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Server unreachable', 503, null]);
      expect(
        exception1.toString(),
        contains(
          'ServerException(message: Server unreachable, statusCode: 503)',
        ),
      );
    });

    test('NetworkException supports value equality and props', () {
      const exception1 = NetworkException(
        message: 'Connection timed out',
        statusCode: 408,
      );
      const exception2 = NetworkException(
        message: 'Connection timed out',
        statusCode: 408,
      );

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Connection timed out', 408, null]);
    });

    test('CacheException supports value equality and props', () {
      const exception1 = CacheException(message: 'Disk full');
      const exception2 = CacheException(message: 'Disk full');

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Disk full', null, null]);
    });

    test('AuthException supports value equality and props', () {
      const exception1 = AuthException(message: 'JWT expired', statusCode: 401);
      const exception2 = AuthException(message: 'JWT expired', statusCode: 401);

      expect(exception1, equals(exception2));
      expect(exception1.props, ['JWT expired', 401, null]);
    });

    test('ValidationException supports value equality and props', () {
      const exception1 = ValidationException(message: 'Invalid email');
      const exception2 = ValidationException(message: 'Invalid email');

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Invalid email', null, null]);
    });

    test('ScanException supports value equality and props', () {
      const exception1 = ScanException(message: 'Poor lighting condition');
      const exception2 = ScanException(message: 'Poor lighting condition');

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Poor lighting condition', null, null]);
    });

    test('NotFoundException supports value equality and props', () {
      const exception1 = NotFoundException(message: 'Routine not found');
      const exception2 = NotFoundException(message: 'Routine not found');

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Routine not found', null, null]);
    });

    test('UnexpectedException supports value equality and props', () {
      const exception1 = UnexpectedException(message: 'Unknown crash');
      const exception2 = UnexpectedException(message: 'Unknown crash');

      expect(exception1, equals(exception2));
      expect(exception1.props, ['Unknown crash', null, null]);
    });
  });
}
