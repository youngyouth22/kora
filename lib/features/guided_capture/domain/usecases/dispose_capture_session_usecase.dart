import 'package:kora/features/guided_capture/domain/repositories/face_capture_repository.dart';

/// Usecase to clean up active camera analysis and brightness sessions.
class DisposeCaptureSessionUseCase {
  /// Creates a [DisposeCaptureSessionUseCase].
  const DisposeCaptureSessionUseCase(this._repository);

  final FaceCaptureRepository _repository;

  /// Releases repository and sensor resources.
  Future<void> call() => _repository.dispose();
}
