// ignore_for_file: document_ignores

import 'dart:developer' as developer;

import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';

/// Contract for remote logging, analytics, and profile synchronization.
abstract class OnboardingRemoteDataSource {
  /// Tracks an analytics event.
  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
  });

  /// Synchronizes a user skin profile to remote storage (e.g. Supabase).
  Future<void> syncProfile(UserSkinProfileModel profile);
}

/// Remote analytics datasource implementation.
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  @override
  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
  }) async {
    developer.log(
      'Event: $eventName, Properties: $properties',
      name: 'kora.analytics',
    );
  }

  @override
  Future<void> syncProfile(UserSkinProfileModel profile) async {
    developer.log(
      'Syncing profile: isAnon=${profile.isAnonymous}, '
      'userId=${profile.userId}',
      name: 'kora.sync',
    );
  }
}
