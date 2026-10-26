import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

/// Contract for profile operations with offline-first guarantees.
abstract class UserProfileRepository {
  /// Retrieves profile from local Drift cache first, then triggers
  /// background sync.
  Future<Either<Failure, UserSkinProfile?>> getProfile({required String id});

  /// Watches profile reactively from local Drift SQLite database.
  Stream<UserSkinProfile?> watchProfile({required String id});

  /// Saves or updates profile locally in Drift and enqueues background sync.
  Future<Either<Failure, void>> saveProfile(UserSkinProfile profile);

  /// Synchronizes local profile with remote Supabase profile.
  Future<Either<Failure, void>> syncProfile({required String id});
}
