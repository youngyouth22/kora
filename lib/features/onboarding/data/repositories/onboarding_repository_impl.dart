// ignore_for_file: document_ignores, avoid_catches_without_on_clauses, lines_longer_than_80_chars

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementation of [OnboardingRepository].
///
/// Orchestrates data transfer between local caching and remote analytics sources.
class OnboardingRepositoryImpl implements OnboardingRepository {
  /// Creates an [OnboardingRepositoryImpl].
  const OnboardingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// Local storage data source.
  final OnboardingLocalDataSource localDataSource;

  /// Remote analytics data source.
  final OnboardingRemoteDataSource remoteDataSource;

  @override
  ResultFuture<void> trackOnboardingStarted({
    required String source,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final properties = <String, dynamic>{
        'source': source,
        'timestamp': DateTime.now().toIso8601String(),
        ...?metadata,
      };

      await remoteDataSource.trackEvent(
        eventName: 'onboarding_started',
        properties: properties,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to record onboarding started event',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<void> saveDemographics(UserDemographics demographics) async {
    try {
      var toSave = demographics;
      if (toSave.isAnonymous &&
          (toSave.anonymousId == null || toSave.anonymousId!.isEmpty)) {
        final anonId = await localDataSource.getOrCreateAnonymousId();
        toSave = toSave.copyWith(anonymousId: anonId);
      }
      final model = UserDemographicsModel.fromEntity(toSave);
      await localDataSource.cacheDemographics(model);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to save demographics',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<UserDemographics?> getDemographics() async {
    try {
      final result = await localDataSource.getLastDemographics();
      return Right(result?.toEntity());
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to retrieve demographics',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<void> saveQuizAnswers(Map<int, String> answers) async {
    try {
      await localDataSource.cacheQuizAnswers(answers);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to save quiz answers',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<Map<int, String>> getQuizAnswers() async {
    try {
      final result = await localDataSource.getQuizAnswers();
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to retrieve quiz answers',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<void> saveSkinProfile(UserSkinProfile profile) async {
    try {
      var toSave = profile;
      if (toSave.isAnonymous &&
          (toSave.anonymousId == null || toSave.anonymousId!.isEmpty)) {
        final anonId = await localDataSource.getOrCreateAnonymousId();
        toSave = toSave.copyWith(anonymousId: anonId);
      }
      final model = UserSkinProfileModel.fromEntity(toSave);
      await localDataSource.cacheSkinProfile(model);
      try {
        await remoteDataSource.syncProfile(model);
      } catch (_) {
        // Tolerates offline/network sync failure as local cache is primary (Article 5)
      }
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to save skin profile',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<UserSkinProfile?> getSkinProfile() async {
    try {
      final model = await localDataSource.getLastSkinProfile();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to retrieve skin profile',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<void> linkProfileToUser({required String userId}) async {
    try {
      await localDataSource.linkProfileToUser(userId: userId);
      final updated = await localDataSource.getLastSkinProfile();
      if (updated != null) {
        try {
          await remoteDataSource.syncProfile(updated);
        } catch (_) {
          // Offline tolerant
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to link guest profile to account',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<void> completeOnboarding() async {
    try {
      await localDataSource.setOnboardingCompleted(completed: true);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to mark onboarding completed',
          cause: e,
        ),
      );
    }
  }

  @override
  ResultFuture<bool> isOnboardingCompleted() async {
    try {
      final result = await localDataSource.isOnboardingCompleted();
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to verify onboarding completion',
          cause: e,
        ),
      );
    }
  }
}
