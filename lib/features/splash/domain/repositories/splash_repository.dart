// ignore_for_file: document_ignores
// ignore_for_file: one_member_abstracts

import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';

/// Abstract contract for bootstrapping app session and initial state.
///
/// Follows Clean Architecture Article 1: pure interface without dependencies.
abstract class SplashRepository {
  /// Resolves initial bootstrap state from local cache and remote sessions.
  ResultFuture<AppBootstrapData> bootstrap();
}
