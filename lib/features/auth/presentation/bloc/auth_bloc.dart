// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_apple_usecase.dart';
import 'package:kora/features/auth/domain/usecases/link_with_google_usecase.dart';
import 'package:kora/features/auth/domain/usecases/send_email_otp_usecase.dart';
import 'package:kora/features/auth/domain/usecases/set_account_password_usecase.dart';
import 'package:kora/features/auth/domain/usecases/skip_account_linking_usecase.dart';
import 'package:kora/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';

/// Orchestrates authentication and session linking flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc].
  AuthBloc({
    required SendEmailOtpUseCase sendEmailOtpUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
    required SetAccountPasswordUseCase setAccountPasswordUseCase,
    required LinkWithAppleUseCase linkWithAppleUseCase,
    required LinkWithGoogleUseCase linkWithGoogleUseCase,
    required SkipAccountLinkingUseCase skipAccountLinkingUseCase,
  }) : _sendEmailOtpUseCase = sendEmailOtpUseCase,
       _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
       _setAccountPasswordUseCase = setAccountPasswordUseCase,
       _linkWithAppleUseCase = linkWithAppleUseCase,
       _linkWithGoogleUseCase = linkWithGoogleUseCase,
       _skipAccountLinkingUseCase = skipAccountLinkingUseCase,
       super(const AuthState()) {
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthSetPasswordRequested>(_onSetPasswordRequested);
    on<AuthLinkAppleRequested>(_onLinkAppleRequested);
    on<AuthLinkGoogleRequested>(_onLinkGoogleRequested);
    on<AuthSkipRequested>(_onSkipRequested);
    on<AuthResetErrorRequested>(_onResetErrorRequested);
  }

  final SendEmailOtpUseCase _sendEmailOtpUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final SetAccountPasswordUseCase _setAccountPasswordUseCase;
  final LinkWithAppleUseCase _linkWithAppleUseCase;
  final LinkWithGoogleUseCase _linkWithGoogleUseCase;
  final SkipAccountLinkingUseCase _skipAccountLinkingUseCase;

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        email: event.email,
        clearError: true,
      ),
    );

    final result = await _sendEmailOtpUseCase(event.email);

    result.fold(
      (failure) {
        if (failure.statusCode == 409 ||
            failure.message.toLowerCase().contains('already')) {
          emit(
            state.copyWith(
              status: AuthStatus.emailAlreadyInUse,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) => emit(state.copyWith(status: AuthStatus.otpSent)),
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _verifyEmailOtpUseCase(
      VerifyEmailOtpParams(email: event.email, token: event.token),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.otpVerified,
          user: user,
          email: event.email,
        ),
      ),
    );
  }

  Future<void> _onSetPasswordRequested(
    AuthSetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _setAccountPasswordUseCase(event.password);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onLinkAppleRequested(
    AuthLinkAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _linkWithAppleUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onLinkGoogleRequested(
    AuthLinkGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _linkWithGoogleUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onSkipRequested(
    AuthSkipRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    await _skipAccountLinkingUseCase(const NoParams());

    emit(state.copyWith(status: AuthStatus.skipped));
  }

  void _onResetErrorRequested(
    AuthResetErrorRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
