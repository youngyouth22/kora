import 'package:kora/features/guided_capture/domain/repositories/face_capture_repository.dart';

/// Usecase to boost screen brightness for underexposed frame illumination.
class SetMaxScreenBrightnessUseCase {
  /// Creates a [SetMaxScreenBrightnessUseCase].
  const SetMaxScreenBrightnessUseCase(this._repository);

  final FaceCaptureRepository _repository;

  /// Maximizes brightness.
  Future<void> call() => _repository.setMaxScreenBrightness();
}

/// Usecase to restore original device screen brightness.
class RestoreScreenBrightnessUseCase {
  /// Creates a [RestoreScreenBrightnessUseCase].
  const RestoreScreenBrightnessUseCase(this._repository);

  final FaceCaptureRepository _repository;

  /// Restores brightness.
  Future<void> call() => _repository.restoreScreenBrightness();
}
