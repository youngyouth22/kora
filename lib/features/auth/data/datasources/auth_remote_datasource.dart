// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:developer' as developer;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/network/api_endpoints.dart';
import 'package:kora/features/auth/data/models/user_account_model.dart';
import 'package:supabase/supabase.dart' hide AuthException;
import 'package:supabase/supabase.dart' as supa show AuthException;

/// Contract for remote authentication operations via Supabase and Social
/// Providers.
abstract class AuthRemoteDataSource {
  /// Sends an email verification / OTP code to [email].
  Future<void> sendEmailOtp({required String email});

  /// Verifies the OTP [token] for [email] and returns the authenticated user.
  Future<UserAccountModel> verifyEmailOtp({
    required String email,
    required String token,
  });

  /// Sets or updates the account password for the current user.
  Future<UserAccountModel> setPassword({required String password});

  /// Links the current anonymous session with Sign in with Apple.
  Future<UserAccountModel> linkWithApple();

  /// Links the current anonymous session with Google Sign In.
  Future<UserAccountModel> linkWithGoogle();

  /// Defers account linking.
  Future<void> skipAccountLinking();

  /// Retrieves the active authenticated user, if any.
  Future<UserAccountModel?> getCurrentUser();
}

/// Production implementation of [AuthRemoteDataSource] integrating
/// Supabase Auth and Google Sign-In SDK.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSourceImpl].
  AuthRemoteDataSourceImpl({
    SupabaseClient? client,
    String? serverClientId,
  }) : _client = client,
       _serverClientId = serverClientId ?? ApiEndpoints.googleServerClientId;

  final SupabaseClient? _client;
  final String _serverClientId;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_serverClientId.isEmpty) {
      throw const AuthException(
        message:
            'Google Sign-In is not configured: '
            'GOOGLE_SERVER_CLIENT_ID is missing. '
            'Please pass --dart-define-from-file=.env when running the app.',
      );
    }
    if (!_googleInitialized) {
      try {
        await GoogleSignIn.instance.initialize(
          serverClientId: _serverClientId,
        );
        _googleInitialized = true;
      } on Object catch (e) {
        developer.log(
          'GoogleSignIn initialization warning: $e',
          name: 'AuthRemoteDataSource',
        );
      }
    }
  }

  @override
  Future<void> sendEmailOtp({required String email}) async {
    final trimmed = email.trim().toLowerCase();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      throw const ValidationException(
        message: 'Please enter a valid email address.',
      );
    }

    final client = _client;
    if (client == null) {
      throw const AuthException(
        message:
            'Supabase client is not initialized. Please verify backend setup.',
      );
    }

    try {
      final currentUser = client.auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        // Upgrade anonymous session to email
        await client.auth.updateUser(UserAttributes(email: trimmed));
      } else {
        // Direct email OTP / sign in
        await client.auth.signInWithOtp(
          email: trimmed,
          shouldCreateUser: true,
        );
      }
    } on supa.AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already in use') ||
          msg.contains('user already exists')) {
        throw const AuthException(
          message:
              'This email is already registered. '
              'Please sign in to merge your scans.',
          statusCode: 409,
        );
      }
      throw AuthException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Object catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: 'Failed to send OTP code: $e');
    }
  }

  @override
  Future<UserAccountModel> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final trimmedToken = token.trim();
    if (trimmedToken.length < 4) {
      throw const ValidationException(
        message: 'Please enter a valid verification code.',
      );
    }

    final client = _client;
    if (client == null) {
      throw const AuthException(
        message:
            'Supabase client is not initialized. Please verify backend setup.',
      );
    }

    try {
      final response = await client.auth.verifyOTP(
        email: email.trim().toLowerCase(),
        token: trimmedToken,
        type: OtpType.email,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message: 'Verification failed. No active user returned.',
        );
      }
      return UserAccountModel(
        id: user.id,
        isAnonymous: user.isAnonymous,
        email: user.email,
        isEmailConfirmed: user.emailConfirmedAt != null,
        createdAt: DateTime.tryParse(user.createdAt),
        lastSignInAt: user.lastSignInAt != null
            ? DateTime.tryParse(user.lastSignInAt!)
            : null,
      );
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Object catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: 'OTP verification failed: $e');
    }
  }

  @override
  Future<UserAccountModel> setPassword({required String password}) async {
    if (password.length < 8) {
      throw const ValidationException(
        message: 'Password must be at least 8 characters long.',
      );
    }

    final client = _client;
    if (client == null) {
      throw const AuthException(
        message:
            'Supabase client is not initialized. Please verify backend setup.',
      );
    }

    try {
      final response = await client.auth.updateUser(
        UserAttributes(password: password),
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException(message: 'Failed to update user password.');
      }
      return UserAccountModel(
        id: user.id,
        isAnonymous: user.isAnonymous,
        email: user.email,
        isEmailConfirmed: user.emailConfirmedAt != null,
        createdAt: DateTime.tryParse(user.createdAt),
        lastSignInAt: user.lastSignInAt != null
            ? DateTime.tryParse(user.lastSignInAt!)
            : null,
      );
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Object catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: 'Failed to update password: $e');
    }
  }

  @override
  Future<UserAccountModel> linkWithApple() async {
    final client = _client;
    if (client == null) {
      throw const AuthException(
        message:
            'Supabase client is not initialized. Please verify backend setup.',
      );
    }

    try {
      final currentUser = client.auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        await client.auth.getLinkIdentityUrl(OAuthProvider.apple);
      } else {
        await client.auth.getOAuthSignInUrl(provider: OAuthProvider.apple);
      }

      final user = client.auth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: 'Apple authentication did not return a user.',
        );
      }

      return UserAccountModel(
        id: user.id,
        isAnonymous: user.isAnonymous,
        email: user.email,
        isEmailConfirmed: true,
        createdAt: DateTime.tryParse(user.createdAt),
        lastSignInAt: user.lastSignInAt != null
            ? DateTime.tryParse(user.lastSignInAt!)
            : null,
      );
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Object catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: 'Sign in with Apple failed: $e');
    }
  }

  @override
  Future<UserAccountModel> linkWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final googleAccount = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final idToken = googleAccount.authentication.idToken;

      final client = _client;
      if (client != null) {
        if (idToken != null) {
          final currentUser = client.auth.currentUser;
          final isAnonymous = currentUser != null && currentUser.isAnonymous;

          final response = isAnonymous
              ? await client.auth.linkIdentityWithIdToken(
                  provider: OAuthProvider.google,
                  idToken: idToken,
                )
              : await client.auth.signInWithIdToken(
                  provider: OAuthProvider.google,
                  idToken: idToken,
                );

          final user = response.user;
          return UserAccountModel(
            id: user?.id ?? googleAccount.id,
            isAnonymous: false,
            email: user?.email ?? googleAccount.email,
            isEmailConfirmed: true,
            createdAt: DateTime.now(),
            lastSignInAt: DateTime.now(),
          );
        } else {
          await client.auth.getOAuthSignInUrl(provider: OAuthProvider.google);
          final user = client.auth.currentUser;
          return UserAccountModel(
            id: user?.id ?? googleAccount.id,
            isAnonymous: false,
            email: user?.email ?? googleAccount.email,
            isEmailConfirmed: true,
            createdAt: DateTime.now(),
            lastSignInAt: DateTime.now(),
          );
        }
      } else {
        return UserAccountModel(
          id: googleAccount.id,
          isAnonymous: false,
          email: googleAccount.email,
          isEmailConfirmed: true,
          createdAt: DateTime.now(),
          lastSignInAt: DateTime.now(),
        );
      }
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Object catch (e) {
      if (e is AppException) rethrow;
      developer.log('Google Sign-In error: $e', name: 'AuthRemoteDataSource');
      throw AuthException(message: 'Google Sign-In failed: $e');
    }
  }

  @override
  Future<void> skipAccountLinking() async {
    developer.log('User skipped account linking', name: 'AuthRemoteDataSource');
  }

  @override
  Future<UserAccountModel?> getCurrentUser() async {
    final client = _client;
    if (client == null) return null;

    final user = client.auth.currentUser;
    if (user == null) return null;

    return UserAccountModel(
      id: user.id,
      isAnonymous: user.isAnonymous,
      email: user.email,
      isEmailConfirmed: user.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(user.createdAt),
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.tryParse(user.lastSignInAt!)
          : null,
    );
  }
}
