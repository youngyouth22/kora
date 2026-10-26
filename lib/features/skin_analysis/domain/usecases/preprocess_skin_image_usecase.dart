import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

/// Parameters for [PreprocessSkinImageUseCase].
class PreprocessSkinImageParams extends Equatable {
  /// Creates [PreprocessSkinImageParams].
  const PreprocessSkinImageParams({required this.inputPath});

  /// Path to the raw captured photo on disk.
  final String inputPath;

  @override
  List<Object?> get props => [inputPath];
}

/// Use case that resizes and encodes the photo to HD standards
/// in a background isolate before sending to YouCam API.
class PreprocessSkinImageUseCase
    implements UseCase<String, PreprocessSkinImageParams> {
  /// Creates a [PreprocessSkinImageUseCase].
  const PreprocessSkinImageUseCase(this._repository);

  final SkinAnalysisRepository _repository;

  @override
  Future<Either<Failure, String>> call(PreprocessSkinImageParams params) {
    return _repository.preprocessImage(inputPath: params.inputPath);
  }
}
