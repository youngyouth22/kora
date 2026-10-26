import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';
import 'package:kora/features/skin_analysis/domain/usecases/preprocess_skin_image_usecase.dart';

class _FakeSkinAnalysisRepository implements SkinAnalysisRepository {
  Either<Failure, String> preprocessResult = const Right('/path/to/hd.jpg');

  @override
  Future<Either<Failure, String>> preprocessImage({
    required String inputPath,
  }) async {
    return preprocessResult;
  }

  @override
  Future<Either<Failure, SkinAnalysisResult>> analyzeSkin({
    required String imagePath,
    bool useMockIfOffline = true,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeSkinAnalysisRepository repository;
  late PreprocessSkinImageUseCase useCase;

  setUp(() {
    repository = _FakeSkinAnalysisRepository();
    useCase = PreprocessSkinImageUseCase(repository);
  });

  test('returns preprocessed image path when successful', () async {
    final result = await useCase(
      const PreprocessSkinImageParams(inputPath: '/raw/photo.jpg'),
    );

    expect(result, const Right<Failure, String>('/path/to/hd.jpg'));
  });

  test('returns failure when repository fails', () async {
    repository.preprocessResult = const Left(
      ScanFailure(message: 'Invalid dimensions'),
    );

    final result = await useCase(
      const PreprocessSkinImageParams(inputPath: '/raw/photo.jpg'),
    );

    expect(
      result,
      const Left<Failure, String>(ScanFailure(message: 'Invalid dimensions')),
    );
  });
}
