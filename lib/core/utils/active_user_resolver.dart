import 'package:get_it/get_it.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:supabase/supabase.dart';

/// Helper to resolve the currently active user ID across offline-first and
/// authenticated sessions.
abstract final class ActiveUserResolver {
  /// Default fallback demo UUID.
  static const String defaultFallbackUserId =
      '00000000-0000-0000-0000-000000000001';

  /// Resolves the current user ID from Supabase auth, local ProfileDao,
  /// or KoraAiApiClient.
  static Future<String> resolveUserId({GetIt? locator}) async {
    final sl = locator ?? GetIt.instance;

    if (sl.isRegistered<SupabaseClient>()) {
      final supaUid = sl<SupabaseClient>().auth.currentUser?.id;
      if (supaUid != null && supaUid.isNotEmpty) {
        return supaUid;
      }
    }

    if (sl.isRegistered<ProfileDao>()) {
      try {
        final profile = await sl<ProfileDao>().getLatestProfile();
        if (profile != null && profile.id.isNotEmpty) {
          return profile.id;
        }
      } on Object catch (_) {}
    }

    if (sl.isRegistered<KoraAiApiClient>()) {
      final clientUid = sl<KoraAiApiClient>().currentUserId;
      if (clientUid.isNotEmpty && clientUid != 'anonymous-user') {
        return clientUid;
      }
    }

    return defaultFallbackUserId;
  }
}
