import 'package:get_it/get_it.dart';
import 'package:kora/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kora/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/auth/domain/usecases/link_with_apple_usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_google_usecase.dart';
import 'package:kora/features/auth/domain/usecases/send_email_otp_usecase.dart';
import 'package:kora/features/auth/domain/usecases/set_account_password_usecase.dart';
import 'package:kora/features/auth/domain/usecases/skip_account_linking_usecase.dart';
import 'package:kora/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:supabase/supabase.dart';

/// Initializes dependency injection registrations for the Auth feature.
void initAuthInjection(GetIt sl) {
  // Data Sources
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        client: sl.isRegistered<SupabaseClient>() ? sl<SupabaseClient>() : null,
      ),
    );
  }

  // Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        onboardingRepository: sl.isRegistered<OnboardingRepository>()
            ? sl<OnboardingRepository>()
            : null,
        notificationRepository: sl.isRegistered<NotificationRepository>()
            ? sl<NotificationRepository>()
            : null,
      ),
    );
  }

  // Use Cases
  if (!sl.isRegistered<SendEmailOtpUseCase>()) {
    sl.registerLazySingleton(
      () => SendEmailOtpUseCase(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<VerifyEmailOtpUseCase>()) {
    sl.registerLazySingleton(
      () => VerifyEmailOtpUseCase(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<SetAccountPasswordUseCase>()) {
    sl.registerLazySingleton(
      () => SetAccountPasswordUseCase(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<LinkWithAppleUseCase>()) {
    sl.registerLazySingleton(
      () => LinkWithAppleUseCase(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<LinkWithGoogleUseCase>()) {
    sl.registerLazySingleton(
      () => LinkWithGoogleUseCase(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<SkipAccountLinkingUseCase>()) {
    sl.registerLazySingleton(
      () => SkipAccountLinkingUseCase(sl<AuthRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        sendEmailOtpUseCase: sl<SendEmailOtpUseCase>(),
        verifyEmailOtpUseCase: sl<VerifyEmailOtpUseCase>(),
        setAccountPasswordUseCase: sl<SetAccountPasswordUseCase>(),
        linkWithAppleUseCase: sl<LinkWithAppleUseCase>(),
        linkWithGoogleUseCase: sl<LinkWithGoogleUseCase>(),
        skipAccountLinkingUseCase: sl<SkipAccountLinkingUseCase>(),
      ),
    );
  }
}
