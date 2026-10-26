import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated or anonymous user account.
///
/// Contains zero framework dependencies (Flutter, Supabase, Drift).
class UserAccount extends Equatable {
  /// Creates a [UserAccount].
  const UserAccount({
    required this.id,
    required this.isAnonymous,
    this.email,
    this.isEmailConfirmed = false,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Unique user identifier (e.g. Supabase Auth UID).
  final String id;

  /// Whether the session represents an unlinked anonymous guest.
  final bool isAnonymous;

  /// The verified or primary email address associated with the account.
  final String? email;

  /// Whether the email address has been confirmed through OTP/magiclink.
  final bool isEmailConfirmed;

  /// When the account was initially created.
  final DateTime? createdAt;

  /// Timestamp of the latest authenticated session.
  final DateTime? lastSignInAt;

  /// Creates a copy of this [UserAccount] with updated values.
  UserAccount copyWith({
    String? id,
    bool? isAnonymous,
    String? email,
    bool? isEmailConfirmed,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    isAnonymous,
    email,
    isEmailConfirmed,
    createdAt,
    lastSignInAt,
  ];
}
