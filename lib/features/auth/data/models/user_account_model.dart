import 'package:kora/features/auth/domain/entities/user_account.dart';

/// Data model representing a user account with JSON serialization.
class UserAccountModel extends UserAccount {
  /// Creates a [UserAccountModel].
  const UserAccountModel({
    required super.id,
    required super.isAnonymous,
    super.email,
    super.isEmailConfirmed = false,
    super.createdAt,
    super.lastSignInAt,
  });

  /// Creates a [UserAccountModel] from JSON representation.
  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      id: json['id'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      email: json['email'] as String?,
      isEmailConfirmed:
          json['is_email_confirmed'] as bool? ??
          (json['email_confirmed_at'] != null),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.tryParse(json['last_sign_in_at'] as String)
          : null,
    );
  }

  /// Creates a [UserAccountModel] from a domain [UserAccount].
  factory UserAccountModel.fromEntity(UserAccount entity) {
    return UserAccountModel(
      id: entity.id,
      isAnonymous: entity.isAnonymous,
      email: entity.email,
      isEmailConfirmed: entity.isEmailConfirmed,
      createdAt: entity.createdAt,
      lastSignInAt: entity.lastSignInAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_anonymous': isAnonymous,
      'email': email,
      'is_email_confirmed': isEmailConfirmed,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
    };
  }

  /// Converts to domain [UserAccount].
  UserAccount toEntity() {
    return UserAccount(
      id: id,
      isAnonymous: isAnonymous,
      email: email,
      isEmailConfirmed: isEmailConfirmed,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }
}
