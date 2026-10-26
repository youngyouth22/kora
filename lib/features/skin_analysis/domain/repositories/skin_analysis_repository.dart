import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';

/// Contract for skin analysis image preprocessing and API execution.
abstract class SkinAnalysisRepository {
  /// Preprocesses the captured photo in a background isolate:
  /// - Short edge >= 1080px (HD requirement)
  /// - Long edge <= 2560px
  /// - File size < 10MB
  /// - Outputs high quality JPEG
  ///
  /// Returns the local path to the processed image file.
  Future<Either<Failure, String>> preprocessImage({
    required String inputPath,
  });

  /// Orchestrates skin analysis:
  /// - Can call the real YouCam / Supabase Edge function
  /// - Supports [useMockIfOffline] to save YouCam API credits while developing
  Future<Either<Failure, SkinAnalysisResult>> analyzeSkin({
    required String imagePath,
    bool useMockIfOffline = true,
  });
}
