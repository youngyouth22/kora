// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/auth/domain/entities/user_account.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/auth/domain/usecases/link_with_apple_usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_google_usecase.dart';
import 'package:kora/features/auth/domain/usecases/send_email_otp_usecase.dart';
import 'package:kora/features/auth/domain/usecases/set_account_password_usecase.dart';
import 'package:kora/features/auth/domain/usecases/skip_account_linking_usecase.dart';
import 'package:kora/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/pages/account_secure_page.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_state.dart';
import 'package:kora/features/notifications/presentation/pages/notification_reminder_screen.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:kora/features/subscription/presentation/pages/kora_paywall_page.dart';

class _FakePermissionService implements NotificationPermissionService {
  _FakePermissionService({required this.isGranted});

  bool isGranted;
  int requestCount = 0;

  @override
  Future<bool> requestNotificationPermission() async {
    requestCount++;
    return isGranted;
  }

  @override
  Future<bool> isPermissionGranted() async => isGranted;

  @override
  Future<bool> isPermanentlyDenied() async => false;

  @override
  Future<bool> openSettings() async => true;
}

// ignore: prefer_file_naming_conventions
class _DummyNotificationBloc extends Bloc<NotificationEvent, NotificationState>
    implements NotificationBloc {
  _DummyNotificationBloc() : super(const NotificationState()) {
    on<NotificationEvent>((event, emit) {});
  }
}

class _MockAuthRepo implements AuthRepository {
  @override
  ResultFuture<void> sendEmailOtp({required String email}) async =>
      const Right(null);

  @override
  ResultFuture<UserAccount> verifyEmailOtp({
    required String email,
    required String token,
  }) async => const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<UserAccount> setPassword({required String password}) async =>
      const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<UserAccount> linkWithApple() async =>
      const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<UserAccount> linkWithGoogle() async =>
      const Right(UserAccount(id: '1', isAnonymous: false));

  @override
  ResultFuture<void> skipAccountLinking() async => const Right(null);

  @override
  ResultFuture<UserAccount?> getCurrentUser() async => const Right(null);
}

void main() {
  final sl = GetIt.instance;
  late OnboardingLocalDataSource localDataSource;
  late OnboardingRemoteDataSource remoteDataSource;
  late OnboardingRepositoryImpl onboardingRepository;
  late CompleteOnboardingUseCase completeOnboardingUseCase;
  late AppSessionState sessionState;

  setUp(() async {
    localDataSource = OnboardingLocalDataSourceImpl();
    remoteDataSource = OnboardingRemoteDataSourceImpl();
    onboardingRepository = OnboardingRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    completeOnboardingUseCase = CompleteOnboardingUseCase(onboardingRepository);

    if (sl.isRegistered<CompleteOnboardingUseCase>()) {
      await sl.unregister<CompleteOnboardingUseCase>();
    }
    sl.registerSingleton<CompleteOnboardingUseCase>(completeOnboardingUseCase);

    sessionState = AppSessionState(isInitialized: true);

    if (sl.isRegistered<AppSessionState>()) {
      await sl.unregister<AppSessionState>();
    }
    sl.registerSingleton<AppSessionState>(sessionState);
  });

  tearDown(() async {
    if (sl.isRegistered<CompleteOnboardingUseCase>()) {
      await sl.unregister<CompleteOnboardingUseCase>();
    }
    if (sl.isRegistered<AppSessionState>()) {
      await sl.unregister<AppSessionState>();
    }
  });

  group('Onboarding & Account Security Pipeline Tests', () {
    test(
      'OnboardingLocalDataSource persists demographics and completion status',
      () async {
        expect(await localDataSource.isOnboardingCompleted(), isFalse);

        await localDataSource.cacheDemographics(
          const UserDemographicsModel(
            gender: 'Female',
            ageRange: '25-34',
            hasSensitiveSkin: true,
          ),
        );

        final cached = await localDataSource.getLastDemographics();
        expect(cached?.gender, 'Female');
        expect(cached?.ageRange, '25-34');
        expect(cached?.hasSensitiveSkin, isTrue);

        await localDataSource.setOnboardingCompleted(completed: true);
        expect(await localDataSource.isOnboardingCompleted(), isTrue);
      },
    );

    testWidgets(
      'NotificationReminderScreen completes onboarding and sets destination',
      (tester) async {
        final fakePermissionService = _FakePermissionService(isGranted: true);
        final notifBloc = _DummyNotificationBloc();
        var grantedTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<NotificationBloc>.value(
              value: notifBloc,
              child: NotificationReminderScreen(
                permissionService: fakePermissionService,
                sessionState: sessionState,
                onPermissionGranted: () {
                  grantedTriggered = true;
                },
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.text('Stay consistent with weekly scan reminders'),
          findsOneWidget,
        );

        final enableBtn = find.byType(PrimaryButton);
        expect(enableBtn, findsOneWidget);
        await tester.tap(enableBtn);
        await tester.pump();

        expect(fakePermissionService.requestCount, equals(1));
        expect(grantedTriggered, isTrue);
        expect(sessionState.isOnboardingCompleted, isTrue);

        final isCompleted = await onboardingRepository.isOnboardingCompleted();
        expect(isCompleted.getOrElse(() => false), isTrue);
      },
    );

    testWidgets(
      'AccountSecurePage renders options to protect skin progress and save answers',
      (tester) async {
        final mockRepo = _MockAuthRepo();
        final authBloc = AuthBloc(
          sendEmailOtpUseCase: SendEmailOtpUseCase(mockRepo),
          verifyEmailOtpUseCase: VerifyEmailOtpUseCase(mockRepo),
          setAccountPasswordUseCase: SetAccountPasswordUseCase(mockRepo),
          linkWithAppleUseCase: LinkWithAppleUseCase(mockRepo),
          linkWithGoogleUseCase: LinkWithGoogleUseCase(mockRepo),
          skipAccountLinkingUseCase: SkipAccountLinkingUseCase(mockRepo),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const AccountSecurePage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Protect your skin progress'), findsOneWidget);
        expect(
          find.textContaining(
            'Link your session to keep your scan history, custom routine, and progress safe',
          ),
          findsOneWidget,
        );
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Maybe later'), findsOneWidget);
      },
    );

    testWidgets(
      'KoraPaywallPage renders and triggers onContinue callback on subscribe or close',
      (tester) async {
        bool? resultSubscribed;

        await tester.pumpWidget(
          MaterialApp(
            home: KoraPaywallPage(
              sessionState: sessionState,
              onContinue: (subscribed) {
                resultSubscribed = subscribed;
              },
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Unlock Kora Pro'), findsOneWidget);
        expect(find.text('Continue with Kora Pro'), findsOneWidget);

        await tester.tap(find.text('Continue with Kora Pro'));
        await tester.pump();

        expect(resultSubscribed, isTrue);
        expect(sessionState.hasActiveSubscription, isTrue);
      },
    );
  });
}
