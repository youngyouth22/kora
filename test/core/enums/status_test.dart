import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';

void main() {
  group('BaseStatus', () {
    test('isInitial returns true only for initial', () {
      expect(BaseStatus.initial.isInitial, isTrue);
      expect(BaseStatus.loading.isInitial, isFalse);
      expect(BaseStatus.success.isInitial, isFalse);
      expect(BaseStatus.failure.isInitial, isFalse);
    });

    test('isLoading returns true only for loading', () {
      expect(BaseStatus.initial.isLoading, isFalse);
      expect(BaseStatus.loading.isLoading, isTrue);
      expect(BaseStatus.success.isLoading, isFalse);
      expect(BaseStatus.failure.isLoading, isFalse);
    });

    test('isSuccess returns true only for success', () {
      expect(BaseStatus.initial.isSuccess, isFalse);
      expect(BaseStatus.loading.isSuccess, isFalse);
      expect(BaseStatus.success.isSuccess, isTrue);
      expect(BaseStatus.failure.isSuccess, isFalse);
    });

    test('isFailure returns true only for failure', () {
      expect(BaseStatus.initial.isFailure, isFalse);
      expect(BaseStatus.loading.isFailure, isFalse);
      expect(BaseStatus.success.isFailure, isFalse);
      expect(BaseStatus.failure.isFailure, isTrue);
    });
  });
}
