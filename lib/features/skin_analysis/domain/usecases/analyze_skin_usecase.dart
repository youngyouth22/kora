import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

/// Parameters for [AnalyzeSkinUseCase].
class AnalyzeSkinParams extends Equatable {
  /// Creates [AnalyzeSkinParams].
  const AnalyzeSkinParams({
    required this.imagePath,
    this.useMockIfOffline = false,
  });

  /// Path to the preprocessed photo.
  final String imagePath;

  /// Whether to use real response fixtures to save YouCam API credits.
  final bool useMockIfOffline;

  @override
  List<Object?> get props => [imagePath, useMockIfOffline];
}

/// Use case that triggers and observes YouCam skin analysis.
class AnalyzeSkinUseCase
    implements UseCase<SkinAnalysisResult, AnalyzeSkinParams> {
  /// Creates an [AnalyzeSkinUseCase].
  const AnalyzeSkinUseCase(this._repository);

  final SkinAnalysisRepository _repository;

  @override
  Future<Either<Failure, SkinAnalysisResult>> call(AnalyzeSkinParams params) {
    return _repository.analyzeSkin(
      imagePath: params.imagePath,
      useMockIfOffline: params.useMockIfOffline,
    );
  }
}
