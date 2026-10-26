// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementation of [AuthRepository] mediating between Supabase and Domain.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl].
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    OnboardingRepository? onboardingRepository,
    NotificationRepository? notificationRepository,
  }) : _remoteDataSource = remoteDataSource,
       _onboardingRepository = onboardingRepository,
       _notificationRepository = notificationRepository;

  final AuthRemoteDataSource _remoteDataSource;
  final OnboardingRepository? _onboardingRepository;
  final NotificationRepository? _notificationRepository;

  @override
  ResultFuture<void> sendEmailOtp({required String email}) async {
    try {
      await _remoteDataSource.sendEmailOtp(email: email);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, cause: e));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on AppException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error: $e', cause: e));
    }
  }

  @override
  ResultFuture<UserAccount> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      final model = await _remoteDataSource.verifyEmailOtp(
        email: email,
        token: token,
      );
      final entity = model.toEntity();
      await _linkProfileSafely(entity.id);
      return Right(entity);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, cause: e));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on AppException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error: $e', cause: e));
    }
  }

  @override
  ResultFuture<UserAccount> setPassword({required String password}) async {
    try {
      final model = await _remoteDataSource.setPassword(password: password);
      final entity = model.toEntity();
      await _linkProfileSafely(entity.id);
      return Right(entity);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, cause: e));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on AppException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error: $e', cause: e));
    }
  }

  @override
  ResultFuture<UserAccount> linkWithApple() async {
    try {
      final model = await _remoteDataSource.linkWithApple();
      final entity = model.toEntity();
      await _linkProfileSafely(entity.id);
      return Right(entity);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on AppException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error: $e', cause: e));
    }
  }

  @override
  ResultFuture<UserAccount> linkWithGoogle() async {
    try {
      final model = await _remoteDataSource.linkWithGoogle();
      final entity = model.toEntity();
      await _linkProfileSafely(entity.id);
      return Right(entity);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on AppException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode, cause: e),
      );
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error: $e', cause: e));
    }
  }

  @override
  ResultFuture<void> skipAccountLinking() async {
    try {
      await _remoteDataSource.skipAccountLinking();
      await _scheduleFreeUserReminders();
      return const Right(null);
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Error skipping auth: $e'));
    }
  }

  @override
  ResultFuture<UserAccount?> getCurrentUser() async {
    try {
      final model = await _remoteDataSource.getCurrentUser();
      return Right(model?.toEntity());
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: 'Error fetching session: $e'));
    }
  }

  Future<void> _linkProfileSafely(String userId) async {
    if (_onboardingRepository == null) return;
    try {
      await _onboardingRepository.linkProfileToUser(userId: userId);
    } on Object catch (_) {}
  }

  Future<void> _scheduleFreeUserReminders() async {
    if (_notificationRepository == null) return;
    try {
      final now = DateTime.now();
      // J+3 Reminder
      await _notificationRepository.scheduleNotification(
        payload: NotificationPayload.fromType(
          type: NotificationType.scanDue,
          customTitle: 'Keep your skin progress safe',
          customBody:
              'Link your account in one tap so you never lose your scans '
              'and routine history.',
          customTargetRoute: AppRoutes.accountSecure,
          createdAt: now,
        ),
        scheduledTime: now.add(const Duration(days: 3)),
      );

      // J+7 Reminder
      await _notificationRepository.scheduleNotification(
        payload: NotificationPayload.fromType(
          type: NotificationType.winBack,
          customTitle: 'Protect your scan insights',
          customBody:
              'Your skin data is still waiting for you. '
              'Secure your account today.',
          customTargetRoute: AppRoutes.accountSecure,
          createdAt: now,
        ),
        scheduledTime: now.add(const Duration(days: 7)),
      );
    } on Object catch (_) {}
  }
}
