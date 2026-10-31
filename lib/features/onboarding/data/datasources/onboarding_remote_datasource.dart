// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:developer' as developer;

import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/sync/sync_engine.dart';
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

/// Remote analytics and synchronization datasource implementation.
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  /// Creates an [OnboardingRemoteDataSourceImpl] with optional outbox sync.
  OnboardingRemoteDataSourceImpl({
    SyncMutationDao? mutationDao,
    SyncEngine? syncEngine,
  }) : _mutationDao = mutationDao,
       _syncEngine = syncEngine;

  final SyncMutationDao? _mutationDao;
  final SyncEngine? _syncEngine;

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

    final profileId = profile.userId ?? profile.anonymousId ?? 'guest_profile';
    final payload = <String, dynamic>{
      'id': profileId,
      'skin_type': profile.skinType?.code,
      'skin_tone_self': profile.skinTone != null
          ? int.tryParse(profile.skinTone!.code.replaceAll('type_', ''))
          : null,
      'goals': profile.primaryGoals.map((g) => g.code).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final dao = _mutationDao;
    if (dao != null) {
      await dao.enqueue(
        id: 'mut_profile_${profileId}_${DateTime.now().millisecondsSinceEpoch}',
        targetTable: 'profiles',
        recordId: profileId,
        action: 'upsert',
        payload: payload,
      );
      _syncEngine?.notifyMutationEnqueued();
    }
  }
}
