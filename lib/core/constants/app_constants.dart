/// Application-wide architectural constants.
abstract final class AppConstants {
  /// Default HTTP connection timeout in milliseconds.
  static const int connectTimeoutMs = 15000;

  /// Default HTTP receive timeout in milliseconds.
  static const int receiveTimeoutMs = 15000;

  /// Default send timeout in milliseconds.
  static const int sendTimeoutMs = 15000;

  /// Default pagination page size.
  static const int defaultPageSize = 20;

  /// Maximum photo upload retry count before failure.
  static const int maxPhotoUploadRetries = 3;

  /// Hero animation tag for the Kora companion mascot transitions.
  static const String mascotHeroTag = 'kora_mascot_hero';
}
