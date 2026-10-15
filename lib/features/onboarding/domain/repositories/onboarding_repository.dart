import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

/// Abstract contract for onboarding operations and persistence.
///
/// Follows Clean Architecture Article 1: pure interface with zero framework
/// dependencies.
abstract class OnboardingRepository {
  /// Emits an onboarding analytics event with attribution source.
  ResultFuture<void> trackOnboardingStarted({
    required String source,
    Map<String, dynamic>? metadata,
  });

  /// Persists demographic responses (gender, age range, sensitive skin).
  ResultFuture<void> saveDemographics(UserDemographics demographics);

  /// Retrieves previously cached demographic responses.
  ResultFuture<UserDemographics?> getDemographics();

  /// Persists onboarding quiz answers.
  ResultFuture<void> saveQuizAnswers(Map<int, String> answers);

  /// Retrieves previously saved onboarding quiz answers.
  ResultFuture<Map<int, String>> getQuizAnswers();

  /// Persists the normalized skin profile and preferences.
  ResultFuture<void> saveSkinProfile(UserSkinProfile profile);

  /// Retrieves the saved skin profile (anonymous or authenticated).
  ResultFuture<UserSkinProfile?> getSkinProfile();

  /// Links an existing anonymous guest profile to an authenticated account
  /// user ID.
  ResultFuture<void> linkProfileToUser({required String userId});

  /// Flags onboarding as fully completed in local session and persistence.
  ResultFuture<void> completeOnboarding();

  /// Checks whether onboarding has already been completed.
  ResultFuture<bool> isOnboardingCompleted();
}
