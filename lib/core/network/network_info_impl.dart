import 'dart:io';

import 'package:kora/core/network/network_info.dart';

/// Production implementation of [NetworkInfo] that checks socket connectivity.
class NetworkInfoImpl implements NetworkInfo {
  /// Default const constructor.
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on Object catch (_) {
      return false;
    }
  }
}
