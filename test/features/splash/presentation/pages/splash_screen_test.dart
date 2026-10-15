import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';
import 'package:kora/features/splash/domain/repositories/splash_repository.dart';
import 'package:kora/features/splash/domain/usecases/bootstrap_app_usecase.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:kora/features/splash/presentation/pages/splash_screen.dart';

class FakeSplashRepository implements SplashRepository {
  bool shouldFail = false;
  bool isOnboardingCompleted = false;

  @override
  ResultFuture<AppBootstrapData> bootstrap() async {
    if (shouldFail) {
      return const Left(
        CacheFailure(message: 'Database initialization failed'),
      );
    }
    return Right(
      AppBootstrapData(
        isOnboardingCompleted: isOnboardingCompleted,
      ),
    );
  }
}

void main() {
  testWidgets('renders KORA branding and loading indicator', (tester) async {
    final repository = FakeSplashRepository();
    final useCase = BootstrapAppUseCase(repository);
    final bloc = SplashBloc(bootstrapApp: useCase);
    final sessionState = AppSessionState();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          sessionState: sessionState,
          bloc: bloc,
        ),
      ),
    );

    expect(find.text('KORA'), findsOneWidget);
    expect(find.text('Skin tracking & routine insights'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
  });

  testWidgets('triggers sessionState.completeInitialization on success', (
    tester,
  ) async {
    final repository = FakeSplashRepository()..isOnboardingCompleted = true;
    final useCase = BootstrapAppUseCase(repository);
    final bloc = SplashBloc(bootstrapApp: useCase);
    final sessionState = AppSessionState();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          sessionState: sessionState,
          bloc: bloc,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(sessionState.isInitialized, isTrue);
    expect(sessionState.isOnboardingCompleted, isTrue);
  });

  testWidgets('displays error UI and retry button on failure', (tester) async {
    final repository = FakeSplashRepository()..shouldFail = true;
    final useCase = BootstrapAppUseCase(repository);
    final bloc = SplashBloc(bootstrapApp: useCase);
    final sessionState = AppSessionState();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          sessionState: sessionState,
          bloc: bloc,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Initialization Failed'), findsOneWidget);
    expect(find.text('Database initialization failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Tap retry with success
    repository.shouldFail = false;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(sessionState.isInitialized, isTrue);
  });
}
