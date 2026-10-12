import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/network/network_info.dart';

class _MockNetworkInfo implements NetworkInfo {
  _MockNetworkInfo({required this.connected});

  final bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  group('NetworkInfo', () {
    test('reports true when connected', () async {
      final networkInfo = _MockNetworkInfo(connected: true);
      expect(await networkInfo.isConnected, isTrue);
    });

    test('reports false when disconnected', () async {
      final networkInfo = _MockNetworkInfo(connected: false);
      expect(await networkInfo.isConnected, isFalse);
    });
  });
}
