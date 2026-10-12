/// Contract for checking network connectivity state across the application.
abstract class NetworkInfo {
  /// Checks if the device has an active internet connection.
  Future<bool> get isConnected;
}
