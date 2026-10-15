import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/splash/data/models/app_bootstrap_model.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';

void main() {
  const tModel = AppBootstrapModel(
    isOnboardingCompleted: true,
  );

  test('is a subclass of AppBootstrapData entity', () {
    expect(tModel, isA<AppBootstrapData>());
  });

  test('fromJson deserializes properly', () {
    final json = {
      'is_onboarding_completed': true,
      'is_authenticated': false,
    };
    final result = AppBootstrapModel.fromJson(json);

    expect(result.isOnboardingCompleted, isTrue);
    expect(result.isAuthenticated, isFalse);
  });

  test('toJson serializes properly', () {
    final result = tModel.toJson();

    expect(result, {
      'is_onboarding_completed': true,
      'is_authenticated': false,
    });
  });

  test('toEntity returns valid domain entity', () {
    final entity = tModel.toEntity();
    expect(entity.isOnboardingCompleted, isTrue);
    expect(entity.isAuthenticated, isFalse);
  });
}
